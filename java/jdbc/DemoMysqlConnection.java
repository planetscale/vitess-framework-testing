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

			Statement st = con.createStatement();
			st.executeUpdate(createTableSql);
			st.close();

			st.getConnection();
			String insertUser1 = "INSERT INTO people VALUES (1, 'Vitess User 1')";
			String insertUser2 = "INSERT INTO people VALUES (2, 'Vitess User 2')";
			String insertUser3 = "INSERT INTO people VALUES (3, 'Vitess User 3')";
			st.executeUpdate(insertUser1);
			st.executeUpdate(insertUser2);
			st.executeUpdate(insertUser3);
			st.close();

			st.getConnection();
			
			con.close();
		}
		catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
