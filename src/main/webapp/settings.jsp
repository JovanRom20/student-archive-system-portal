<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

    // If there is no active user, kick them out to login
    if (currentUser == null) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return; 
    }

    // --- FETCH CURRENT USER DETAILS ---
    String currentEmail = "";
    
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT email FROM users WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, currentUser);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentEmail = rs.getString("email");
                    if (currentEmail == null) currentEmail = "";
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - FSUU Thesis Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* === RESET & BASE === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { display: flex; flex-direction: column; min-height: 100vh; background-color: #e9ecef; }

        /* === LAYOUT WRAPPERS === */
        .app-container { display: flex; flex-grow: 1; overflow: hidden; }
        
        /* === SIDEBAR === */
        .sidebar { width: 260px; background-color: #0b2e4f; color: white; display: flex; flex-direction: column; flex-shrink: 0; overflow-y: auto;}
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
            flex-grow: 1; display: flex; flex-direction: column; 
            background-color: #e9ecef; overflow-y: auto; 
        }
        .topbar { background-color: #0d3863; color: white; padding: 16px 30px; flex-shrink: 0; }
        .topbar h1 { font-size: 19px; font-weight: 600; }

        /* === SETTINGS LAYOUT === */
        .settings-wrapper { padding: 30px; }
        
        .settings-card {
            background-color: white; border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex; min-height: 500px;
        }

        /* Inner Left Menu (Profile / Security) */
        .inner-sidebar {
            width: 200px; padding: 30px 20px;
            border-right: 1px solid #eee;
            display: flex; flex-direction: column; gap: 10px;
        }

        .tab-btn {
            background-color: transparent; border: 1px solid #2ea3f2; color: #2ea3f2;
            padding: 10px 15px; border-radius: 6px; font-size: 14px; font-weight: 600;
            text-align: left; cursor: pointer; transition: 0.2s;
            display: flex; align-items: center; gap: 10px;
        }
        
        /* The Active state turns solid blue */
        .tab-btn.active { background-color: #2ea3f2; color: white; }
        .tab-btn:hover:not(.active) { background-color: #f0f8ff; }

        /* Inner Right Content (The Forms) */
        .inner-content { padding: 30px; flex-grow: 1; }
        .section-title { font-size: 15px; font-weight: bold; color: #2ea3f2; margin-bottom: 25px; }

        /* We hide the forms that aren't active */
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.3s ease-in-out; }

        /* Form Styles */
        .form-group { margin-bottom: 20px; max-width: 400px; }
        .form-group label {
            display: block; font-size: 12px; font-weight: 600; color: #333; margin-bottom: 8px;
        }
        .form-group input {
            width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 4px;
            font-size: 14px; outline: none; transition: border-color 0.2s;
        }
        .form-group input:focus { border-color: #2ea3f2; }

        .btn-submit {
            background-color: #2ea3f2; color: white; border: none; padding: 10px 20px;
            border-radius: 4px; font-size: 13px; font-weight: bold; cursor: pointer; margin-top: 10px;
        }
        .btn-submit:hover { background-color: #1c8cd6; }

        /* Fade in animation for tab switching */
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        /* === FOOTER === */
        .app-footer { background-color: #1a6bba; color: white; text-align: center; padding: 12px; font-size: 12px; }

        /* === BANNERS === */
        .banner-success { background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 20px; border: 1px solid #c3e6cb; font-size: 13px; }
        .banner-error { background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 20px; border: 1px solid #f5c6cb; font-size: 13px; }
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
                <a href="adminDashboard.jsp" class="nav-link">
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
                
                <a href="settings.jsp" class="nav-link active">
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

            <div class="settings-wrapper">
                <div class="settings-card">
                    
                    <div class="inner-sidebar">
                        <button class="tab-btn active" onclick="switchTab('profileTab', this)">
                            <i class="far fa-user"></i> Profile
                        </button>
                        <button class="tab-btn" onclick="switchTab('securityTab', this)">
                            <i class="fas fa-lock"></i> Security
                        </button>
                    </div>

                    <div class="inner-content">
                        
                        <% 
                            String msg = request.getParameter("msg");
                            if ("profileUpdated".equals(msg)) {
                        %>
                            <div class="banner-success"><i class="fas fa-check-circle"></i> Profile updated successfully.</div>
                        <% } else if ("passwordUpdated".equals(msg)) { %>
                            <div class="banner-success"><i class="fas fa-check-circle"></i> Password updated successfully.</div>
                        <% } else if ("passwordMismatch".equals(msg)) { %>
                            <div class="banner-error"><i class="fas fa-exclamation-circle"></i> New passwords do not match.</div>
                        <% } else if ("incorrectPassword".equals(msg)) { %>
                            <div class="banner-error"><i class="fas fa-exclamation-circle"></i> Current password is incorrect.</div>
                        <% } else if ("error".equals(msg)) { %>
                            <div class="banner-error"><i class="fas fa-exclamation-triangle"></i> An error occurred. Please try again.</div>
                        <% } %>

                        <div id="profileTab" class="tab-content active">
                            <h2 class="section-title">Profile Settings</h2>
                            
                            <form action="UpdateProfileServlet" method="POST">
                                <div class="form-group">
                                    <label><i class="far fa-user"></i> Full Name (Username)</label>
                                    <input type="text" name="fullName" value="<%= currentUser %>" placeholder="Enter full name" required>
                                </div>
                                <div class="form-group">
                                    <label><i class="far fa-id-badge"></i> Role</label>
                                    <input type="text" name="role" value="<%= userRole != null ? userRole : "" %>" readonly style="background-color: #f9f9f9; cursor: not-allowed;">
                                </div>
                                <div class="form-group">
                                    <label><i class="far fa-envelope"></i> Email Address</label>
                                    <input type="email" name="email" value="<%= currentEmail %>" placeholder="Enter email address" required>
                                </div>
                                <div class="form-group">
                                    <label><i class="far fa-building"></i> Department</label>
                                    <input type="text" name="department" placeholder="Enter department (e.g. CITE)">
                                </div>
                                <button type="submit" class="btn-submit">Save changes</button>
                            </form>
                        </div>

                        <div id="securityTab" class="tab-content">
                            <h2 class="section-title">Password Settings</h2>
                            
                            <form action="UpdatePasswordServlet" method="POST">
                                <div class="form-group">
                                    <label><i class="fas fa-key"></i> Current Password</label>
                                    <input type="password" name="currentPassword" required>
                                </div>
                                <div class="form-group">
                                    <label><i class="fas fa-lock"></i> New Password</label>
                                    <input type="password" name="newPassword" required>
                                </div>
                                <div class="form-group">
                                    <label><i class="fas fa-check-circle"></i> Confirm New Password</label>
                                    <input type="password" name="confirmPassword" required>
                                </div>
                                <button type="submit" class="btn-submit">Update Password</button>
                            </form>
                        </div>

                    </div>
                </div>
            </div>
        </main>
    </div>

    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

    <script>
        function switchTab(tabId, clickedBtn) {
            // 1. Hide all tab contents
            const contents = document.querySelectorAll('.tab-content');
            contents.forEach(content => content.classList.remove('active'));
            
            // 2. Remove the active color from all buttons
            const buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            
            // 3. Show the selected tab content and color the clicked button blue
            document.getElementById(tabId).classList.add('active');
            clickedBtn.classList.add('active');
        }
    </script>

</body>
</html>