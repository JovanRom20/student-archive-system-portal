<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - FSUU Thesis Archive</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* === RESET & BASE STYLES === */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { height: 100vh; display: flex; flex-direction: column; background-color: #f4f7f6; }

        /* === TOP NAVIGATION BAR === */
        .navbar {
         display: flex; 
         justify-content: space-between;
         align-items: center;
         padding: 15px 50px; 
         
         background-color: #ffffff;
         box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); 
         height: 80px;
          z-index: 10;
        }
        .brand { 
        display: flex; 
        align-items: center; 
        gap: 15px;
         }
        .school-logo {
            width: 50px; 
            height: 50px;  
            object-fit: contain;
        }
        .brand-text h1 { 
        font-size: 22px; 
        color: #003366; 
        line-height: 1.1;
        
         }
        .brand-text p { 
        font-size: 10px;
        color: #555;
        
        text-transform: uppercase;
        letter-spacing: 0.5px;
         }
        
        .auth-toggle { 
        display: flex;
        background-color: #f0f8ff;
        border-radius: 30px;
        border: 2px solid #00aaff;
        overflow: hidden; }
        .btn-toggle {
         padding: 8px 25px;
         border: none;
         font-weight: 600;
         font-size: 14px;
         cursor: pointer;
          }
        .active-toggle {
         background-color: #00aaff;
         color: #ffffff;
          }
        .inactive-toggle {
         background-color: transparent;
          color: #00aaff; }

        /* === HERO BACKGROUND & MODAL CONTAINER === */
        .hero {
            flex-grow: 1;
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            /* TODO: Replace with the FSUU building image URL */
            background-image: url('images/background.jpeg');
            background-size: cover; background-position: center;
        }
        .hero-overlay { 
        position: absolute;
         top: 0;
         left: 0;
         right: 0;
         bottom: 0;
         background-color: rgba(0, 0, 0, 0.3); }

        /* === LOGIN BOX === */
        .login-card {
         background-color: #ffffff;
         width: 400px;
         padding: 40px;
              
              
         border-radius: 8px;
         box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
         position: relative; z-index: 2;
         display: flex; flex-direction: column;
         align-items: center;
        }
        .login-card h2 { 
        font-size: 20px; 
        color: #333;
        margin-bottom: 25px;
        
        display: flex; 
        align-items: center;
        gap: 10px; }
        
        .login_logo{
          width: 48px;
          height: 48px;
          object-fit: contain;
        }
        .login-header {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 22px;
            color: #111;
            margin-bottom: 25px;
            font-weight: bold;
        }
        
        /* Form Inputs */
        .login-form {
         width: 100%;
         display: flex;
         flex-direction: column;
          gap: 15px;
           }
        .input-group {
         
         width: 100%;
         display: flex;
         flex-direction: column;
         gap: 5px; /* Adds space for the error text */
          }
          
        .forgot-link-container {
         display: flex;
         justify-content: flex-end;
         width: 100%;
         margin-bottom: -2px; /* Pulls it slightly closer to the input box */
        }
        .error-text {
         color: #ff3b30;
         font-size: 11px;
         margin-left: 2px;
         text-align: left;
        }

        .error-border {
            border-color: #ff3b30 !important;
        }
          
         .switch-login {
         display: block;
         text-align: center;
         margin-top: 25px;
         margin-bottom: 15px;
         font-size: 13px;
         color: #2ea3f2;
         text-decoration: none;
         transition: color 0.2s;
        }

        .switch-login:hover {
            text-decoration: underline;
            color: #1c8cd6;
        }
        .input-group input[type="text"], .input-group input[type="password"] {
          width: 100%;
          padding: 12px 15px;
          border: 1px solid #ccc;
           
          border-radius: 5px;
          font-size: 14px;
          outline: none; 
          transition: border 0.3s;
        }
        .input-group input:focus {
         border-color: #00aaff; }
        
        /* Utilities (Forgot Pass, Remember Me) */
        .form-utils { display: flex;
         justify-content: space-between;
         align-items: center;
         font-size: 12px;
         margin-top: -5px; }
         
        .forgot-link {
         color: #555;
         text-decoration: none;
         font-size: 11px; 
         text-align: right; 
         width: 100%; 
         display: block; 
         margin-top: 5px; }
         
        .forgot-link:hover { 
        text-decoration: underline;
         }
        .checkbox-group { display: flex; align-items: center; gap: 5px; color: #555; }
        
        /* Submit Button */
        .btn-submit {
            width: 100%;
            padding: 12px; 
            background-color: #00aaff; 
            color: white;
            
            border: none; 
            border-radius: 5px; 
            font-size: 15px; 
            font-weight: bold;
            
            cursor: pointer; 
            margin-top: 10px; 
            transition: background 0.3s;
        }
        .btn-submit:hover { background-color: #0088cc; }

        /* Footer Links */
        .card-footer { 
        margin-top: 20px; 
        font-size: 12px;
        color: #555; 
        text-align: center; 
        width: 100%;
         }
        .card-footer a { 
        color: #00aaff; 
        text-decoration: none; 
        font-weight: 600;
         }
        .card-footer a:hover {
         text-decoration: underline; 
         }
        .copyright { 
        margin-top: 20px;
         font-size: 10px; 
         color: #999; 
         text-align: center; }
        
        /* === DROPDOWN MENU === */
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

        .show { display: block; }
        .menu { width: 18px; height: 18px; object-fit: contain; }

        /* ADDED: Styling for global error banners (Account Disabled / Server Crash) */
        .global-error-banner {
            color: #ff3b30; 
            background-color: #fdedec; 
            padding: 12px; 
            border-radius: 5px; 
            font-size: 13px; 
            font-weight: 600; 
            text-align: center; 
            border: 1px solid #ffb3b0; 
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
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
        
        <div class="login-card">
           <div class="login-header">
            <img src="images/admin.jpeg" class="login_logo" alt="LogIcon"> 
                Login your Account
            </div>
            
            <form class="login-form" action="LoginServlet" method="POST">
                <% String error = request.getParameter("error"); %>
                
                <% if ("account_disabled".equals(error)) { %>
                    <div class="global-error-banner">
                        <i class="fas fa-user-lock"></i> Account disabled by an Administrator.
                    </div>
                <% } else if ("server".equals(error)) { %>
                    <div class="global-error-banner">
                        <i class="fas fa-exclamation-triangle"></i> Database connection error.
                    </div>
                <% } %>
                
                <div class="input-group">
                    <input type="text" name="username" placeholder="Username or Email" 
                           class="<%= "invaliduser".equals(error) || "invalid".equals(error) ? "error-border" : "" %>" required>
                    
                    <% if ("invaliduser".equals(error) || "invalid".equals(error)) { %>
                        <span class="error-text">The username you entered is incorrect. Please try again.</span>
                    <% } %>
                </div>

                <div class="input-group">
                    <div class="forgot-link-container">
                        <a href="forgetpass.jsp" class="forgot-link">Forgot Password?</a>
                    </div>
                    <input type="password" name="password" placeholder="Password" 
                           class="<%= "invalidpass".equals(error) || "invalid".equals(error) ? "error-border" : "" %>" required>
                    
                    <% if ("invalidpass".equals(error) || "invalid".equals(error)) { %>
                        <span class="error-text">The password you entered is incorrect. Please try again.</span>
                    <% } %>
                </div>
                
                <div class="form-utils">
                    <label class="checkbox-group">
                        <input type="checkbox" name="remember"> Remember credentials
                    </label>
                </div>
                
                <button type="submit" class="btn-submit">Log in</button>
            </form>
            
            <div class="card-footer">
                <span>Don't have an account? <a href="signup.jsp">Sign Up</a></span>
                <span>Having issues? <a href="contact.jsp">Contact support</a></span>
            </div>
            
            <a href="loginStudent.jsp" class="switch-login">Switch to Student Login</a>
            
            <div class="copyright">
                © Father Saturnino Urios University. All rights reserved.
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