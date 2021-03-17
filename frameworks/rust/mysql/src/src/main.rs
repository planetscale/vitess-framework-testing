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

	let query = r"
	SELECT
		column_name column_name,
		data_type data_type,
		column_type full_data_type,
		character_maximum_length character_maximum_length,
		numeric_precision numeric_precision,
		numeric_scale numeric_scale,
		datetime_precision datetime_precision,
		column_default column_default,
		is_nullable is_nullable,
		extra extra,
		table_name table_name
	FROM information_schema.columns
	WHERE table_schema = '".to_owned() + &std::env::var("VT_DATABASE").unwrap() + r"'
	ORDER BY ordinal_position
	";
	println!("--- query:{}", query);
	let rows: Vec<ColumnInfo> = conn.query(query).expect("SELECT from information_schema.columns failed");
	assert_eq!(rows.len(), 2);
	// MySQL 5.7 returns "int(11)" for column_type; 8.0 only returns "int"
	assert!(
		rows[0] == ColumnInfo::new2("one", "int", "int(11)", None, Some(10), Some(0), None, None, "NO", "", "a") ||
		rows[0] == ColumnInfo::new2("one", "int", "int", None, Some(10), Some(0), None, None, "NO", "", "a")
	);
	assert!(
		rows[1] == ColumnInfo::new2("two", "int", "int(11)", None, Some(10), Some(0), None, None, "NO", "", "a") ||
		rows[1] == ColumnInfo::new2("two", "int", "int", None, Some(10), Some(0), None, None, "NO", "", "a")
	);

	let query = r"
	SELECT
		column_name column_name,
		data_type data_type,
		column_type full_data_type,
		character_maximum_length character_maximum_length,
		numeric_precision numeric_precision,
		numeric_scale numeric_scale,
		datetime_precision datetime_precision,
		column_default column_default,
		is_nullable is_nullable,
		extra extra,
		table_name table_name
	FROM information_schema.columns
	WHERE table_schema = ?
	ORDER BY ordinal_position
	";
	println!("--- query:{}", query);
	let stmt = conn.prep(query).expect("prepare SELECT from information_schema.columns failed");
	let rows: Vec<ColumnInfo> = conn.exec(stmt, (std::env::var("VT_DATABASE").unwrap(),)).expect("exec prepared SELECT from information_schema.columns failed");
	assert_eq!(rows.len(), 2);
	assert!(
		rows[0] == ColumnInfo::new2("one", "int", "int(11)", None, Some(10), Some(0), None, None, "NO", "", "a") ||
		rows[0] == ColumnInfo::new2("one", "int", "int", None, Some(10), Some(0), None, None, "NO", "", "a")
	);
	assert!(
		rows[1] == ColumnInfo::new2("two", "int", "int(11)", None, Some(10), Some(0), None, None, "NO", "", "a") ||
		rows[1] == ColumnInfo::new2("two", "int", "int", None, Some(10), Some(0), None, None, "NO", "", "a")
	);
}

