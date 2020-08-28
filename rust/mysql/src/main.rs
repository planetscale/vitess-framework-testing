// Adapted from https://docs.rs/mysql/19.0.1/mysql/index.html#example
extern crate mysql;
extern crate prettytable;
extern crate tablefy;
extern crate tablefy_derive;

use mysql::*;
use mysql::prelude::*;
use tablefy::Tablefy;
use tablefy_derive::Tablefy;

#[derive(Debug, PartialEq, Eq, Tablefy)]
struct Payment {
	customer_id: i32,
	amount: i32,
	account_name: Option<String>
}

fn main() {
	let url = std::env::var("DATABASE_URL").unwrap();
	let pool = Pool::new(url).unwrap();
	let mut conn = pool.get_conn().unwrap();

	let query = "DROP TABLE IF EXISTS payment";
	println!("--- query:\n\t{}\n\n", query);
	conn.query_drop(query).expect("DROP TABLE IF EXISTS failed");

	let query = r"
	CREATE TABLE payment (
		customer_id INT NOT NULL,
		amount INT NOT NULL,
		account_name TEXT
	)";
	println!("--- query:{}\n\n", query);
	conn.query_drop(query).expect("CREATE TABLE failed");

	let payments = vec![
		Payment{customer_id: 1, amount: 2, account_name: None},
		Payment{customer_id: 3, amount: 4, account_name: Some("foo".into())},
		Payment{customer_id: 5, amount: 6, account_name: None},
		Payment{customer_id: 7, amount: 8, account_name: None},
		Payment{customer_id: 9, amount: 10, account_name: Some("bar".into())},
	];

	let query = r"
	INSERT INTO payment
		(customer_id, amount, account_name)
	VALUES
		(:customer_id, :amount, :account_name)
	";
	println!("--- batch query:{}", query);
	conn.exec_batch(
		query,
		payments.iter().map(|p| params!{
			"customer_id" => p.customer_id,
			"amount" => p.amount,
			"account_name" => &p.account_name
		})
	).expect("INSERT with named parameters failed");
	println!("{}\n\n", tablefy::into_string(&payments));

	let query = r"
	SELECT
		customer_id,
		amount,
		account_name
	FROM
		payment
	";
	println!("--- query:{}", query);
	let payments = conn.query_map(query, |(customer_id, amount, account_name)| {
		Payment{customer_id, amount, account_name}
	}).expect("SELECT failed");
	println!("{}\n\n", tablefy::into_string(&payments));

	let query = r"
	UPDATE
		payment
	SET
		account_name = ?
	WHERE
		customer_id = ?
	";
	println!("--- query:{}", query);
	conn.exec_drop(query, ("foobar", 5)).expect("UPDATE failed");

	let query = r"
	SELECT
		customer_id,
		amount,
		account_name
	FROM
		payment
	";
	println!("--- query:{}", query);
	let payments = conn.query_map(query, |(customer_id, amount, account_name)| {
		Payment{customer_id, amount, account_name}
	}).expect("SELECT failed");
	println!("{}\n\n", tablefy::into_string(&payments));

	let query = r"
	DELETE FROM
		payment
	WHERE
		customer_id = ?
	";
	println!("--- query:{}", query);
	conn.exec_drop(query, (9,)).expect("DELETE failed");

	let query = r"
	SELECT
		customer_id,
		amount,
		account_name
	FROM
		payment
	";
	println!("--- query:{}", query);
	let payments = conn.query_map(query, |(customer_id, amount, account_name)| {
		Payment{customer_id, amount, account_name}
	}).expect("SELECT failed");
	println!("{}\n\n", tablefy::into_string(&payments));

	let query = "DROP TABLE payment";
	println!("--- query:\n\t{}\n\n", query);
	conn.query_drop(query).expect("DROP TABLE failed");

	let query = r"
	SELECT
		customer_id,
		amount,
		account_name
	FROM
		payment
	";
	println!("--- query:{}", query);
	match conn.query_drop(query) {
		Ok(_) => panic!("SELECT after DROP succeeded when it should have failed"),
		Err(e) => println!("Error (as expected):\n\t{}\n\n", e)
	};
}

