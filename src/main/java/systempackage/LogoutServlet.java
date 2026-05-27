package systempackage;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // 1. Set a default destination just in case
        String redirectTarget = "login.jsp?success=loggedout";
        
        if (session != null) {
            
            // 2. Grab the user's role BEFORE we destroy the session!
            String role = (String) session.getAttribute("userRole");
            
            // 3. If they are a student, change the destination door
            if ("Student".equals(role)) {
                redirectTarget = "loginStudent.jsp?success=loggedout";
            }
            
            // 4. Now it is safe to wipe the memory
            session.invalidate();
            System.out.println("User session destroyed. Successfully logged out.");
        }
        
        // 5. Send them back to the correct front door
        response.sendRedirect(redirectTarget);
    }
}