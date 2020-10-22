import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

class DemoMysqlConnection {
	public static void main(String args[]) {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");

			String vtUsername = System.getenv("VT_USERNAME");
			String vtPassword = System.getenv("VT_PASSWORD");
			String vtHost = System.getenv("VT_HOST");
			String vtPort = System.getenv("VT_PORT");
			String vtDatabase = System.getenv("VT_DATABASE");

			String connectionUri = "jdbc:mysql://" + vtHost + ":" + vtPort + "/" + vtDatabase;
			Connection con = DriverManager.getConnection(connectionUri, vtUsername, vtPassword);

			String createTableSql = "CREATE TABLE people (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL) ";
			String insertUser1Sql = "INSERT INTO people VALUES (1, 'Vitess User 1')";
			String insertUser2Sql = "INSERT INTO people VALUES (2, 'Vitess User 2')";
			String insertUser3Sql = "INSERT INTO people VALUES (3, 'Vitess User 3')";
			String selectPeopleSql = "SELECT * FROM people";
			String updatePeopleSql = "UPDATE people SET name='Vitess User 500' where id=2";
			String dropPeopleSql = "DROP TABLE people";

			Statement st = con.createStatement();
			st.getConnection();

			// Create table
			st.executeUpdate(createTableSql);

			// Insert three records into people table
			st.executeUpdate(insertUser1Sql);
			st.executeUpdate(insertUser2Sql);
			st.executeUpdate(insertUser3Sql);
			con.commit();

			// Select * from people
			st.executeQuery(selectPeopleSql);

			// Update records
			st.executeUpdate(updatePeopleSql);
			con.commit();

			// Select * again
			st.executeQuery(selectPeopleSql);

			// Drop the table
			st.getConnection();
			st.executeUpdate(dropPeopleSql);
			con.commit();

			st.close();
			con.close();
		}
		catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
