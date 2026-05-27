package systempackage;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
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

@WebServlet("/DownloadThesisServlet")
public class DownloadThesisServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("activeUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Grab the Thesis ID from the URL
        String thesisIdStr = request.getParameter("thesisId");
        if (thesisIdStr == null || thesisIdStr.trim().isEmpty()) {
            response.sendRedirect("thesisManagement.jsp");
            return;
        }

        int thesisId = Integer.parseInt(thesisIdStr);
        String fileName = null;

        // 3. Database Operations (Get File Name & Add +1 to Count)
        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // A. Find out what the file is called
            String selectSql = "SELECT file_name FROM Thesis_Records WHERE thesis_id = ?";
            try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                selectStmt.setInt(1, thesisId);
                try (ResultSet rs = selectStmt.executeQuery()) {
                    if (rs.next()) {
                        fileName = rs.getString("file_name");
                    }
                }
            }

            // B. If a real file exists, increment the download counter!
            if (fileName != null && !fileName.equals("No file attached") && !fileName.isEmpty()) {
                String updateSql = "UPDATE Thesis_Records SET download_count = download_count + 1 WHERE thesis_id = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, thesisId);
                    updateStmt.executeUpdate();
                }
            } else {
                // Kick them back if there is no file to download
                response.sendRedirect("thesisInformation.jsp?thesisId=" + thesisId);
                return;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("thesisInformation.jsp?thesisId=" + thesisId);
            return;
        }

        // 4. Locate the Physical File on the Server
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File downloadFile = new File(uploadPath, fileName);

        if (!downloadFile.exists()) {
            System.out.println("Error: File not found on server hard drive.");
            response.sendRedirect("thesisInformation.jsp?thesisId=" + thesisId);
            return;
        }

        // 5. Force the Browser to Download the File
        // This tells the browser "Get ready to receive a PDF, don't try to render it as HTML!"
        response.setContentType("application/pdf");
        response.setContentLength((int) downloadFile.length());
        
        // "attachment" forces the save dialog box to pop up
        String headerKey = "Content-Disposition";
        String headerValue = String.format("attachment; filename=\"%s\"", fileName);
        response.setHeader(headerKey, headerValue);

        // 6. Stream the File Data to the User
        try (FileInputStream inStream = new FileInputStream(downloadFile);
             OutputStream outStream = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead = -1;
            
            while ((bytesRead = inStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
        }
    }
}