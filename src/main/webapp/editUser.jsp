<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

    if (currentUser == null || "Student".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return; 
    }
    
    String targetId = request.getParameter("id");
    if (targetId == null || targetId.trim().isEmpty()) {
        response.sendRedirect("users.jsp");
        return;
    }

    String uName = "", uEmail = "", uRole = "", uStatus = "";

    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(targetId));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    uName = rs.getString("username");
                    uEmail = rs.getString("email");
                    if (uEmail == null) uEmail = ""; // Handle nulls safely
                    uRole = rs.getString("role");
                    uStatus = rs.getString("status");
                } else {
                    response.sendRedirect("users.jsp");
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
    <title>Edit User - FSUU Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Base Layout Styles */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; flex-direction: column; height: 100vh; background-color: #e9ecef; }
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
        
        .main-content { flex-grow: 1; display: flex; flex-direction: column; overflow-y: auto; }
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
        
        /* Form Styles */
        .edit-wrapper { padding: 30px; display: flex; justify-content: center; }
        .edit-panel { background-color: white; border-radius: 8px; width: 100%; max-width: 700px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .main-title { color: #2ea3f2; font-size: 20px; font-weight: bold; margin-bottom: 25px; display: flex; align-items: center; gap: 10px; }
        
        .form-row { display: flex; gap: 20px; margin-bottom: 20px; }
        .form-group { display: flex; flex-direction: column; flex: 1; }
        .form-group label { color: #2ea3f2; font-size: 13px; font-weight: 600; margin-bottom: 8px; }
        .form-group input, .form-group select { padding: 12px 15px; border: 1px solid #a3c2e0; border-radius: 6px; font-size: 14px; outline: none; transition: 0.3s; }
        .form-group input:focus, .form-group select:focus { border-color: #2ea3f2; box-shadow: 0 0 0 3px rgba(46,163,242,0.1); }
        
        .button-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn-submit { background-color: #2ea3f2; color: white; padding: 12px 25px; border: none; border-radius: 4px; font-weight: bold; font-size: 14px; cursor: pointer; transition: 0.3s; }
        .btn-submit:hover { background-color: #1c8cd6; }
        .btn-cancel { background-color: white; color: #2ea3f2; padding: 12px 25px; border: 1px solid #a3c2e0; border-radius: 4px; font-weight: bold; font-size: 14px; text-decoration: none; transition: 0.3s; }
        .btn-cancel:hover { background-color: #f0f8ff; }
        
        .app-footer { background-color: #1a6bba; color: white; text-align: center; padding: 12px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="app-container">
        <aside class="sidebar">
            <div class="sidebar-brand"><img src="images/logo.jpeg"><h2>FSUU</h2></div>
            <nav class="nav-menu">
                <a href="adminDashboard.jsp" class="nav-link"><img src="images/Home.jpeg" class="custom-icon"> Dashboard</a>
                <a href="thesisManagement.jsp" class="nav-link"><img src="images/Folder.jpeg" class="custom-icon"> Thesis Management</a>
                <a href="users.jsp" class="nav-link active"><img src="images/Users.jpeg" class="custom-icon"> Users</a>
                <a href="report.jsp" class="nav-link"><img src="images/Report.jpeg" class="custom-icon"> Reports</a>
                <a href="settings.jsp" class="nav-link"><img src="images/Setting.jpeg" class="custom-icon"> Settings</a>
                <a href="LogoutServlet" class="nav-link logout-link"><img src="images/LogOut.jpeg" class="custom-icon"> Logout</a>
            </nav>
        </aside>

        <main class="main-content">
            <header class="topbar"><h1>Thesis Archive Management System</h1></header>

            <div class="edit-wrapper">
                <div class="edit-panel">
                    <div class="main-title"><i class="fas fa-user-edit"></i> Edit User Account</div>

                    <form action="EditUserServlet" method="POST">
                        <input type="hidden" name="userId" value="<%= targetId %>">
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label>Username</label>
                                <input type="text" name="username" value="<%= uName %>" required>
                            </div>
                            <div class="form-group">
                                <label>Email Address</label>
                                <input type="email" name="email" value="<%= uEmail %>">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label>Account Role</label>
                                <select name="role">
                                    <option value="Student" <%= "Student".equals(uRole) ? "selected" : "" %>>Student</option>
                                    <option value="Admin" <%= "Admin".equals(uRole) ? "selected" : "" %>>Admin</option>
                                    <option value="Faculty" <%= "Faculty".equals(uRole) ? "selected" : "" %>>Faculty</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Account Status</label>
                                <select name="status">
                                    <option value="Active" <%= "Active".equals(uStatus) ? "selected" : "" %>>Active</option>
                                    <option value="Inactive" <%= "Inactive".equals(uStatus) ? "selected" : "" %>>Inactive</option>
                                </select>
                            </div>
                        </div>

                        <div class="button-group">
                            <button type="submit" class="btn-submit">Update User</button>
                            <a href="users.jsp" class="btn-cancel">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
    <footer class="app-footer">@2026 FSUU. All right reserved. | Contact: support@fsuu.edu</footer>
</body>
</html>