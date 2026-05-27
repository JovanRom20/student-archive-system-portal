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
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddUserServlet")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("activeUser") == null || "Student".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Grab form inputs
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        System.out.println("--- Admin Creating New User: " + username + " ---");

        if (username != null && password != null) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                
                // 3. Insert Query (Using the CAST trick for the role, and defaulting status to Active)
                String sql = "INSERT INTO users (username, password, email, role, status) VALUES (?, ?, ?, CAST(? AS user_role), 'Active')";
                
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    
                    ps.setString(1, username);
                    ps.setString(2, password);

                    // Safely handle blank emails
                    if (email == null || email.trim().isEmpty()) {
                        ps.setNull(3, java.sql.Types.VARCHAR);
                    } else {
                        ps.setString(3, email);
                    }

                    ps.setString(4, role);
                    
                    int rowsAffected = ps.executeUpdate();
                    System.out.println("Success! Account created.");
                }
            } catch (SQLException e) {
                System.out.println("DATABASE ERROR: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        // 4. Redirect back to the dashboard table to see the new user
        response.sendRedirect("users.jsp");
    }
}