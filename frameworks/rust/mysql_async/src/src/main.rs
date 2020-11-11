// Adapted from https://docs.rs/mysql_async/0.24.2/mysql_async/index.html#example
extern crate mysql_async;
extern crate prettytable;
extern crate tablefy;
extern crate tablefy_derive;
extern crate tokio;

use mysql_async::*;
use mysql_async::prelude::*;
use tablefy::Tablefy;
use tablefy_derive::Tablefy;

#[derive(Clone, Debug, PartialEq, Eq, Tablefy)]
struct Payment {
	customer_id: i32,
	amount: i32,
	account_name: Option<String>
}

#[tokio::main]
async fn main() {
	let host = std::env::var("VT_HOST").unwrap();
	let port = match std::env::var("VT_PORT") {
		Ok(port_str) => port_str.parse::<u16>().unwrap(),
		Err(_) => 3306
	};
	let username = std::env::var("VT_USERNAME").unwrap();
	let auth = match std::env::var("VT_PASSWORD") {
		Ok(password) => format!("{}:{}", username, password),
		Err(_) => username
	};
	let database = std::env::var("VT_DATABASE").unwrap();
	let url = format!("mysql://{}@{}:{}/{}", &auth, &host, port, &database);
	println!("+++ URL: {}\n", &url);
	let pool = Pool::new(url);
	let mut conn = pool.get_conn().await.unwrap();

	let query = "DROP TABLE IF EXISTS payment";
	println!("--- query:\n\t{}\n\n", query);
	conn.query_drop(query).await.expect("DROP TABLE IF EXISTS failed");

	let query = r"
	CREATE TABLE payment (
		customer_id INT NOT NULL,
		amount INT NOT NULL,
		account_name TEXT
	)";
	println!("--- query:{}\n\n", query);
	conn.query_drop(query).await.expect("CREATE TABLE failed");

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
		payments.clone().into_iter().map(|p| params!{
			"customer_id" => p.customer_id,
			"amount" => p.amount,
			"account_name" => p.account_name
		})
	).await.expect("INSERT with named parameters failed");
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
	}).await.expect("SELECT failed");
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
	conn.exec_drop(query, ("foobar", 5)).await.expect("UPDATE failed");

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
	}).await.expect("SELECT failed");
	println!("{}\n\n", tablefy::into_string(&payments));

	let query = r"
	DELETE FROM
		payment
	WHERE
		customer_id = ?
	";
	println!("--- query:{}", query);
	conn.exec_drop(query, (9,)).await.expect("DELETE failed");

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
	}).await.expect("SELECT failed");
	println!("{}\n\n", tablefy::into_string(&payments));

	let query = "DROP TABLE payment";
	println!("--- query:\n\t{}\n\n", query);
	conn.query_drop(query).await.expect("DROP TABLE failed");

	let query = r"
	SELECT
		customer_id,
		amount,
		account_name
	FROM
		payment
	";
	println!("--- query:{}", query);
	match conn.query_drop(query).await {
		Ok(_) => panic!("SELECT after DROP succeeded when it should have failed"),
		Err(e) => println!("Error (as expected):\n\t{}\n\n", e)
	};
}

