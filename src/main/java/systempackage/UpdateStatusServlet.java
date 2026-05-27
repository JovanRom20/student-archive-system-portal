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

@WebServlet("/UpdateStatusServlet")
public class UpdateStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Security check: Only Admins and Faculty should be doing this!
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        if (role == null || role.equals("Student")) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        // Grab the ID and the new status from the hidden form inputs
        String thesisIdStr = request.getParameter("thesisId");
        String newStatus = request.getParameter("newStatus"); 

        if (thesisIdStr != null && newStatus != null) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                
                // Update the status in the database using the custom ENUM cast
                String sql = "UPDATE Thesis_Records SET status = ?::thesis_status WHERE thesis_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                
                pstmt.setString(1, newStatus);
                pstmt.setInt(2, Integer.parseInt(thesisIdStr));
                
                pstmt.executeUpdate();
                System.out.println("Thesis ID " + thesisIdStr + " status updated to: " + newStatus);

            } catch (SQLException e) {
                e.printStackTrace();
                System.out.println("Database error while updating status.");
            }
        }
        
        // Redirect back to the dashboard so the admin sees the updated table immediately
        response.sendRedirect("adminDashboard.jsp");
    }
}