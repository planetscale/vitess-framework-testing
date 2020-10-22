import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

class DemoMysqlConnection {
	public static void main(String args[]){
		try{
			Class.forName("com.mysql.cj.jdbc.Driver");

			String vtUsername = System.getenv("VT_USERNAME");
			String vtPassword = System.getenv("VT_PASSWORD");
			String vtHost = System.getenv("VT_HOST");
			String vtPort = System.getenv("VT_PORT");
			String vtDatabase = System.getenv("VT_DATABASE");

			String connectionUri = "jdbc:mysql://" + vtHost + ":" + vtPort + "/" + vtDatabase;
			Connection con = DriverManager.getConnection(connectionUri, vtUsername, vtPassword);
			
			Statement st = con.createStatement();
			ResultSet rs = st.executeQuery("select * from login");
			
			while(rs.next()){
				System.out.println("there was another result");
			}
			
			con.close();
		}
		catch(Exception e){
			e.printStackTrace();
			System.exit(1);
		}
	}
}
