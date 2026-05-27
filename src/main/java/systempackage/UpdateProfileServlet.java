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

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("activeUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String currentUser = (String) session.getAttribute("activeUser");
        String newFullName = request.getParameter("fullName");
        String newEmail = request.getParameter("email");
        
        // Note: We are ignoring the 'department' parameter since it's not in the database yet.

        if (newFullName != null && !newFullName.trim().isEmpty()) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                String sql = "UPDATE users SET username = ?, email = ? WHERE username = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, newFullName);
                    ps.setString(2, newEmail);
                    ps.setString(3, currentUser);
                    
                    int rowsUpdated = ps.executeUpdate();
                    
                    if (rowsUpdated > 0) {
                        // Update the session attribute since the username changed!
                        session.setAttribute("activeUser", newFullName);
                        response.sendRedirect("settings.jsp?msg=profileUpdated");
                        return;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        response.sendRedirect("settings.jsp?msg=error");
    }
}