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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Grab what they typed (it could be a username OR an email)
        String loginInput = request.getParameter("username"); 
        String pass = request.getParameter("password");

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // --- THE SECURITY UPGRADE: Step 1 ---
            // Added 'status' to the SELECT statement so Java can read it
            String sql = "SELECT username, role, status FROM Users WHERE (username = ? OR email = ?) AND password = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            // We pass the loginInput twice because of the two ? placeholders in the OR statement
            pstmt.setString(1, loginInput);
            pstmt.setString(2, loginInput);
            pstmt.setString(3, pass);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                
                // --- THE SECURITY UPGRADE: Step 2 ---
                // Grab the status first before doing anything else
                String accountStatus = rs.getString("status");
                
                // The Bouncer: Kick them out immediately if they are Inactive
                if ("Inactive".equalsIgnoreCase(accountStatus)) {
                    System.out.println("Blocked login attempt for inactive user: " + loginInput);
                    response.sendRedirect("login.jsp?error=account_disabled");
                    return; // Stops the code dead in its tracks!
                }

                // SUCCESS! (If they made it past the bouncer)
                String role = rs.getString("role");
                String actualUsername = rs.getString("username"); // Grab their real username from the DB

                // Save their actual username to the session, even if they logged in with their email
                HttpSession session = request.getSession();
                session.setAttribute("activeUser", actualUsername); 
                session.setAttribute("userRole", role);

                System.out.println("Successful login: " + actualUsername + " (" + role + ")");

                // Traffic Control
                if (role.equals("Student")) {
                    response.sendRedirect("studentDashboard.jsp");
                } else if (role.equals("Admin") || role.equals("Faculty")) {
                    response.sendRedirect("adminDashboard.jsp");
                }

            } else {
                System.out.println("Failed login attempt for: " + loginInput);
                response.sendRedirect("login.jsp?error=invalid");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Database error during login.");
            response.sendRedirect("login.jsp?error=server");
        }
    }
}