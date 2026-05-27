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

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("activeUser") == null || "Student".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Get the ID from the URL
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            
            try (Connection conn = DatabaseConnection.getConnection()) {
                // 3. Delete the user
                String sql = "DELETE FROM users WHERE user_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(idStr));
                    ps.executeUpdate();
                }
            } catch (SQLException | NumberFormatException e) {
                e.printStackTrace();
            }
        }
        
        // 4. Send them right back to the table
        response.sendRedirect("users.jsp");
    }
}