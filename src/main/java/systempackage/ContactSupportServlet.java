package systempackage;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ContactSupportServlet")
public class ContactSupportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // In a real production environment, you would use JavaMail to send an actual email here.
        // For this prototype, we will just simulate a successful submission!
        
        String name = request.getParameter("name");
        String subject = request.getParameter("subject");
        
        System.out.println("--- New Support Ticket Received ---");
        System.out.println("From: " + name);
        System.out.println("Subject: " + subject);
        System.out.println("-----------------------------------");
        
        // Redirect back to the contact page with a success message flag in the URL
        response.sendRedirect("contact.jsp?msg=sent");
    }
}