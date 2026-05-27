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

@WebServlet("/EditUserServlet")
public class EditUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("activeUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Grab form inputs
        String userIdStr = request.getParameter("userId");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        String status = request.getParameter("status");

        System.out.println("--- Attempting to Update User ID: " + userIdStr + " ---");

        if (userIdStr != null && username != null) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                
                // THE FIX: We added CAST(? AS user_role) so PostgreSQL accepts the text from Java!
                String sql = "UPDATE users SET username=?, email=?, role=CAST(? AS user_role), status=? WHERE user_id=?";
                
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    
                    ps.setString(1, username);

                    // Safely handle blank emails
                    if (email == null || email.trim().isEmpty()) {
                        ps.setNull(2, java.sql.Types.VARCHAR);
                    } else {
                        ps.setString(2, email);
                    }

                    ps.setString(3, role);
                    ps.setString(4, status);
                    ps.setInt(5, Integer.parseInt(userIdStr));
                    
                    int rowsAffected = ps.executeUpdate();
                    System.out.println("Success! Rows updated: " + rowsAffected);
                }
            } catch (SQLException e) {
                System.out.println("DATABASE ERROR: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        response.sendRedirect("users.jsp");
    }
}