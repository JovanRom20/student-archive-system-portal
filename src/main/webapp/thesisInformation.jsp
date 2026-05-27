<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Security Check
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || "Student".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return; 
    }
    
    // Grab the ID of the thesis they clicked on
    String thesisId = request.getParameter("thesisId");
    
    // If somehow they get to this page without clicking an ID, kick them back
    if (thesisId == null || thesisId.trim().isEmpty()) {
        response.sendRedirect("thesisManagement.jsp");
        return;
    }

    // --- VARIABLES TO HOLD THE DATA ---
    String tTitle = "";
    String tAuthor = "";
    String tDept = "";
    String tDate = "";
    String tAbstract = "";
    String tKeywords = "";
    String tStatus = "";
    String tFile = "";

    // --- FETCH DATA FROM DATABASE ---
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT * FROM Thesis_Records WHERE thesis_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            // We turn the String ID into an Integer for the database
            ps.setInt(1, Integer.parseInt(thesisId));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    tTitle = rs.getString("title");
                    tAuthor = rs.getString("author");
                    tDept = rs.getString("department");
                    tAbstract = rs.getString("abstract_text");
                    tKeywords = rs.getString("keywords");
                    tStatus = rs.getString("status");
                    tFile = rs.getString("file_name");
                    
                    // Format the date nicely!
                    java.sql.Date dbDate = rs.getDate("submission_date");
                    SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
                    tDate = (dbDate != null) ? sdf.format(dbDate) : "N/A";
                } else {
                    // If the ID doesn't exist in the database, kick them back
                    response.sendRedirect("thesisManagement.jsp");
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
            background-color: #e9ecef; /* Unified background color */
            overflow-y: auto; 
            overflow-x: hidden; 
        }
        .topbar { 
            background-color: #0d3863; 
            color: white; 
            padding: 16px 30px; /* Unified padding */
            flex-shrink: 0; 
        }
        .topbar h1 { 
            font-size: 19px; /* Unified font size */
            font-weight: 600; 
        }

        /* === 3-COLUMN VIEW LAYOUT === */
        .view-container {
            display: flex; gap: 15px; padding: 15px; height: calc(100vh - 85px); /* Subtract topbar and footer */
        }
        
        .panel {
            background-color: white; border: 1px solid #d1d5da;
            display: flex; flex-direction: column;
        }
        
        .panel-header {
            padding: 15px; border-bottom: 1px solid #eee;
            color: #2ea3f2; font-weight: bold; font-size: 14px;
            display: flex; align-items: center; gap: 8px;
        }

        /* 1. Left Panel: Thesis Info */
        .col-info { flex: 1.2; overflow-y: auto; padding-bottom: 20px; }
        .info-group { padding: 15px 15px 0 15px; }
        .info-group h4 { font-size: 12px; color: #111; margin-bottom: 5px; }
        .info-group p { font-size: 12px; color: #555; line-height: 1.5; }

        /* 2. Center Panel: Document Viewer */
        .col-viewer { flex: 2.5; }
        .doc-wrapper { flex-grow: 1; padding: 20px; background-color: #f8f9fa; display: flex; flex-direction: column; }
        .doc-paper { flex-grow: 1; background-color: white; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .doc-controls {
            background-color: #7f7f7f; color: white; padding: 10px;
            display: flex; justify-content: center; align-items: center; gap: 15px; font-size: 12px;
        }
        .doc-controls input { width: 40px; text-align: center; border: none; padding: 3px; }

        /* 3. Right Panel: Actions */
        .col-actions { flex: 1; background: transparent; border: none; gap: 15px; }
        .action-box { background: white; border: 1px solid #d1d5da; padding: 15px; }
        
        .btn { width: 100%; padding: 10px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 10px; transition: 0.2s; }
        .btn-primary { background-color: #5bb4f3; border: none; color: white; }
        .btn-primary:hover { background-color: #2ea3f2; }
        .btn-outline { background-color: white; border: 1px solid #5bb4f3; color: #5bb4f3; }
        .btn-outline:hover { background-color: #f0f8ff; }

        .status-header { font-size: 12px; font-weight: bold; margin-bottom: 10px; margin-top: 5px; color: #111; }
        .status-option {
            display: flex; justify-content: space-between; align-items: center;
            padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; margin-bottom: 8px; font-size: 12px;
        }
        .status-option label { display: flex; align-items: center; gap: 8px; cursor: pointer; width: 100%; }
        
        /* Status Text Colors */
        .text-active { color: #2ecc71; font-weight: bold; }
        .text-hidden { color: #555; font-weight: bold; }
        .text-flagged { color: #e74c3c; font-weight: bold; }

        /* Global Footer */
        .app-footer {
             background-color: #1a6bba; color: white; text-align: center;
             padding: 12px; font-size: 12px;
         }
    </style>
</head>
<body>

    <div class="app-container">
        
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <img src="images/logo.jpeg" alt="FSUU Logo">
                <h2>FSUU</h2>
            </div>
            <nav class="nav-menu">
                <!-- 1. Removed 'active' from Dashboard -->
                <a href="adminDashboard.jsp" class="nav-link">
                    <img src="images/Home.jpeg" class="custom-icon" alt="Home"> Dashboard
                </a>
                
                <!-- 2. Added 'active' to Thesis Management -->
                <a href="thesisManagement.jsp" class="nav-link active">
                    <img src="images/Folder.jpeg" class="custom-icon" alt="Folder"> Thesis Management
                </a>
                
                <a href="users.jsp" class="nav-link">
                <img src="images/Users.jpeg" class="custom-icon" alt="Users"> Users
                </a>
                <a href="report.jsp" class="nav-link">
                    <img src="images/Report.jpeg" class="custom-icon" alt="Reports"> Reports
                </a>
                <a href="settings.jsp" class="nav-link">
                    <img src="images/Setting.jpeg" class="custom-icon" alt="Settings"> Settings
                </a>
                
                <a href="LogoutServlet" class="nav-link logout-link">
                    <img src="images/LogOut.jpeg" class="custom-icon" alt="Logout"> Logout
                </a>
            </nav>
        </aside>

        <!-- Main Content Area -->
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

                <!-- COLUMN 2: Document Viewer -->
                <div class="panel col-viewer">
                    <div class="panel-header"><i class="fas fa-eye"></i> Document Viewer</div>
                    
                    <div class="doc-wrapper" style="padding: 0;"> 
                        <% 
                            // Check if a file actually exists for this thesis
                            if (tFile != null && !tFile.trim().isEmpty() && !tFile.equals("No file attached")) { 
                        %>
                            <iframe src="uploads/<%= tFile %>" width="100%" height="100%" style="border: none;"></iframe>
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

                <!-- COLUMN 3: Actions & Status -->
                <div class="panel col-actions">
                    
                    <!-- Action Buttons -->
                    <div class="action-box">
                        <div class="panel-header" style="border:none; padding:0 0 15px 0;"><i class="fas fa-cog"></i> Actions</div>
                        <a href="DownloadThesisServlet?thesisId=<%= thesisId %>" class="btn btn-primary" style="text-decoration: none;">
                        <i class="fas fa-download"></i> Download Document</a>
                        <a href="editThesis.jsp?thesisId=<%= thesisId %>" class="btn btn-outline" style="text-decoration: none;">
                        <i class="fas fa-edit"></i> Edit Thesis</a>
                    </div>

                    <!-- Status Control Form -->
                    <div class="action-box">
                        <div class="status-header">Status Control</div>
                        
                        <!-- Notice how this perfectly connects to the Servlet we just built! -->
                        <form action="UpdateStatusServlet" method="POST">
                            <input type="hidden" name="thesisId" value="<%= thesisId %>">
                            
                            <div class="status-option">
                                <label><i class="fas fa-check-circle text-active"></i> Active</label>
                                <input type="radio" name="newStatus" value="Active" <%= "Active".equals(tStatus) ? "checked" : "" %>>
                            </div>
                            
                            <div class="status-option">
                                <label><i class="fas fa-eye-slash text-hidden"></i> Hidden</label>
                                <input type="radio" name="newStatus" value="Hidden" <%= "Hidden".equals(tStatus) ? "checked" : "" %>>
                            </div>
                            
                            <div class="status-option">
                                <label><i class="fas fa-flag text-flagged"></i> Flagged</label>
                                <input type="radio" name="newStatus" value="Flagged" <%= "Flagged".equals(tStatus) ? "checked" : "" %>>
                            </div>
                            
                            <button type="submit" class="btn btn-primary" style="margin-top: 15px;">Update Status</button>
                        </form>
                    </div>
                    
                </div>

            </div>
        </main>
    </div>
    <!-- Global Footer moved OUTSIDE app-container to span the full width! -->
    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

</body>
</html>