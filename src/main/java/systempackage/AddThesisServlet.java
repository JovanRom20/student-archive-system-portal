package systempackage;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/AddThesisServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 25,       // 25MB
    maxRequestSize = 1024 * 1024 * 30     // 30MB
)
public class AddThesisServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Security Check
        HttpSession session = request.getSession();
        String currentUser = (String) session.getAttribute("activeUser");
        String role = (String) session.getAttribute("userRole");

        if (currentUser == null || "Student".equals(role)) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        // 2. Extract Text Data
        String title = request.getParameter("title");
        String department = request.getParameter("department");
        String author = request.getParameter("author");
        String submissionDateStr = request.getParameter("submissionDate");
        String abstractText = request.getParameter("abstractText");
        String keywords = request.getParameter("keywords");

        // 3. Handle File Upload
        Part filePart = request.getPart("thesisFile");
        String fileName = "";

        if (filePart != null && filePart.getSize() > 0) {
            // Get original file name and clean it to prevent issues
            fileName = filePart.getSubmittedFileName().replaceAll("\\s+", "_"); 

            // Define where the "uploads" folder is physically located on the server
            // Using getRealPath creates the folder inside your Tomcat deployment directory
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir(); // Create the folder if it doesn't exist
            }

            // Save the physical file to that folder!
            Path filePath = Paths.get(uploadPath, fileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
                System.out.println("File saved securely to: " + filePath.toString());
            } catch (IOException e) {
                System.out.println("Error writing file to disk!");
                e.printStackTrace();
            }
        } else {
            fileName = "No file attached"; // Fallback if they didn't upload a file
        }

        // 4. Save Record to Database
        if (title != null && author != null && submissionDateStr != null) {
            try (Connection conn = DatabaseConnection.getConnection()) {
                
                Date subDate = Date.valueOf(submissionDateStr); 

                String sql = "INSERT INTO Thesis_Records (title, department, author, submission_date, abstract_text, keywords, file_name, uploaded_by, status) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Active'::thesis_status)";
                
                PreparedStatement pstmt = conn.prepareStatement(sql);
                
                pstmt.setString(1, title);
                pstmt.setString(2, department);
                pstmt.setString(3, author);
                pstmt.setDate(4, subDate);
                pstmt.setString(5, abstractText);
                pstmt.setString(6, keywords);
                pstmt.setString(7, fileName); // We save the exact name so the iframe can find it later!
                pstmt.setString(8, currentUser); 
                
                pstmt.executeUpdate();
                System.out.println("Success! Thesis saved to database: " + title);

            } catch (SQLException | IllegalArgumentException e) {
                e.printStackTrace();
                System.out.println("Database error while adding thesis.");
            }
        }
        
        // 5. Redirect back to Dashboard
        response.sendRedirect("adminDashboard.jsp");
    }
}