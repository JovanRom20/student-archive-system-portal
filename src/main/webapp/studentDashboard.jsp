<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

    // If there is no active user, kick them out
    if (currentUser == null) {
        response.sendRedirect("loginStudent.jsp?error=unauthorized");
        return; 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - FSUU Thesis Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* === RESET & BASE === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; flex-direction: column; min-height: 100vh; background-color: #e9ecef; }

        /* === LAYOUT WRAPPERS === */
        .app-container { display: flex; flex-grow: 1; overflow: hidden; }
        
        /* === SIDEBAR === */
        .sidebar {
            width: 260px; background-color: #0b2e4f; color: white;
            display: flex; flex-direction: column; flex-shrink: 0;
        }
        .sidebar-brand { display: flex; align-items: center; gap: 15px; padding: 25px 20px; }
        .sidebar-brand img { width: 45px; height: 45px; object-fit: contain; }
        .sidebar-brand h2 { font-size: 22px; font-weight: 600; letter-spacing: 1px; }

        .nav-menu { display: flex; flex-direction: column; padding: 10px 0; flex-grow: 1; }
        .nav-link {
            padding: 16px 25px; color: #a3c2e0; text-decoration: none;
            display: flex; align-items: center; gap: 15px;
            font-size: 15px; font-weight: 500; transition: 0.3s;
        }
        .nav-link .custom-icon { width: 20px; height: 20px; object-fit: contain; }
        .nav-link:hover { background-color: rgba(255, 255, 255, 0.05); color: white; }
        .nav-link.active { background-color: #1a426b; color: white; border-left: 4px solid #2ea3f2; }
        .logout-link { margin-top: auto; margin-bottom: 20px; }

        /* === MAIN CONTENT === */
        .main-content { flex-grow: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { background-color: #0d3863; color: white; padding: 20px 30px; }
        .topbar h1 { font-size: 20px; font-weight: 600; }

        /* Banner & Overlapping Cards */
        .dashboard-header { position: relative; }
        .banner-img {
            width: 100%; height: 200px;
            background-image: url('images/background.jpeg'); 
            background-size: cover; background-position: center;
        }

        .stats-container {
            display: flex; gap: 20px; padding: 0 30px;
            margin-top: -40px; /* Pulls cards up over the banner */
            position: relative; z-index: 2;
        }

        /* Adjusted Welcome Card for Student Dashboard */
        .welcome-card { 
            background-color: white; padding: 20px 30px; border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            display: flex; flex-direction: column; align-items: center; 
            text-align: center; justify-content: center; gap: 5px;
            min-width: 300px; /* Keeps it perfectly sized on the left */
        }
        .welcome-card h2 { font-size: 22px; color: #111; }
        .welcome-card p { font-size: 14px; font-weight: 600; color: #333; }

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
        th:last-child { border-top-right-radius: 6px; }
        td { padding: 12px 15px; border-bottom: 1px solid #eee; font-size: 13px; color: #333; }
        
        /* Timeline Styles */
        .timeline { 
            list-style: none; padding-left: 0; margin-left: 20px; 
            border-left: 2px dashed #b0b0b0; 
        }
        .timeline li { 
            position: relative; margin-bottom: 20px; padding-left: 25px; 
            font-size: 13px; color: #111; 
        }
        .timeline li::before {
            content: ''; position: absolute; left: -8px; top: 2px; 
            width: 10px; height: 10px; background-color: #e9ecef; 
            border: 2px solid #b0b0b0; border-radius: 50%;
        }

        /* === FOOTER === */
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
                <a href="studentDashboard.jsp" class="nav-link active">
                    <img src="images/Home.jpeg" class="custom-icon" alt="Home"> Dashboard
                </a>
                <a href="studentThesisManagement.jsp" class="nav-link">
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

            <div class="dashboard-header">
                <div class="banner-img"></div>
                
                <div class="stats-container">
                    <div class="welcome-card">
                        <h2>Welcome,</h2>
                        <p><%= currentUser != null ? currentUser : "Student" %> | <%= userRole != null ? userRole : "Student" %></p>
                    </div>
                    </div>
            </div>

            <div class="content-section">

                <div class="panel">
                    <div class="panel-title">Recent Thesis Submissions</div>
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DatabaseConnection.getConnection()) {
                                    // Only show Active theses to students!
                                    String sqlRecent = "SELECT title, author, submission_date FROM Thesis_Records WHERE status = 'Active' ORDER BY thesis_id DESC LIMIT 3";
                                    try (PreparedStatement ps = conn.prepareStatement(sqlRecent);
                                         ResultSet rs = ps.executeQuery()) {
                                        
                                        boolean hasRecords = false;
                                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM d, yyyy");

                                        while (rs.next()) {
                                            hasRecords = true;
                                            String tTitle = rs.getString("title");
                                            String tAuthor = rs.getString("author");
                                            java.sql.Date tDate = rs.getDate("submission_date");
                                            String formattedDate = (tDate != null) ? sdf.format(tDate) : "N/A";
                            %>
                            <tr>
                                <td><%= tTitle %></td>
                                <td><%= tAuthor %></td>
                                <td><%= formattedDate %></td>
                            </tr>
                            <%
                                        }
                                        if (!hasRecords) {
                                            out.println("<tr><td colspan='3' style='text-align: center;'>No active thesis records found.</td></tr>");
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<tr><td colspan='3'>Error loading recent submissions.</td></tr>");
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
                                // Pulling recent active records to simulate the timeline design
                                String sqlTimeline = "SELECT title, submission_date FROM Thesis_Records WHERE status = 'Active' ORDER BY thesis_id DESC LIMIT 3";
                                try (PreparedStatement ps = conn.prepareStatement(sqlTimeline);
                                     ResultSet rs = ps.executeQuery()) {
                                    
                                    boolean hasActivity = false;
                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM, yyyy");

                                    while (rs.next()) {
                                        hasActivity = true;
                                        String tTitle = rs.getString("title");
                                        java.sql.Date tDate = rs.getDate("submission_date");
                                        String formattedDate = (tDate != null) ? sdf.format(tDate) : "Unknown Date";
                        %>
                            <li><%= formattedDate %> - You opened "<%= tTitle %>"</li>
                        <%
                                    }
                                    
                                    if (!hasActivity) {
                                        out.println("<li>No recent activity to display.</li>");
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

    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

</body>
</html>