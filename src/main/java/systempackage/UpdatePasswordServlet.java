package systempackage;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdatePasswordServlet")
public class UpdatePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("activeUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentUser = (String) session.getAttribute("activeUser");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("settings.jsp?msg=passwordMismatch");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Step 1: Verify current password
            String checkSql = "SELECT user_id FROM users WHERE username = ? AND password = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, currentUser);
                checkPs.setString(2, currentPassword);
                
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        // Current password didn't match
                        response.sendRedirect("settings.jsp?msg=incorrectPassword");
                        return;
                    }
                }
            }

            // Step 2: Update to new password
            String updateSql = "UPDATE users SET password = ? WHERE username = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, newPassword);
                updatePs.setString(2, currentUser);
                updatePs.executeUpdate();
                
                response.sendRedirect("settings.jsp?msg=passwordUpdated");
                return;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("settings.jsp?msg=error");
        }
    }
}