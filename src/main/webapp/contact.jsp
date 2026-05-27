<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Support - FSUU Thesis Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* === RESET & BASE STYLES === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        /* FIX: Changed height to min-height so the page can scroll if the form is tall! */
        body { min-height: 100vh; display: flex; flex-direction: column; background-color: #f4f7f6; overflow-x: hidden;}

        /* === TOP NAVIGATION BAR (EXACT COPY FROM FRONTPAGE) === */
        .navbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 15px 50px; background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); height: 80px; z-index: 10;
        }
        .brand { display: flex; align-items: center; gap: 15px; }
        .school-logo {
            width: 50px; 
            height: 50px;  
            object-fit: contain;
        }
        .brand-text h1 { font-size: 22px; color: #003366; line-height: 1.1; }
        .brand-text p { font-size: 10px; color: #555; text-transform: uppercase; letter-spacing: 0.5px; }
        
        /* AUTH BUTTONS (EXACT COPY FROM FRONTPAGE) */
        .auth-toggle { display: flex; background-color: #f0f8ff; border-radius: 30px; border: 2px solid #00aaff; overflow: hidden; }
        .btn-toggle { padding: 8px 25px; border: none; font-weight: 600; font-size: 14px; cursor: pointer; }
        .active-toggle { background-color: #00aaff; color: #ffffff; }
        .inactive-toggle { background-color: transparent; color: #00aaff; }

        /* === DROPDOWN MENU (EXACT COPY FROM FRONTPAGE) === */
        .auth-container {
            position: relative;
            display: inline-block;
        }

        .dropdown-content {
            display: none; /* Hidden by default */
            position: absolute;
            top: 120%; /* Pushes it just below the blue pill */
            right: 0; /* Aligns it to the right edge */
            background-color: #ffffff;
            min-width: 180px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            border-radius: 8px;
            z-index: 20;
            overflow: hidden;
        }

        .dropdown-content a {
            color: #333;
            padding: 12px 16px;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
            font-weight: 600;
            transition: background 0.2s;
        }

        .dropdown-content a:hover {
            background-color: #f1f1f1;
        }

        /* JavaScript will add this class to make it visible */
        .show {
            display: block;
        }
        
        /* RESTORED TO EXACT MATCH WITH FRONTPAGE.JSP */
        .menu{
           width: 18x;
           height: 18px;
           object-fit: contain;
        }

        /* === HERO BACKGROUND === */
        .hero {
            flex-grow: 1; position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center;
            background-image: url('images/background.jpeg');
            background-size: cover; background-position: center;
            padding: 50px 20px;
        }
        .hero-overlay { 
            position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.3); z-index: 1;
        }

        /* === CONTACT LAYOUT === */
        .contact-container {
            position: relative; z-index: 2; width: 100%; max-width: 550px;
            display: flex; flex-direction: column; gap: 20px;
        }

        .contact-header { color: white; font-size: 24px; font-weight: bold; text-shadow: 1px 1px 3px rgba(0,0,0,0.5); margin-bottom: -10px; }

        /* Main Form Card */
        .contact-card {
            background-color: white; border-radius: 8px; padding: 30px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }
        
        .contact-card h2 { font-size: 20px; color: #111; margin-bottom: 20px; }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 12px; color: #333; margin-bottom: 5px; }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 10px 12px; border: 1px solid #00aaff; border-radius: 4px;
            font-size: 13px; outline: none; transition: 0.2s;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            box-shadow: 0 0 0 2px rgba(0, 170, 255, 0.2);
        }
        .form-group textarea { resize: vertical; min-height: 80px; }

        .btn-submit {
            width: 100%; padding: 12px; background-color: #00aaff; color: white;
            border: none; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer;
            transition: background 0.3s; margin-top: 5px;
        }
        .btn-submit:hover { background-color: #0088cc; }

        /* Support Info Card */
        .info-card {
            background-color: white; border-radius: 8px; padding: 20px 30px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
        }
        .info-card h3 { font-size: 14px; color: #111; margin-bottom: 5px; }
        .info-card p { font-size: 11px; color: #666; margin-bottom: 15px; }
        
        .info-list { list-style: none; display: flex; flex-direction: column; gap: 10px; }
        .info-list li { display: flex; align-items: center; gap: 10px; font-size: 12px; color: #333; }
        .info-list i { color: #555; width: 14px; text-align: center; }

        /* Success Message Banner */
        .banner-success {
            background-color: #d4edda; color: #155724; padding: 12px; border-radius: 4px;
            border: 1px solid #c3e6cb; font-size: 13px; margin-bottom: 20px; text-align: center;
        }
    </style>
</head>
<body>

    <nav class="navbar">
        <div class="brand">
            <img src="images/logo.jpeg" class="school-logo" alt="University Logo">
            <div class="brand-text">
                <h1>FSUU</h1>
                <p>Father Saturnino Urios University</p>
            </div>
        </div>
        <div class="auth-container">
            <div class="auth-toggle">
                    <button class="btn-toggle" onclick="toggleMenu(event)">Login</button>
                    <button class="btn-toggle" onclick="window.location.href='signup.jsp'">Signup</button>
             </div>

            <div id="loginMenu" class="dropdown-content">
                <a href="loginStudent.jsp?role=student">
                    <img src="images/student.jpeg" class="menu-icon" alt="Student">Student
                </a>
                <a href="login.jsp?role=admin">
                    <img src="images/admin.jpeg" class="menu-icon" alt="Admin"> Administrator
                </a>
            </div>
        </div>
    </nav>
    <main class="hero">
        <div class="hero-overlay"></div>
        
        <div class="contact-container">
            <div class="contact-header">Contact Support</div>
            
            <div class="contact-card">
                <h2>How can we help you?</h2>
                
                <% if ("sent".equals(request.getParameter("msg"))) { %>
                    <div class="banner-success"><i class="fas fa-check-circle"></i> Your message has been sent successfully! Our support team will respond shortly.</div>
                <% } %>
                
                <form action="ContactSupportServlet" method="POST">
                    <div class="form-group">
                        <label>Name</label>
                        <input type="text" name="name" placeholder="Enter your full name" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" placeholder="Enter your email address" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Subject</label>
                        <input type="text" name="subject" placeholder="What is this regarding?" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Issue Type</label>
                        <select name="issueType" required>
                            <option value="" disabled selected hidden>(Login issues, Technical problem, account access, other)</option>
                            <option value="Login Issue">Login Issue</option>
                            <option value="Technical Problem">Technical Problem</option>
                            <option value="Account Access">Account Access</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <textarea name="message" placeholder="Describe your issue in details" required></textarea>
                    </div>
                    
                    <button type="submit" class="btn-submit">Send Message</button>
                </form>
            </div>

            <div class="info-card">
                <h3>Support contact info</h3>
                <p>Need another way to reach us?</p>
                <ul class="info-list">
                    <li><i class="far fa-envelope"></i> Email: support@fsuu.edu.ph</li>
                    <li><i class="fas fa-phone"></i> Phone: +63 976 245 1234</li>
                    <li><i class="far fa-clock"></i> Office Hours: Monday-Friday, 8:00 AM - 5:00 PM</li>
                </ul>
            </div>
        </div>
        
    </main>

    <script>
        function toggleMenu(event) {
            event.stopPropagation(); 
            document.getElementById("loginMenu").classList.toggle("show");
        }

        window.onclick = function(event) {
            var dropdown = document.getElementById("loginMenu");
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
    </script>
</body>
</html>