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

@WebServlet("/EditThesisServlet")
// The magic tag for file uploads is still required!
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 25,
    maxRequestSize = 1024 * 1024 * 30
)
public class EditThesisServlet extends HttpServlet {
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

        // 2. Extract Text Data AND the Thesis ID!
        String thesisIdStr = request.getParameter("thesisId");
        String title = request.getParameter("title");
        String department = request.getParameter("department");
        String author = request.getParameter("author");
        String submissionDateStr = request.getParameter("submissionDate");
        String abstractText = request.getParameter("abstractText");
        String keywords = request.getParameter("keywords");

        // Kick them out if the ID is missing
        if (thesisIdStr == null || title == null) {
            response.sendRedirect("thesisManagement.jsp");
            return;
        }

        int thesisId = Integer.parseInt(thesisIdStr);

        // 3. Handle OPTIONAL File Upload
        Part filePart = request.getPart("thesisFile");
        String newFileName = null;

        // Only do file stuff if they actually attached a new file
        if (filePart != null && filePart.getSize() > 0) {
            newFileName = filePart.getSubmittedFileName().replaceAll("\\s+", "_"); 
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            Path filePath = Paths.get(uploadPath, newFileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
                System.out.println("New file uploaded and replaced: " + newFileName);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // 4. Update the Database
        try (Connection conn = DatabaseConnection.getConnection()) {
            Date subDate = Date.valueOf(submissionDateStr); 
            String sql;
            
            // SMART LOGIC: Change the SQL query depending on if a file was uploaded!
            if (newFileName != null) {
                // Update text AND the file name
                sql = "UPDATE Thesis_Records SET title=?, department=?, author=?, submission_date=?, abstract_text=?, keywords=?, file_name=? WHERE thesis_id=?";
            } else {
                // Update text ONLY (leaves the old file name alone!)
                sql = "UPDATE Thesis_Records SET title=?, department=?, author=?, submission_date=?, abstract_text=?, keywords=? WHERE thesis_id=?";
            }
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, title);
                pstmt.setString(2, department);
                pstmt.setString(3, author);
                pstmt.setDate(4, subDate);
                pstmt.setString(5, abstractText);
                pstmt.setString(6, keywords);
                
                if (newFileName != null) {
                    pstmt.setString(7, newFileName);
                    pstmt.setInt(8, thesisId);
                } else {
                    pstmt.setInt(7, thesisId);
                }
                
                pstmt.executeUpdate();
                System.out.println("Success! Thesis updated.");
            }
        } catch (SQLException | IllegalArgumentException e) {
            e.printStackTrace();
            System.out.println("Database error while updating thesis.");
        }
        
        // 5. Redirect back to the Information page so they can see their updates instantly!
        response.sendRedirect("thesisInformation.jsp?thesisId=" + thesisId);
    }
}