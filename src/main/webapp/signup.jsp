<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signup - FSUU Thesis Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* === RESET & BASE STYLES === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { height: 100vh; display: flex; flex-direction: column; background-color: #f4f7f6; }

        /* === TOP NAVIGATION BAR === */
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
        
        .auth-toggle { display: flex; background-color: #f0f8ff; border-radius: 30px; border: 2px solid #00aaff; overflow: hidden; }
        .btn-toggle { padding: 8px 25px; border: none; font-weight: 600; font-size: 14px; cursor: pointer; }
        .active-toggle { background-color: #00aaff; color: #ffffff; }
        .inactive-toggle { background-color: transparent; color: #00aaff; }

        /* === HERO BACKGROUND & MODAL CONTAINER === */
        .hero {
            flex-grow: 1;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background-image: url('images/background.jpeg');
            background-size: cover; background-position: center;
        }
        .hero-overlay { 
            position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.3); 
            display: flex; justify-content: center; align-items: center;
        }
        
        /* === DROPDOWN MENU === */
        .auth-container { position: relative; display: inline-block; }
        .dropdown-content {
            display: none; position: absolute; top: 120%; right: 0;
            background-color: #ffffff; min-width: 180px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            border-radius: 8px; z-index: 20; overflow: hidden;
        }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 600; transition: background 0.2s; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }
        .menu { width: 18px; height: 18px; object-fit: contain; }

        /* === SIGN UP CARD === */
        .sign-up_Card {
            background-color: #ffffff; width: 450px; padding: 40px;
            border-radius: 12px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            position: relative; z-index: 2; display: flex; flex-direction: column; align-items: center;
        }
        .signup-header { display: flex; align-items: center; gap: 10px; font-size: 22px; color: #111; margin-bottom: 25px; font-weight: bold; }
        .sign-up_logo { width: 24px; height: 24px; object-fit: contain; }

        /* Form Inputs */
        .signup-form { width: 100%; display: flex; flex-direction: column; gap: 15px; }
        .input-group input, .input-group select {
            width: 100%; padding: 12px 15px; border: 1px solid #b3b3b3;
            border-radius: 6px; font-size: 14px; outline: none; transition: border 0.3s; color: #333;
        }
        .input-group input:focus, .input-group select:focus { border-color: #2ea3f2; }
        
        /* Error States */
        .input-group { width: 100%; display: flex; flex-direction: column; gap: 5px; }
        .error-text { color: #ff3b30; font-size: 11px; margin-left: 2px; }
        .error-border { border-color: #ff3b30 !important; }

        /* Submit Button */
        .btn-submit {
            width: 100%; padding: 14px; background-color: #2ea3f2; color: white;
            border: none; border-radius: 6px; font-size: 16px; font-weight: bold;
            cursor: pointer; margin-top: 10px; transition: background 0.3s;
            box-shadow: 0 4px 6px rgba(46, 163, 242, 0.3);
        }
        .btn-submit:hover { background-color: #1c8cd6; }

        /* Footer Links */
        .card-footer { margin-top: 25px; font-size: 12px; color: #555; display: flex; justify-content: space-between; width: 100%; }
        .card-footer a { color: #2ea3f2; text-decoration: none; }
        .card-footer a:hover { text-decoration: underline; }
        .copyright { margin-top: 35px; font-size: 11px; color: #999; text-align: center; width: 100%; }

        /* === SUCCESS POPUP MODAL (ADDED) === */
        .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(0, 0, 0, 0.6); z-index: 100; display: flex; justify-content: center; align-items: center; backdrop-filter: blur(4px); }
        .modal-card { background-color: white; width: 400px; padding: 40px; border-radius: 12px; text-align: center; box-shadow: 0 15px 30px rgba(0,0,0,0.3); animation: slideUp 0.4s ease-out; }
        .modal-icon { font-size: 50px; color: #f39c12; margin-bottom: 20px; }
        .modal-card h2 { color: #333; margin-bottom: 10px; font-size: 22px; }
        .modal-card p { color: #666; font-size: 14px; line-height: 1.5; margin-bottom: 25px; }
        .btn-modal { display: inline-block; background-color: #2ea3f2; color: white; padding: 12px 25px; border-radius: 5px; text-decoration: none; font-weight: bold; transition: 0.3s; }
        .btn-modal:hover { background-color: #1c8cd6; }
        @keyframes slideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
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
                <button class="btn-toggle">Signup</button>
            </div>

            <div id="loginMenu" class="dropdown-content">
                <a href="login.jsp?role=student">
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
        
        <div class="sign-up_Card">
            <div class="signup-header">
                <img src="images/admin.jpeg" class="sign-up_logo" alt="SignIcon"> 
                Create your Account
            </div>
            
            <form class="signup-form" action="SignupServlet" method="POST">
                <% String error = request.getParameter("error"); %>
                
                <div class="input-group">
                    <input type="text" name="username" placeholder="Enter your username" 
                           class="<%= "userexists".equals(error) ? "error-border" : "" %>" required>
                    
                    <% if ("userexists".equals(error)) { %>
                        <span class="error-text">The username you entered already exists. Please try again.</span>
                    <% } %>
                </div>

                <div class="input-group">
                    <input type="email" name="email" placeholder="Enter your email address" 
                           class="<%= "emailexists".equals(error) ? "error-border" : "" %>" required>
                           
                    <% if ("emailexists".equals(error)) { %>
                        <span class="error-text">This email is already registered. Please try logging in.</span>
                    <% } %>
                </div>

                <div class="input-group">
                    <input type="password" name="password" placeholder="Create a strong password" 
                           class="<%= "passwordmismatch".equals(error) ? "error-border" : "" %>" required>
                </div>

                <div class="input-group">
                    <input type="password" name="confirm_password" placeholder="Re-enter your password" 
                           class="<%= "passwordmismatch".equals(error) ? "error-border" : "" %>" required>
                    
                    <% if ("passwordmismatch".equals(error)) { %>
                        <span class="error-text">The passwords you entered do not match. Please try again.</span>
                    <% } %>
                </div>
                
                <div class="input-group">
                    <select name="position" required>
                        <option value="" disabled selected hidden >Select your position</option>
                        <option value="Student">Student</option>
                        <option value="Faculty">Faculty</option>
                        <option value="Admin">Administrator</option>
                    </select>
                </div>
                
                <button type="submit" class="btn-submit">Sign Up</button>
            </form>
            
            <div class="card-footer">
                <span>Already have an account? <a href="login.jsp">Sign In</a></span>
                <span>Having issues? <a href="contact.jsp">Contact support</a></span>
            </div>
            
            <div class="copyright">
                © 2026 Father Saturnino Urios University. All Rights Reserved.
            </div>
            
        </div> 
    </main>
    
    <% 
        String successParam = request.getParameter("success");
        if ("pending".equals(successParam)) { 
    %>
        <div class="modal-overlay">
            <div class="modal-card">
                <i class="fas fa-user-clock modal-icon"></i>
                <h2>Registration Successful!</h2>
                <p>Your account has been created, but it is currently <strong>Pending Approval</strong> by an administrator. You will not be able to log in until your account is activated.</p>
                <a href="login.jsp" class="btn-modal">Return to Login</a>
            </div>
        </div>
    <% } %>

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