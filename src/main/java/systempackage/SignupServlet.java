package systempackage;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Grab the data the user typed into your HTML form
        String user = request.getParameter("username");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");
        String confirmPass = request.getParameter("confirm_password");
        String position = request.getParameter("position"); 

        // 2. Security Check: Make sure passwords match
        if (!pass.equals(confirmPass)) {
            response.sendRedirect("signup.jsp?error=passwordmismatch"); 
            return;
        }

        // 3. Connect to PostgreSQL and save the new user
        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // --- THE SECURITY UPGRADE ---
            // Added 'status' to the columns, and hardcoded 'Inactive' to the VALUES
            String sql = "INSERT INTO Users (username, email, password, role, status) VALUES (?, ?, ?, ?::user_role, 'Inactive')";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, user);
            pstmt.setString(2, email);
            pstmt.setString(3, pass); 
            pstmt.setString(4, position);

            pstmt.executeUpdate();
            
            System.out.println("New " + position + " registered (Pending Approval): " + user + " (" + email + ")");
            
            // --- THE REDIRECT UPGRADE ---
            // Redirect back to signup.jsp to trigger the pending modal
            response.sendRedirect("signup.jsp?success=pending");

        } catch (SQLException e) {
            // Check for unique constraint violations (duplicate username OR duplicate email)
            if ("23505".equals(e.getSQLState())) {
                String errorMsg = e.getMessage().toLowerCase();
                
                // Determine if it was the email or username that caused the conflict
                if (errorMsg.contains("email")) {
                    System.out.println("Registration failed: Email " + email + " already exists.");
                    response.sendRedirect("signup.jsp?error=emailexists");
                } else {
                    System.out.println("Registration failed: Username " + user + " already exists.");
                    response.sendRedirect("signup.jsp?error=userexists");
                }
            } else {
                e.printStackTrace();
                System.out.println("Database error during signup.");
                response.sendRedirect("signup.jsp?error=server");
            }
         }
     }
}