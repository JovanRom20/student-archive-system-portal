<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FSUU Thesis Archive - HOME</title>
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
            flex-grow: 1; position: relative; display: flex; justify-content: center; align-items: center;
            /* TODO: Replace with the FSUU building image URL */
            background-image: url('images/background.jpeg');
            background-size: cover; background-position: center;
        }
        .hero-overlay { 
        position: absolute;
        top: 0;
        left: 0;
        right: 0; bottom:
        0;
        background-color:
        rgba(0, 0, 0, 0.3); 
        display: flex;
        justify-content: center;
        align-items: center;
        }
        .banner-text {
        color: white;
        font-size: 105px;
        font-weight: bold;
        text-align: center;
        line-weight: 1.1;
        
        text-shadow: 2px 2px 2px rgba(0,0,0,0.4);
        }
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

        /* JavaScript will add this class to make it visible */
        .show {
            display: block;
        }
        .menu{
           width: 18x;
           height: 18px;
           object-fit: contain;
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
    <div class="banner">
    
    </div>
    <main class="hero">
        <div class="hero-overlay">
        <h1 class="banner-text">Thesis Archive<br>
        Management
        </h1>
        </div>
        
        
    </main>
    <script>
        function toggleMenu(event) {
            // Stop the click from immediately triggering the window close event
            event.stopPropagation(); 
            document.getElementById("loginMenu").classList.toggle("show");
        }

        // Close the dropdown if the user clicks anywhere else on the page
        window.onclick = function(event) {
            var dropdown = document.getElementById("loginMenu");
            if (dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
    </script>
</body>
</html>