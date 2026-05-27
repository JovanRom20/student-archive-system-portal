package systempackage;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
	
    private static final String URL = "jdbc:postgresql://localhost:5432/thesis_archive";
    private static final String USER = "postgres"; // Default PostgreSQL user
    private static final String PASSWORD = "jovan123"; // The password you set during installation

    
    private DatabaseConnection() {}

    public static Connection getConnection() {
        Connection connection = null;
        try {
            
            Class.forName("org.postgresql.Driver");
            
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("PostgreSQL Database connected successfully.");
            
        } catch (ClassNotFoundException e) {
            System.out.println("PostgreSQL JDBC Driver not found. Make sure the .jar is in your WEB-INF/lib folder.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("Connection failed. Check your credentials and ensure the server is running on port 5432.");
            e.printStackTrace();
        }
        return connection;
    }
}

