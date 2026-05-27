<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="systempackage.DatabaseConnection" %>
<%
    // --- SECURITY CHECK ---
    String currentUser = (String) session.getAttribute("activeUser");
    String userRole = (String) session.getAttribute("userRole");

 // Only Admins and Faculty should see reports
    if (currentUser == null || "Student".equals(userRole)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return; 
    }

    // --- CHART DATA PREPARATION ---
    int activeCount = 0;
    int hiddenCount = 0;
    int flaggedCount = 0;

    try (Connection conn = DatabaseConnection.getConnection()) {
        // Group the records by their status and count them
        String chartSql = "SELECT status, COUNT(*) as count FROM Thesis_Records GROUP BY status";
        try (PreparedStatement ps = conn.prepareStatement(chartSql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt("count");
                
                if ("Active".equals(status)) activeCount = count;
                else if ("Hidden".equals(status)) hiddenCount = count;
                else if ("Flagged".equals(status)) flaggedCount = count;
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
    <title>Reports - FSUU Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    
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
        .topbar { background-color: #0d3863; color: white; padding: 16px 30px; flex-shrink: 0; }
        .topbar h1 { font-size: 19px; font-weight: 600; }

        /* === REPORTS LAYOUT === */
        .reports-wrapper { padding: 30px; display: flex; flex-direction: column; gap: 25px; }
        
        .report-card {
            background-color: white; border-radius: 12px; padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        
        .chart-card { width: 400px; height: auto; }
        .card-title { font-size: 14px; font-weight: bold; color: #111; margin-bottom: 20px; }

        /* === TABLE STYLES === */
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th { background-color: #1a6bba; color: white; padding: 14px 15px; text-align: left; font-size: 13px; font-weight: 600; }
        th:first-child { border-top-left-radius: 6px; }
        th:last-child { border-top-right-radius: 6px; text-align: center; }
        td { padding: 14px 15px; border-bottom: 1px solid #eee; font-size: 13px; color: #333; }
        
        /* Status Colors */
        .status-active { color: #2ecc71; font-weight: 600; }
        .status-flagged { color: #e74c3c; font-weight: 600; }
        .status-hidden { color: #555555; font-weight: 600; }

        /* Export Button */
        .btn-export {
            background-color: #2ea3f2; color: white; padding: 10px 20px; border: none; 
            border-radius: 6px; font-size: 13px; font-weight: bold; cursor: pointer; transition: 0.3s;
            display: inline-block; text-decoration: none;
        }
        .btn-export:hover { background-color: #1c8cd6; }

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
                <a href="adminDashboard.jsp" class="nav-link">
                    <img src="images/Home.jpeg" class="custom-icon" alt="Home"> Dashboard
                </a>
                <a href="thesisManagement.jsp" class="nav-link">
                    <img src="images/Folder.jpeg" class="custom-icon" alt="Folder"> Thesis Management
                </a>
                <a href="users.jsp" class="nav-link">
                    <img src="images/Users.jpeg" class="custom-icon" alt="Users"> Users
                </a>
                <a href="report.jsp" class="nav-link active">
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

        <main class="main-content">
            
            <header class="topbar">
                <h1>Thesis Archive Management System</h1>
            </header>

            <div class="reports-wrapper">
                
                <div class="report-card chart-card">
                    <div class="card-title">Thesis Status Overview</div>
                    <div style="position: relative; height: 250px; width: 100%;">
                        <canvas id="statusChart"></canvas>
                    </div>
                </div>

                <div class="report-card">
                    <div class="card-title">Detailed Report Table</div>
                    
                    <div id="printableReport">
                        <table>
                            <thead>
                                <tr>
                                    <th>Thesis Title</th>
                                    <th>Author(s)</th>
                                    <th>Department</th>
                                    <th>Status</th>
                                    <th style="text-align: center;">Downloads</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DatabaseConnection.getConnection()) {
                                        // Pull all records, sorting by the highest downloads at the top
                                        String sql = "SELECT title, author, department, status, download_count FROM Thesis_Records ORDER BY download_count DESC";
                                        try (PreparedStatement ps = conn.prepareStatement(sql);
                                             ResultSet rs = ps.executeQuery()) {
                                            
                                            boolean hasRecords = false;
                                            while (rs.next()) {
                                                hasRecords = true;
                                                String tTitle = rs.getString("title");
                                                String tAuthor = rs.getString("author");
                                                String tDept = rs.getString("department");
                                                String tStatus = rs.getString("status");
                                                int tDownloads = rs.getInt("download_count");
                                                
                                                String statusClass = "status-hidden"; 
                                                if ("Active".equals(tStatus)) statusClass = "status-active";
                                                else if ("Flagged".equals(tStatus)) statusClass = "status-flagged";
                                %>
                                <tr>
                                    <td><%= tTitle %></td>
                                    <td><%= tAuthor %></td>
                                    <td><%= tDept != null && !tDept.isEmpty() ? tDept : "N/A" %></td>
                                    <td class="<%= statusClass %>"><%= tStatus %></td>
                                    <td style="text-align: center; font-weight: bold;"><%= tDownloads %></td>
                                </tr>
                                <%
                                            }
                                            
                                            if (!hasRecords) {
                                                out.println("<tr><td colspan='5' style='text-align:center;'>No thesis records found.</td></tr>");
                                            }
                                        }
                                    } catch (SQLException e) {
                                        out.println("<tr><td colspan='5' style='text-align:center;'>Error loading report data.</td></tr>");
                                        e.printStackTrace();
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>

                    <button class="btn-export" id="exportBtn">Export to PDF</button>
                    
                </div>
            </div>

        </main>
    </div>

    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

    <script>
        // 1. CHART.JS CONFIGURATION (Thesis Status Doughnut Chart)
        const ctx = document.getElementById('statusChart').getContext('2d');
        const statusChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Active', 'Hidden', 'Flagged'],
                datasets: [{
                    // Injecting our Java integer variables directly!
                    data: [<%= activeCount %>, <%= hiddenCount %>, <%= flaggedCount %>],
                    backgroundColor: [
                        '#2ecc71', // Green for Active
                        '#555555', // Gray for Hidden
                        '#e74c3c'  // Red for Flagged
                    ],
                    borderWidth: 0,
                    hoverOffset: 5 // Makes the slice pop out slightly when hovered
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '75%', // Controls how thick the donut ring is
                plugins: { 
                    legend: { 
                        display: true, 
                        position: 'bottom',
                        labels: { padding: 20, font: { size: 12, family: "'Segoe UI', sans-serif" } }
                    } 
                }
            }
        });

        // 2. HTML2PDF.JS CONFIGURATION (Export to PDF function)
        document.getElementById('exportBtn').addEventListener('click', function() {
            var element = document.getElementById('printableReport');
            
            var opt = {
                margin:       0.5,
                filename:     'Thesis_Archive_Report.pdf',
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { scale: 2 },
                jsPDF:        { unit: 'in', format: 'letter', orientation: 'landscape' }
            };

            html2pdf().set(opt).from(element).save();
        });
    </script>

</body>
</html>