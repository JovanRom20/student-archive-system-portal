<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // --- SECURITY CHECK ---
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || "Student".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return; 
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add New Thesis - FSUU Archive</title>
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

        /* === ADD FORM STYLES === */
        .edit-wrapper { padding: 25px; display: flex; justify-content: center; }
        .edit-panel {
            background-color: white; border-radius: 8px; width: 100%; max-width: 1000px;
            padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        .main-title { color: #111; font-size: 20px; font-weight: bold; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .main-title span { color: #2ea3f2; }
        .main-title i { color: #2ea3f2; }
        
        /* Section Boxes */
        .section-box { border: 1px solid #d1d5da; border-radius: 8px; padding: 25px; margin-bottom: 25px; }
        .section-title { color: #2ea3f2; font-size: 14px; font-weight: bold; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
        
        /* Form Grids */
        .form-row { display: flex; gap: 25px; margin-bottom: 15px; }
        .form-group { display: flex; flex-direction: column; flex: 1; }
        .form-group.full { width: 100%; }
        
        .form-group label { color: #2ea3f2; font-size: 12px; font-weight: 600; margin-bottom: 8px; }
        .form-group label span { color: #e74c3c; } 
        
        .form-group input, .form-group textarea {
            padding: 12px 15px; border: 1px solid #e74c3c; /* Defaulting to red outline per your Figma until typed in */
            border-radius: 6px; font-size: 13px; outline: none; transition: 0.3s;
        }
        .form-group input:focus, .form-group textarea:focus { border-color: #2ea3f2; box-shadow: 0 0 0 3px rgba(46,163,242,0.1); }
        /* When valid (user typed something), turn border normal */
        .form-group input:valid, .form-group textarea:valid { border-color: #a3c2e0; }
        .form-group textarea { resize: vertical; min-height: 120px; }

        /* File Upload Area */
        .upload-btn {
            background-color: #2ea3f2; color: white; padding: 12px 25px; border-radius: 6px;
            display: inline-flex; align-items: center; gap: 8px; font-weight: 600; font-size: 13px; cursor: pointer; transition: 0.3s;
        }
        .upload-btn:hover { background-color: #1c8cd6; }
        .upload-btn input[type="file"] { display: none; } 
        
        .empty-file-box {
            background-color: #e9ecef; border-radius: 4px; padding: 12px 15px;
            display: inline-flex; align-items: center; justify-content: space-between;
            width: 300px; margin-top: 15px; font-size: 13px; font-weight: bold; color: #333;
        }
        .empty-file-box i { color: #888; cursor: pointer; }
        .file-hint { font-size: 11px; color: #555; margin-top: 15px; }

        /* Submit Buttons */
        .button-group { display: flex; gap: 15px; }
        .btn-submit { background-color: #2ea3f2; color: white; padding: 10px 25px; border: none; border-radius: 4px; font-weight: bold; font-size: 13px; cursor: pointer; transition: 0.3s; display: flex; align-items: center; gap: 8px;}
        .btn-submit:hover { background-color: #1c8cd6; }
        
        .btn-cancel { background-color: white; color: #2ea3f2; padding: 10px 25px; border: 1px solid #a3c2e0; border-radius: 4px; font-weight: bold; font-size: 13px; text-decoration: none; display: flex; align-items: center; transition: 0.3s; }
        .btn-cancel:hover { background-color: #f0f8ff; border-color: #2ea3f2; }

        /* Global Footer */
        .app-footer { background-color: #1a6bba; color: white; text-align: center; padding: 10px; font-size: 11px; flex-shrink: 0;}
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

            <div class="edit-wrapper">
                <div class="edit-panel">
                    
                    <div class="main-title">
                        <i class="fas fa-file-alt"></i> Create a <span>Thesis Creation Form</span>
                    </div>

                    <!-- Note: action points to AddThesisServlet now! -->
                    <form action="AddThesisServlet" method="POST" enctype="multipart/form-data">

                        <!-- SECTION 1: Thesis Information -->
                        <div class="section-box">
                            <div class="section-title"><i class="fas fa-info-circle"></i> Thesis Information</div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Thesis Title <span>*</span></label>
                                    <input type="text" name="title" required>
                                </div>
                                <div class="form-group">
                                    <label>Department <span>*</span></label>
                                    <input type="text" name="department" required>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label>Author Name <span>*</span></label>
                                    <input type="text" name="author" required>
                                </div>
                                <div class="form-group">
                                    <label>Date of Submission <span>*</span></label>
                                    <input type="date" name="submissionDate" required>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group full">
                                    <label>Abstract <span>*</span></label>
                                    <textarea name="abstractText" required></textarea>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group full">
                                    <label>Keywords</label>
                                    <!-- Keywords aren't required in your Figma, so no red outline needed -->
                                    <input type="text" name="keywords" style="border-color: #a3c2e0;">
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 2: File Upload -->
                        <div class="section-box">
                            <div class="section-title"><i class="fas fa-cloud-upload-alt"></i> Thesis File Upload</div>
                            
                            <div>
                                <label class="upload-btn">
                                    <i class="fas fa-upload"></i> Upload Thesis Document
                                    <input type="file" name="thesisFile" id="thesisFileInput" accept=".pdf,.docx" required>
                                </label>
                            </div>
                            
                            <div class="empty-file-box">
                                <span id="fileNameDisplay">No file selected</span>
                                <i class="fas fa-times" id="clearFileBtn" style="cursor:pointer;" title="Remove file"></i>
                            </div>
                            
                            <div class="file-hint">
                                Accepted file types: .pdf, .docx. Maximum file size: 25MB.
                            </div>
                        </div>

                        <!-- SECTION 3: Submit -->
                        <div class="section-box" style="margin-bottom: 0;">
                            <div class="section-title">Submit Section</div>
                            
                            <div class="button-group">
                                <button type="submit" class="btn-submit"><i class="fas fa-check"></i> Submit Thesis</button>
                                <a href="thesisManagement.jsp" class="btn-cancel">Cancel</a>
                            </div>
                        </div>

                    </form>

                </div>
            </div>
            
        </main>
    </div>

    <!-- Global Footer OUTSIDE app-container -->
    <footer class="app-footer">
        @2026 FSUU. All right reserved. | Contact: support@fsuu.edu
    </footer>

    <script>
        const fileInput = document.getElementById('thesisFileInput');
        const fileNameDisplay = document.getElementById('fileNameDisplay');
        const clearBtn = document.getElementById('clearFileBtn');

        // 1. Listen for when a user selects a file
        fileInput.addEventListener('change', function() {
            if (this.files && this.files.length > 0) {
                // Change the text to the file's name and turn it blue
                fileNameDisplay.textContent = this.files[0].name;
                fileNameDisplay.style.color = '#2ea3f2'; 
            } else {
                // If they cancel, revert back
                fileNameDisplay.textContent = 'No file selected';
                fileNameDisplay.style.color = '#333';
            }
        });

        // 2. Listen for when they click the 'X' button
        clearBtn.addEventListener('click', function() {
            fileInput.value = ''; // Empties the actual hidden input
            fileNameDisplay.textContent = 'No file selected'; // Resets the text
            fileNameDisplay.style.color = '#333';
        });
    </script>

</body>
</html>

</body>
</html>