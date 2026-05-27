<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

    // Only Admins should ideally see the user management page
    if (currentUser == null || "Student".equals(userRole)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return; 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - FSUU Archive</title>
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
        .topbar h1 { 
            font-size: 19px; 
            font-weight: 600; 
        }

        /* === MANAGEMENT PANEL === */
        .management-wrapper { padding: 30px; flex-grow: 1; }
        .management-panel {
            background-color: white; border-radius: 12px; padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); min-height: 100%;
        }

        /* Controls (Search & Add Button) */
        .controls-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        
        .search-container { position: relative; width: 350px; }
        .search-container i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #888; }
        .search-container input {
            width: 100%; padding: 12px 15px 12px 40px;
            border: 1px solid #d1d5da; border-radius: 6px; font-size: 14px; outline: none; transition: 0.3s;
        }
        .search-container input:focus { border-color: #2ea3f2; }

        .btn-add {
            background-color: #2ea3f2; color: white; padding: 12px 20px; border: none; text-decoration: none;
            border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer;
            display: flex; align-items: center; gap: 8px; transition: 0.3s;
        }
        .btn-add:hover { background-color: #1c8cd6; }

        /* === TABLE STYLES === */
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #1a6bba; color: white; padding: 14px 15px; text-align: left; font-size: 13px; font-weight: 600; }
        th:first-child { border-top-left-radius: 6px; }
        th:last-child { border-top-right-radius: 6px; text-align: center; }
        td { padding: 14px 15px; border-bottom: 1px solid #eee; font-size: 13px; color: #333; }
        
        /* Specific User Status Colors (From Figma) */
        .status-user-active { color: #2ecc71; font-weight: 600; display: flex; align-items: center; gap: 6px; }
        .status-user-inactive { color: #e74c3c; font-weight: 600; display: flex; align-items: center; gap: 6px; }

        .actions { display: flex; justify-content: center; gap: 8px; }
        .btn-action {
            background-color: #f0f8ff; border: 1px solid #a3c2e0; color: #2ea3f2;
            width: 32px; height: 32px; border-radius: 4px; cursor: pointer;
            display: flex; align-items: center; justify-content: center; transition: 0.2s;
        }
        
        /* Specific Edit & Delete buttons */
        .btn-action.edit { color: #555; border-color: #ccc; background-color: #f9f9f9; }
        .btn-action.edit:hover { background-color: #555; color: white; border-color: #555; }
        
        .btn-action.delete { color: #e74c3c; border-color: #f5b7b1; background-color: #fdedec; }
        .btn-action.delete:hover { background-color: #e74c3c; color: white; border-color: #e74c3c; }

        /* === FOOTER === */
        .app-footer { background-color: #1a6bba; color: white; text-align: center; padding: 12px; font-size: 12px; }
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
                <a href="adminDashboard.jsp" class="nav-link">
                    <img src="images/Home.jpeg" class="custom-icon" alt="Home"> Dashboard
                </a>
                
                <a href="thesisManagement.jsp" class="nav-link">
                    <img src="images/Folder.jpeg" class="custom-icon" alt="Folder"> Thesis Management
                </a>
                
                <!-- Users Tab is now ACTIVE -->
                <a href="users.jsp" class="nav-link active">
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

            <div class="management-wrapper">
                <div class="management-panel">
                    
                    <!-- Top Controls -->
                    <div class="controls-header">
                        <div class="search-container">
                            <i class="fas fa-search"></i>
                            <input type="text" placeholder="Search users...">
                        </div>
                        
                        <!-- Link to a future 'addUser.jsp' -->
                        <a href="addUser.jsp" class="btn-add">
                            <i class="fas fa-plus"></i> Add New User
                        </a>
                    </div>

                    <!-- Users Data Table -->
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th style="text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DatabaseConnection.getConnection()) {
                                    String sql = "SELECT user_id, username, email, role, status FROM users ORDER BY user_id ASC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql);
                                         ResultSet rs = ps.executeQuery()) {
                                        
                                        boolean hasUsers = false;
                                        
                                        while (rs.next()) {
                                            hasUsers = true;
                                            int uId = rs.getInt("user_id");
                                            String uName = rs.getString("username");
                                            String uEmail = rs.getString("email");
                                            String uRole = rs.getString("role");
                                            String uStatus = rs.getString("status");
                                            
                                            // --- THE MAGIC CHECK ---
                                            // Is the database username the exact same as the logged-in session username?
                                            boolean isMe = uName.equals(currentUser);
                                            
                                            String displayEmail = (uEmail != null && !uEmail.trim().isEmpty()) ? uEmail : "<span style='color: #888; font-style: italic;'>N/A</span>";
                                            
                                            String statusClass = "status-user-active";
                                            String iconClass = "fa-check-circle";
                                            
                                            if ("Inactive".equalsIgnoreCase(uStatus)) {
                                                statusClass = "status-user-inactive";
                                                iconClass = "fa-times-circle";
                                            }
                            %>
                            <tr style="<%= isMe ? "background-color: #f0f8ff;" : "" %>">
                                <td>
                                    <%= uName %>
                                    <% if (isMe) { %>
                                        <span style="background-color: #2ea3f2; color: white; font-size: 10px; font-weight: bold; padding: 2px 6px; border-radius: 12px; margin-left: 8px;">YOU</span>
                                    <% } %>
                                </td>
                                <td><%= displayEmail %></td>
                                <td><%= uRole %></td>
                                <td>
                                    <span class="<%= statusClass %>"><i class="far <%= iconClass %>"></i> <%= uStatus %></span>
                                </td>
                                <td class="actions">
                                    <a href="editUser.jsp?id=<%= uId %>" class="btn-action edit" title="Edit User">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    
                                    <% if (isMe) { %>
                                        <button class="btn-action" style="color: #ccc; border-color: #eee; cursor: not-allowed;" title="You cannot delete yourself!" disabled>
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    <% } else { %>
                                        <a href="DeleteUserServlet?id=<%= uId %>" class="btn-action delete" title="Delete User" onclick="return confirm('Are you sure you want to delete user: <%= uName %>?');">
                                            <i class="fas fa-trash-alt"></i>
                                        </a>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                        } 
                                        
                                        if (!hasUsers) {
                                            out.println("<tr><td colspan='5' style='text-align:center; padding: 20px;'>No users found in the system.</td></tr>");
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<tr><td colspan='5' style='text-align:center; padding: 20px; color: red;'>Error connecting to the database.</td></tr>");
                                    e.printStackTrace();
                                }
                            %>
                        </tbody>
                    </table>

                </div>
            </div>

        </main>
    </div>

    <!-- Global Footer outside app-container -->
    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

</body>
</html>