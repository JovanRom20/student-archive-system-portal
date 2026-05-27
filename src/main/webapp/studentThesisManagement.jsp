<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

    // If there is no active user, kick them out to the student login
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
    <title>Thesis Management - FSUU Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* === RESET & BASE === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; flex-direction: column; min-height: 100vh; background-color: #e9ecef; }

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
        .topbar { 
            background-color: #0d3863; 
            color: white; 
            padding: 16px 30px; 
            flex-shrink: 0; 
        }
        .topbar h1 { font-size: 19px; font-weight: 600; }

        /* === MANAGEMENT PANEL === */
        .management-wrapper { padding: 30px; flex-grow: 1; }
        .management-panel {
            background-color: white; border-radius: 12px; padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); min-height: 100%;
        }

        /* Controls (Search Only) */
        .controls-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        
        .search-container { position: relative; width: 350px; }
        .search-container i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #888; }
        .search-container input {
            width: 100%; padding: 12px 15px 12px 40px;
            border: 1px solid #d1d5da; border-radius: 6px; font-size: 14px; outline: none; transition: 0.3s;
        }
        .search-container input:focus { border-color: #2ea3f2; }

        /* === TABLE STYLES === */
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #1a6bba; color: white; padding: 14px 15px; text-align: left; font-size: 13px; font-weight: 600; }
        th:first-child { border-top-left-radius: 6px; }
        th:last-child { border-top-right-radius: 6px; text-align: center; }
        td { padding: 14px 15px; border-bottom: 1px solid #eee; font-size: 13px; color: #333; }
        
        .actions { display: flex; justify-content: center; gap: 8px; }
        .btn-action {
            background-color: #f0f8ff; border: 1px solid #a3c2e0; color: #2ea3f2;
            width: 32px; height: 32px; border-radius: 4px; cursor: pointer;
            display: flex; align-items: center; justify-content: center; transition: 0.2s;
        }
        .btn-action:hover { background-color: #2ea3f2; color: white; }

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

            <div class="management-wrapper">
                <div class="management-panel">
                    
                    <div class="controls-header">
                        <form action="studentThesisManagement.jsp" method="GET" style="margin: 0; width: 100%;">
                            <div class="search-container">
                                <i class="fas fa-search"></i>
                                <input type="text" name="q" placeholder="Search by Title, or Author..." 
                                       value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                            </div>
                        </form>
                        </div>

                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Date</th>
                                <th style="text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                String searchParam = request.getParameter("q");
                                boolean hasSearch = (searchParam != null && !searchParam.trim().isEmpty());

                                try (Connection conn = DatabaseConnection.getConnection()) {
                                    String sql;
                                    
                                    // SECURITY UPGRADE: Both queries force "status = 'Active'"
                                    if (hasSearch) {
                                        sql = "SELECT thesis_id, title, author, submission_date " +
                                              "FROM Thesis_Records " +
                                              "WHERE (title ILIKE ? OR author ILIKE ?) AND status = 'Active' " +
                                              "ORDER BY thesis_id DESC";
                                    } else {
                                        sql = "SELECT thesis_id, title, author, submission_date FROM Thesis_Records WHERE status = 'Active' ORDER BY thesis_id DESC";
                                    }

                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        
                                        if (hasSearch) {
                                            String wildcardSearch = "%" + searchParam.trim() + "%";
                                            ps.setString(1, wildcardSearch); 
                                            ps.setString(2, wildcardSearch); 
                                        }

                                        try (ResultSet rs = ps.executeQuery()) {
                                            
                                            SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy");
                                            boolean foundResults = false;

                                            while (rs.next()) {
                                                foundResults = true;
                                                String tId = rs.getString("thesis_id");
                                                String tTitle = rs.getString("title");
                                                String tAuthor = rs.getString("author");
                                                java.sql.Date tDate = rs.getDate("submission_date");
                                                String formattedDate = (tDate != null) ? sdf.format(tDate) : "N/A";
                            %>
                            <tr>
                                <td><%= tTitle %></td>
                                <td><%= tAuthor %></td>
                                <td><%= formattedDate %></td>
                                <td class="actions">
                                    <form action="studentThesisInformation.jsp" method="GET" style="margin: 0;">
                                        <input type="hidden" name="thesisId" value="<%= tId %>">
                                        <button type="submit" class="btn-action" title="View Information">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </form>
                                    </td>
                            </tr>
                            <%
                                            } 
                                            
                                            if (!foundResults) {
                                                out.println("<tr><td colspan='4' style='text-align:center; padding: 30px;'>No active thesis records found matching your search.</td></tr>");
                                            }
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<tr><td colspan='4' style='text-align:center;'>Error loading thesis records.</td></tr>");
                                    e.printStackTrace();
                                }
                            %>
                        </tbody>
                    </table>

                </div>
            </div>

        </main>
    </div>

    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

</body>
</html>