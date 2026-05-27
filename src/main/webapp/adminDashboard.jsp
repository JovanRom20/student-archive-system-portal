<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

    // If there is no active user, kick them out
    if (currentUser == null) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return; 
    }

    // --- DASHBOARD STATISTICS ---
    int totalThesis = 0;
    int hiddenThesis = 0;
    int flaggedThesis = 0;

    try (Connection conn = DatabaseConnection.getConnection()) {
        
        // 1. Count ALL Thesis
        String sqlTotal = "SELECT COUNT(*) FROM Thesis_Records";
        try (PreparedStatement psTotal = conn.prepareStatement(sqlTotal);
             ResultSet rsTotal = psTotal.executeQuery()) {
            if (rsTotal.next()) totalThesis = rsTotal.getInt(1);
        }

        // 2. Count HIDDEN Thesis
        String sqlHidden = "SELECT COUNT(*) FROM Thesis_Records WHERE status = 'Hidden'";
        try (PreparedStatement psHidden = conn.prepareStatement(sqlHidden);
             ResultSet rsHidden = psHidden.executeQuery()) {
            if (rsHidden.next()) hiddenThesis = rsHidden.getInt(1);
        }

        // 3. Count FLAGGED Thesis
        String sqlFlagged = "SELECT COUNT(*) FROM Thesis_Records WHERE status = 'Flagged'";
        try (PreparedStatement psFlagged = conn.prepareStatement(sqlFlagged);
             ResultSet rsFlagged = psFlagged.executeQuery()) {
            if (rsFlagged.next()) flaggedThesis = rsFlagged.getInt(1);
        }

    } catch (SQLException e) {
        e.printStackTrace();
        System.out.println("Error loading dashboard stats.");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - FSUU Thesis Archive</title>
    <!-- FontAwesome for the Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* === RESET & BASE === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; flex-direction: column; min-height: 100vh; background-color: #e9ecef; }

        /* === LAYOUT WRAPPERS === */
        .app-container { display: flex; flex-grow: 1; overflow: hidden; }
        
        /* === SIDEBAR === */
        .sidebar {
            width: 260px;
            background-color: #0b2e4f;
            color: white;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .sidebar-brand {
            display: flex; align-items: center; gap: 15px; padding: 25px 20px;
        }
        .sidebar-brand img { width: 45px; height: 45px; object-fit: contain; }
        .sidebar-brand h2 { font-size: 22px; font-weight: 600; letter-spacing: 1px; }

        .nav-menu { display: flex; flex-direction: column; padding: 10px 0; flex-grow: 1; }
        .nav-link {
            padding: 16px 25px; color: #a3c2e0; text-decoration: none;
            display: flex; align-items: center; gap: 15px;
            font-size: 15px; font-weight: 500; transition: 0.3s;
        }
        /* Styles your custom image icons to fit perfectly */
        .nav-link .custom-icon { 
            width: 20px; 
            height: 20px; 
            object-fit: contain; 
        }
        .nav-link:hover { background-color: rgba(255, 255, 255, 0.05); color: white; }
        .nav-link.active { background-color: #1a426b; color: white; border-left: 4px solid #2ea3f2; }
        
        .logout-link { margin-top: auto; margin-bottom: 20px; }

        /* === MAIN CONTENT === */
        .main-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        .topbar {
            background-color: #0d3863;
            color: white;
            padding: 20px 30px;
        }
        .topbar h1 { font-size: 20px; font-weight: 600; }

        /* Banner & Overlapping Cards */
        .dashboard-header { position: relative; }
        .banner-img {
            width: 100%; height: 200px;
            background-image: url('images/background.jpeg'); /* Make sure this path is correct */
            background-size: cover; background-position: center;
        }

        .stats-container {
            display: flex; gap: 20px; padding: 0 30px;
            margin-top: -40px; /* Pulls cards up over the banner */
            position: relative; z-index: 2;
        }

        .stat-card {
            background-color: white; padding: 20px; border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            display: flex; align-items: center; justify-content: center; gap: 15px;
        }
        .welcome-card { flex: 2; flex-direction: column; align-items: center; text-align: center; justify-content: center; gap: 5px; }
        .welcome-card h2 { font-size: 22px; color: #111; }
        .welcome-card p { font-size: 14px; font-weight: 600; color: #333; }
        
        .data-card { flex: 1; flex-direction: column; text-align: center; }
        .data-card .icon-box {
            width: 35px; height: 35px; border-radius: 6px;
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 16px; margin-bottom: 5px;
        }
        .icon-blue { background-color: #2ea3f2; }
        .icon-dark { background-color: #0b2e4f; }
        .data-card h3 { font-size: 20px; color: #111; }
        .data-card p { font-size: 11px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; }

        /* === DATA SECTIONS === */
        .content-section { padding: 30px; display: flex; flex-direction: column; gap: 25px; }
        
        .panel {
            background-color: white; border-radius: 8px; padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .panel-title { font-size: 14px; font-weight: bold; color: #111; margin-bottom: 15px; }

        /* Table Styles */
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #1a6bba; color: white; padding: 12px 15px; text-align: left; font-size: 13px; font-weight: 500; }
        th:first-child { border-top-left-radius: 6px; }
        th:last-child { border-top-right-radius: 6px; text-align: center; }
        td { padding: 12px 15px; border-bottom: 1px solid #eee; font-size: 13px; color: #333; }
        
        /* === STATUS COLORS === */
        .status-active { color: #2ecc71; font-weight: 600; }
        .status-flagged { color: #e74c3c; font-weight: 600; }
        .status-hidden { color: #555555; font-weight: 600; }

        /* === ACTION BUTTONS === */
        .actions { display: flex; justify-content: flex-start; gap: 8px; }
        
        .btn-action {
            background-color: #f0f8ff; border: 1px solid #a3c2e0; color: #2ea3f2;
            width: 32px; height: 32px; border-radius: 4px; cursor: pointer;
            display: flex; align-items: center; justify-content: center; transition: 0.2s;
        }
        .btn-action:hover { background-color: #2ea3f2; color: white; }
        
        .btn-action.edit { color: #555; border-color: #ccc; background-color: #f9f9f9; }
        .btn-action.edit:hover { background-color: #555; color: white; }

        /* Timeline Styles */
        .timeline { 
            list-style: none; 
            padding-left: 0; 
            margin-left: 20px; 
            border-left: 2px dashed #b0b0b0; /* Lightened to match Figma */
        }
        .timeline li { 
            position: relative; 
            margin-bottom: 20px; /* Increased spacing between items */
            padding-left: 25px; 
            font-size: 13px; /* Slightly larger text to match Figma */
            color: #111; 
        }
        .timeline li::before {
            content: ''; 
            position: absolute; 
            left: -8px; /* Perfect mathematical center for a 10px dot on a 2px border */
            top: 2px; /* Aligns the dot with the middle of the text line */
            width: 10px; 
            height: 10px; 
            background-color: #e9ecef; /* Matches background to make it look 'hollow' */
            border: 2px solid #b0b0b0; 
            border-radius: 50%;
        }

        /* === FOOTER === */
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
                <a href="adminDashboard.jsp" class="nav-link active">
                    <img src="images/Home.jpeg" class="custom-icon" alt="Home"> Dashboard
                </a>
                <a href="thesisManagement.jsp" class="nav-link">
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

            <div class="dashboard-header">
                <div class="banner-img"></div>
                
                <div class="stats-container">
                    <div class="stat-card welcome-card">
                        <h2>Welcome,</h2>
                        <p><%= currentUser != null ? currentUser : "Admin" %> | <%= userRole != null ? userRole : "Administrator" %></p>
                    </div>
                    
                    <div class="stat-card data-card">
                        <div class="icon-box icon-blue"><i class="fas fa-file-alt"></i></div>
                        <h3><%= totalThesis %></h3>
                        <p>Total Thesis</p>
                    </div>
                    
                    <div class="stat-card data-card">
                        <div class="icon-box icon-blue"><i class="fas fa-eye-slash"></i></div>
                        <h3><%= hiddenThesis %></h3>
                        <p>Hidden</p>
                    </div>
                    
                    <div class="stat-card data-card">
                        <div class="icon-box icon-dark"><i class="fas fa-times"></i></div>
                        <h3><%= flaggedThesis %></h3>
                        <p>Flagged</p>
                    </div>
                </div>
            </div>

            <div class="content-section">

                <!-- Data Table Panel -->
                <div class="panel">
                    <div class="panel-title">Recent Thesis Submissions</div>
                    <table>
                        <thead>
                            <tr>
                                <th>Thesis Title</th>
                                <th>Author(s)</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DatabaseConnection.getConnection()) {
                                    String sqlRecent = "SELECT thesis_id, title, author, submission_date, status FROM Thesis_Records ORDER BY thesis_id DESC LIMIT 3";
                                    try (PreparedStatement ps = conn.prepareStatement(sqlRecent);
                                         ResultSet rs = ps.executeQuery()) {
                                        
                                        while (rs.next()) {
                                            String tId = rs.getString("thesis_id");
                                            String tTitle = rs.getString("title");
                                            String tAuthor = rs.getString("author");
                                            java.sql.Date tDate = rs.getDate("submission_date");
                                            String tStatus = rs.getString("status");
                                            
                                            String statusClass = "status-hidden"; 
                                            if ("Active".equals(tStatus)) statusClass = "status-active";
                                            else if ("Flagged".equals(tStatus)) statusClass = "status-flagged";
                            %>
                            <tr>
                                <td><%= tTitle %></td>
                                <td><%= tAuthor %></td>
                                <td><%= tDate != null ? tDate.toString() : "N/A" %></td>
                                <td class="<%= statusClass %>"><%= tStatus %></td>
                                <td class="actions">
                                    <form action="thesisInformation.jsp" method="GET" style="margin: 0;">
                                        <input type="hidden" name="thesisId" value="<%= tId %>">
                                        <button type="submit" class="btn-action" title="View Information">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </form>
                                    <form action="editThesis.jsp" method="GET" style="margin: 0;">
                                        <input type="hidden" name="thesisId" value="<%= tId %>">
                                        <button type="submit" class="btn-action edit" title="Edit Thesis">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                        } 
                                    }
                                } catch (SQLException e) {
                                    out.println("<tr><td colspan='5'>Error loading recent submissions: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <div class="panel">
                    <div class="panel-title">Recent Activity Timeline</div>
                    <ul class="timeline">
                        <%
                            try (Connection conn = DatabaseConnection.getConnection()) {
                                // We are now selecting 'uploaded_by' instead of 'author'
                                String sqlTimeline = "SELECT title, uploaded_by, submission_date FROM Thesis_Records ORDER BY thesis_id DESC LIMIT 3";
                                try (PreparedStatement ps = conn.prepareStatement(sqlTimeline);
                                     ResultSet rs = ps.executeQuery()) {
                                    
                                    boolean hasActivity = false;
                                    // This magically formats the SQL date to match your Figma design!
                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM, yyyy");

                                    while (rs.next()) {
                                        hasActivity = true;
                                        String tTitle = rs.getString("title");
                                        String tUploader = rs.getString("uploaded_by"); // Grabbing the System User
                                        java.sql.Date tDate = rs.getDate("submission_date");
                                        String formattedDate = (tDate != null) ? sdf.format(tDate) : "Unknown Date";
                        %>
                            <li><%= formattedDate %> - <%= tUploader %> submitted "<%= tTitle %>"</li>
                        <%
                                    }
                                    
                                    if (!hasActivity) {
                                        out.println("<li>No recent activity.</li>");
                                    }
                                }
                            } catch (SQLException e) {
                                out.println("<li>Error loading timeline.</li>");
                            }
                        %>
                    </ul>
                </div>

            </div>
        </main>
    </div>

    <!-- Global Footer -->
    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

</body>
</html>