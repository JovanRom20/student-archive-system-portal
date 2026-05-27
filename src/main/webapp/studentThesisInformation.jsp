<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    
    // If no one is logged in, kick them back to the student login
    if (currentUser == null) {
        response.sendRedirect("loginStudent.jsp?error=unauthorized");
        return; 
    }
    
    String thesisId = request.getParameter("thesisId");
    
    if (thesisId == null || thesisId.trim().isEmpty()) {
        response.sendRedirect("studentThesisManagement.jsp");
        return;
    }

    // --- VARIABLES TO HOLD THE DATA ---
    String tTitle = "";
    String tAuthor = "";
    String tDept = "";
    String tDate = "";
    String tAbstract = "";
    String tKeywords = "";
    String tFile = "";

    // --- FETCH DATA FROM DATABASE ---
    try (Connection conn = DatabaseConnection.getConnection()) {
        // SECURITY UPGRADE: We added "AND status = 'Active'" to physically block students from viewing hidden files via URL
        String sql = "SELECT * FROM Thesis_Records WHERE thesis_id = ? AND status = 'Active'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(thesisId));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    tTitle = rs.getString("title");
                    tAuthor = rs.getString("author");
                    tDept = rs.getString("department");
                    tAbstract = rs.getString("abstract_text");
                    tKeywords = rs.getString("keywords");
                    tFile = rs.getString("file_name");
                    
                    java.sql.Date dbDate = rs.getDate("submission_date");
                    SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
                    tDate = (dbDate != null) ? sdf.format(dbDate) : "N/A";
                } else {
                    // If the ID doesn't exist OR it isn't Active, kick them back
                    response.sendRedirect("studentThesisManagement.jsp");
                    return;
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Thesis Details - FSUU Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* === RESET & BASE === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; flex-direction: column; height: 100vh; background-color: #e9ecef; overflow: hidden; }

        /* === LAYOUT WRAPPERS === */
        .app-container { display: flex; flex-grow: 1; overflow: hidden; }
        
        /* === SIDEBAR === */
        .sidebar { width: 260px; background-color: #0b2e4f; color: white; display: flex; flex-direction: column; flex-shrink: 0; }
        .sidebar-brand { display: flex; align-items: center; gap: 15px; padding: 25px 20px; }
        .sidebar-brand img { width: 45px; height: 45px; object-fit: contain; }
        .sidebar-brand h2 { font-size: 22px; font-weight: 600; letter-spacing: 1px; }

        .nav-menu { display: flex; flex-direction: column; padding: 10px 0; flex-grow: 1; }
        .nav-link {
            padding: 16px 25px; color: #a3c2e0; text-decoration: none;
            display: flex; align-items: center; gap: 15px; font-size: 15px; font-weight: 500; transition: 0.3s;
        }
        .nav-link .custom-icon { width: 20px; height: 20px; object-fit: contain; }
        .nav-link:hover { background-color: rgba(255, 255, 255, 0.05); color: white; }
        .nav-link.active { background-color: #1a426b; color: white; border-left: 4px solid #2ea3f2; }
        .logout-link { margin-top: auto; margin-bottom: 20px; }

        /* === MAIN CONTENT & TOP BAR === */
        .main-content { 
            flex-grow: 1; 
            display: flex; 
            flex-direction: column; 
            background-color: #e9ecef; 
            overflow-y: auto; 
            overflow-x: hidden; 
        }
        .topbar { background-color: #0d3863; color: white; padding: 16px 30px; flex-shrink: 0; }
        .topbar h1 { font-size: 19px; font-weight: 600; }

        /* === 2-COLUMN VIEW LAYOUT (Student Mode) === */
        .view-container {
            display: flex; gap: 15px; padding: 15px; height: calc(100vh - 85px);
        }
        
        .panel {
            background-color: white; border: 1px solid #d1d5da;
            display: flex; flex-direction: column; border-radius: 4px;
        }
        
        .panel-header {
            padding: 15px; border-bottom: 1px solid #eee;
            color: #2ea3f2; font-weight: bold; font-size: 14px;
            display: flex; align-items: center; gap: 8px;
        }

        /* 1. Left Panel: Thesis Info */
        .col-info { flex: 1.2; overflow-y: auto; padding-bottom: 20px; }
        .info-group { padding: 15px 15px 0 15px; }
        .info-group h4 { font-size: 12px; color: #111; margin-bottom: 5px; font-weight: bold; }
        .info-group p { font-size: 12px; color: #555; line-height: 1.5; }

        /* 2. Right Panel: Document Viewer */
        .col-viewer { flex: 2.5; }
        .doc-wrapper { flex-grow: 1; padding: 20px; background-color: #f8f9fa; display: flex; flex-direction: column; }

        /* Global Footer */
        .app-footer { background-color: #1a6bba; color: white; text-align: center; padding: 12px; font-size: 12px; }
    </style>
</head>
<body>

    <div class="app-container">
        
        <aside class="sidebar">
            <div class="sidebar-brand">
                <img src="images/logo.jpeg" alt="FSUU Logo">
                <h2>FSUU</h2>
            </div>
            <nav class="nav-menu">
                <a href="studentDashboard.jsp" class="nav-link">
                    <img src="images/Home.jpeg" class="custom-icon" alt="Home"> Dashboard
                </a>
                
                <a href="studentThesisManagement.jsp" class="nav-link active">
                    <img src="images/Folder.jpeg" class="custom-icon" alt="Folder"> Thesis Management
                </a>
                
                <a href="settings.jsp" class="nav-link">
                    <img src="images/Setting.jpeg" class="custom-icon" alt="Settings"> Settings
                </a>
                
                <a href="LogoutServlet" class="nav-link logout-link">
                    <img src="images/LogOut.jpeg" class="custom-icon" alt="Logout"> Logout
                </a>
            </nav>
        </aside>

        <main class="main-content">
            <header class="topbar">
                <h1>Thesis Archive Management System</h1>
            </header>

            <div class="view-container">
                
                <div class="panel col-info">
                    <div class="panel-header"><i class="fas fa-file-alt"></i> Thesis Information</div>
                    
                    <div class="info-group">
                        <h4>Thesis Title</h4>
                        <p><%= tTitle != null ? tTitle : "No title provided" %></p>
                    </div>
                    <div class="info-group">
                        <h4>Author Name</h4>
                        <p><%= tAuthor != null ? tAuthor : "Unknown Author" %></p>
                    </div>
                    <div class="info-group">
                        <h4>Department</h4>
                        <p><%= tDept != null && !tDept.isEmpty() ? tDept : "Not specified" %></p>
                    </div>
                    <div class="info-group">
                        <h4>Date of Submission</h4>
                        <p><%= tDate %></p>
                    </div>
                    <div class="info-group">
                        <h4>Abstract</h4>
                        <p style="text-align: justify;">
                            <%= tAbstract != null && !tAbstract.isEmpty() ? tAbstract : "No abstract available for this thesis." %>
                        </p>
                    </div>
                    <div class="info-group">
                        <h4>Keywords</h4>
                        <p><%= tKeywords != null && !tKeywords.isEmpty() ? tKeywords : "None" %></p>
                    </div>
                </div>

                <div class="panel col-viewer">
                    <div class="panel-header"><i class="fas fa-eye"></i> Document Viewer</div>
                    
                    <div class="doc-wrapper" style="padding: 0;"> 
                        <% 
                            if (tFile != null && !tFile.trim().isEmpty() && !tFile.equals("No file attached")) { 
                        %>
                            <iframe src="uploads/<%= tFile %>#toolbar=0" width="100%" height="100%" style="border: none;"></iframe>
                        <% 
                            } else { 
                        %>
                            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: #888; background-color: #f8f9fa;">
                                <i class="fas fa-file-pdf" style="font-size: 48px; margin-bottom: 15px; color: #ccc;"></i>
                                <h3>No Document Available</h3>
                                <p style="font-size: 13px; margin-top: 5px;">A file was not attached to this thesis record.</p>
                            </div>
                        <% 
                            } 
                        %>
                    </div>
                </div>
                
                </div>
        </main>
    </div>
    
    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

</body>
</html>