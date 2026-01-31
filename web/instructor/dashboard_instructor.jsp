<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is instructor
    if (!SessionUtil.checkInstructorAccess(session)) {
        // Always redirect to login with appropriate message
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_instructor_pages");
        } else {
            // If logged in but not instructor
            response.sendRedirect("../general/login.jsp?error=instructor_access_required&message=Instructor_privileges_required_to_access_this_page");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Dashboard Instructor Page</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <!-- Icons -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Tailwind Custom Palette -->
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui'],
                        },
                        colors: {
                            /* Primary & Background */
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            blushHover: '#E8BEBE',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',

                            /* Text */
                            espresso: '#3D3434',
                            successText: '#1E3A1E',

                            /* Blue Accents */
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',

                            /* Alerts */
                            successBg: '#A5D6A7',
                            successTextDark: '#1B5E20',

                            warningBg: '#FFCC80',
                            warningText: '#E65100',

                            dangerBg: '#EF9A9A',
                            dangerText: '#B71C1C',

                            infoBg: '#A3C1D6',
                            infoText: '#2C5555',

                            /* New Colors */
                            chartBlue: '#4A90E2',
                            chartGreen: '#50C878',
                            chartOrange: '#FFA500',
                            chartPurple: '#9B59B6'
                        }
                    }
                }
            }
        </script>

        <style>
            @media (max-width: 640px) {
                .mobile-stack { flex-direction: column !important; }
                .mobile-full { width: 100% !important; }
                .mobile-text-center { text-align: center !important; }
                .mobile-p-4 { padding: 1rem !important; }
                .mobile-mb-4 { margin-bottom: 1rem !important; }
            }

            .card-hover {
                transition: all 0.3s ease;
            }
            .card-hover:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 25px rgba(179, 109, 109, 0.15);
            }

            .pulse {
                animation: pulse 2s infinite;
            }

            @keyframes pulse {
                0% { box-shadow: 0 0 0 0 rgba(255, 152, 0, 0.4); }
                70% { box-shadow: 0 0 0 10px rgba(255, 152, 0, 0); }
                100% { box-shadow: 0 0 0 0 rgba(255, 152, 0, 0); }
            }

            .gradient-bg {
                background: linear-gradient(135deg, #FDF8F8 0%, #FFFFFF 100%);
            }

            .calendar-day {
                width: 2rem;
                height: 2rem;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
                cursor: pointer;
                transition: all 0.2s;
            }

            .calendar-day:hover {
                background-color: #F2D1D1;
            }

            .calendar-day.has-class {
                background-color: #B36D6D;
                color: white;
            }

            .notification-badge {
                position: absolute;
                top: -5px;
                right: -5px;
                background: #B71C1C;
                color: white;
                border-radius: 50%;
                width: 18px;
                height: 18px;
                font-size: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .qr-container {
                position: relative;
                display: inline-block;
            }

            .qr-placeholder {
                width: 60px;
                height: 60px;
                background-color: #f0f0f0;
                border: 2px dashed #B36D6D;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .qr-placeholder:hover {
                background-color: #F2D1D1;
                transform: scale(1.05);
            }

            .qr-expanded {
                position: absolute;
                top: 70px;
                left: 0;
                z-index: 100;
                background: white;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
                padding: 15px;
                display: none;
                width: 200px;
                text-align: center;
            }

            .qr-expanded img {
                width: 160px;
                height: 160px;
                margin-bottom: 10px;
            }

            .qr-expanded.show {
                display: block;
            }

            .main-container {
                background: linear-gradient(135deg, #FDF8F8 0%, #FFFFFF 100%);
                border-radius: 20px;
                border: 2px solid #F2D1D1;
                box-shadow: 0 8px 30px rgba(179, 109, 109, 0.08);
                overflow: hidden;
            }

            .welcome-header {
                background: linear-gradient(135deg, #F2D1D1 0%, #EFE1E1 100%);
                padding: 2rem;
                border-bottom: 2px solid #EFE1E1;
            }

            .dashboard-grid {
                padding: 2rem;
                display: grid;
                grid-template-columns: 1fr;
                gap: 2rem;
            }

            .section-card {
                background: white;
                border-radius: 16px;
                border: 1px solid #EFE1E1;
                padding: 1.5rem;
                transition: all 0.3s ease;
            }

            .section-card:hover {
                box-shadow: 0 10px 25px rgba(179, 109, 109, 0.1);
                border-color: #F2D1D1;
            }

            .section-title {
                color: #3D3434;
                font-weight: 600;
                font-size: 1.25rem;
                margin-bottom: 1.5rem;
                padding-bottom: 0.75rem;
                border-bottom: 2px solid #F2D1D1;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <!-- MAIN CONTAINER: Welcome Sarah Lim! -->
            <div class="w-full main-container" style="max-width:1500px">

                <!-- Welcome Header -->
                <div class="welcome-header">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mobile-stack">
                        <div class="mobile-full mobile-mb-4 md:mb-0">
                            <div class="flex items-center mb-3">
                                <div class="w-16 h-16 rounded-full bg-whitePure border-4 border-whitePure shadow-md flex items-center justify-center mr-4">
                                    <i class="fas fa-user text-dusty text-2xl"></i>
                                </div>
                                <div>
                                    <h1 class="text-3xl font-bold text-espresso">
                                        Welcome, <span class="text-dusty">Sarah Lim</span>!
                                    </h1>
                                    <p class="text-espresso/70 text-sm mt-1">
                                        <i class="fas fa-certificate text-dusty mr-2"></i>
                                        Certified Mat Pilates Instructor • Since 2022
                                    </p>
                                    <div class="flex items-center mt-3 space-x-4">
                                        <span class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-calendar-check text-dusty mr-2"></i>
                                            12 Classes This Month
                                        </span>
                                        <span class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-star text-yellow-500 mr-2"></i>
                                            4.8 Avg Rating
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="flex space-x-6 mobile-full mobile-justify-center">
                            <div class="text-center bg-whitePure/90 p-4 rounded-xl shadow-sm min-w-[100px]">
                                <div class="text-3xl font-bold text-dusty">3</div>
                                <div class="text-sm text-espresso/70">Today</div>
                                <div class="text-xs text-espresso/50 mt-1">Classes</div>
                            </div>
                            <div class="text-center bg-whitePure/90 p-4 rounded-xl shadow-sm min-w-[100px]">
                                <div class="text-3xl font-bold text-teal">8</div>
                                <div class="text-sm text-espresso/70">Available</div>
                                <div class="text-xs text-espresso/50 mt-1">Classes</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Dashboard Content Grid - CHANGED TO SINGLE COLUMN -->
                <div class="dashboard-grid">

                    <!-- TODAY'S SCHEDULE -->
                    <div class="section-card">
                        <h2 class="section-title">
                            <i class="fas fa-calendar-day text-dusty"></i>
                            Today's Schedule
                        </h2>
                        <p class="text-sm text-espresso/60 mb-6">
                            <span id="current-date"></span> • You have 3 classes today
                        </p>

                        <!-- Today's Classes Timeline -->
                        <div class="space-y-4">
                            <!-- Morning Class -->
                            <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30">
                                <div class="w-20 text-center">
                                    <div class="text-lg font-bold text-dusty">9:00 AM</div>
                                    <div class="text-xs text-espresso/60">60 mins</div>
                                </div>
                                <div class="flex-1 ml-6">
                                    <div class="flex justify-between items-start mobile-stack">
                                        <div class="mobile-full mobile-mb-2 md:mb-0">
                                            <h3 class="font-semibold text-espresso text-lg">Mat Pilates Beginner</h3>
                                            <p class="text-sm text-espresso/70">
                                                <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                Studio A • <span class="font-medium">12 students enrolled</span>
                                            </p>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <!-- QR Code Placeholder -->
                                            <div class="qr-container">
                                                <div class="qr-placeholder" onclick="toggleQR('qr1')">
                                                    <i class="fas fa-qrcode text-dusty text-xl"></i>
                                                </div>
                                                <div class="qr-expanded" id="qr1">
                                                    <img src="qr_codes/dummy.PNG" alt="QR Code for Mat Pilates Beginner">
                                                    <button onclick="location.href = 'feedback.jsp'" 
                                                            class="mt-3 w-full bg-dusty text-whitePure py-2 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                                                        <i class="fas fa-chart-bar mr-2"></i>View Feedback
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-3 flex items-center text-sm text-espresso/60">
                                        <span class="mr-4">
                                            <i class="fas fa-user mr-1"></i>Sarah Lim (You)
                                        </span>
                                        <span>
                                            <i class="fas fa-chart-bar mr-1"></i>Avg. Rating: 4.8/5
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Afternoon Class -->
                            <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30">
                                <div class="w-20 text-center">
                                    <div class="text-lg font-bold text-dusty">2:00 PM</div>
                                    <div class="text-xs text-espresso/60">60 mins</div>
                                </div>
                                <div class="flex-1 ml-6">
                                    <div class="flex justify-between items-start mobile-stack">
                                        <div class="mobile-full mobile-mb-2 md:mb-0">
                                            <h3 class="font-semibold text-espresso text-lg">Reformer Intermediate</h3>
                                            <p class="text-sm text-espresso/70">
                                                <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                Studio B • <span class="font-medium">8 students enrolled</span>
                                            </p>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <!-- QR Code Placeholder -->
                                            <div class="qr-container">
                                                <div class="qr-placeholder" onclick="toggleQR('qr2')">
                                                    <i class="fas fa-qrcode text-dusty text-xl"></i>
                                                </div>
                                                <div class="qr-expanded" id="qr2">
                                                    <img src="qr_codes/dummy.PNG" alt="QR Code for Reformer Intermediate">
                                                    <button onclick="location.href = 'feedback.jsp'" 
                                                            class="mt-3 w-full bg-dusty text-whitePure py-2 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                                                        <i class="fas fa-chart-bar mr-2"></i>View Feedback
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Evening Class -->
                            <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30">
                                <div class="w-20 text-center">
                                    <div class="text-lg font-bold text-dusty">6:00 PM</div>
                                    <div class="text-xs text-espresso/60">60 mins</div>
                                </div>
                                <div class="flex-1 ml-6">
                                    <div class="flex justify-between items-start mobile-stack">
                                        <div class="mobile-full mobile-mb-2 md:mb-0">
                                            <h3 class="font-semibold text-espresso text-lg">Advanced Pilates</h3>
                                            <p class="text-sm text-espresso/70">
                                                <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                Studio A • <span class="font-medium">10 students enrolled</span>
                                            </p>
                                        </div>
                                        <div class="flex items-center space-x-3">
                                            <!-- QR Code Placeholder -->
                                            <div class="qr-container">
                                                <div class="qr-placeholder" onclick="toggleQR('qr3')">
                                                    <i class="fas fa-qrcode text-dusty text-xl"></i>
                                                </div>
                                                <div class="qr-expanded" id="qr3">
                                                    <img src="qr_codes/dummy.PNG" alt="QR Code for Advanced Pilates">
                                                    <button onclick="location.href = 'feedback.jsp'" 
                                                            class="mt-3 w-full bg-dusty text-whitePure py-2 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                                                        <i class="fas fa-chart-bar mr-2"></i>View Feedback
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- WEEK AT A GLANCE - NOW BELOW TODAY'S SCHEDULE -->
                    <div class="section-card">
                        <div class="flex items-center justify-between mb-6">
                            <h2 class="section-title">
                                <i class="fas fa-calendar text-dusty"></i>
                                Week at a Glance
                            </h2>
                            <span class="text-sm text-espresso/60">Nov 2024</span>
                        </div>

                        <!-- Calendar Header -->
                        <div class="grid grid-cols-7 gap-1 mb-3">
                            <div class="text-center text-xs font-medium text-espresso/60">Sun</div>
                            <div class="text-center text-xs font-medium text-espresso/60">Mon</div>
                            <div class="text-center text-xs font-medium text-espresso/60">Tue</div>
                            <div class="text-center text-xs font-medium text-espresso/60">Wed</div>
                            <div class="text-center text-xs font-medium text-espresso/60">Thu</div>
                            <div class="text-center text-xs font-medium text-espresso/60">Fri</div>
                            <div class="text-center text-xs font-medium text-espresso/60">Sat</div>
                        </div>

                        <!-- Calendar Days -->
                        <div class="grid grid-cols-7 gap-1 mb-6" id="mini-calendar">
                            <!-- Calendar days will be populated by JavaScript -->
                        </div>

                        <!-- Class Status Legend -->
                        <div class="mt-6 pt-6 border-t border-petal">
                            <h4 class="font-medium text-espresso mb-3">Class Status</h4>
                            <div class="space-y-2">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center">
                                        <div class="w-3 h-3 rounded-full bg-dusty mr-2"></div>
                                        <span class="text-sm text-espresso/70">Your Class</span>
                                    </div>
                                    <span class="text-xs text-espresso/60">3 classes</span>
                                </div>
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center">
                                        <div class="w-3 h-3 rounded-full bg-teal mr-2"></div>
                                        <span class="text-sm text-espresso/70">Available for Relief</span>
                                    </div>
                                    <span class="text-xs text-espresso/60">2 classes</span>
                                </div>
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center">
                                        <div class="w-3 h-3 rounded-full bg-successTextDark mr-2"></div>
                                        <span class="text-sm text-espresso/70">Completed Relief</span>
                                    </div>
                                    <span class="text-xs text-espresso/60">2 classes</span>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="mt-6 pt-6 border-t border-petal">
                            <h4 class="font-medium text-espresso mb-3">This Week</h4>
                            <div class="grid grid-cols-2 gap-3">
                                <div class="text-center p-3 rounded-lg bg-blush/20">
                                    <div class="text-lg font-bold text-dusty">5</div>
                                    <div class="text-xs text-espresso/70">Total Classes</div>
                                </div>
                                <div class="text-center p-3 rounded-lg bg-successBg/20">
                                    <div class="text-lg font-bold text-successTextDark">2</div>
                                    <div class="text-xs text-espresso/70">Relieved</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 2-Column Grid for Relief Updates & Available Classes -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                        <!-- RELIEF CLASS UPDATES -->
                        <div class="section-card">
                            <div class="flex items-center justify-between mb-6">
                                <h2 class="section-title">
                                    <i class="fas fa-exchange-alt text-infoText"></i>
                                    Relief Class Updates
                                </h2>
                                <a href="pending.jsp" class="text-dusty text-sm font-medium hover:text-dustyHover">
                                    History →
                                </a>
                            </div>

                            <div class="space-y-4">
                                <!-- Successfully Relieved Class -->
                                <div class="p-4 rounded-lg border border-successBg/50 bg-successBg/10">
                                    <div class="flex items-center mb-3">
                                        <div class="w-10 h-10 rounded-full bg-successBg flex items-center justify-center mr-3">
                                            <i class="fas fa-check-circle text-successTextDark"></i>
                                        </div>
                                        <div>
                                            <h4 class="font-semibold text-espresso">Successfully Relieved</h4>
                                            <p class="text-xs text-espresso/70">You took over a class</p>
                                        </div>
                                    </div>
                                    <div class="space-y-3">
                                        <div class="p-3 rounded-lg bg-whitePure/50 border border-successBg/30">
                                            <div class="flex items-center justify-between mb-1">
                                                <span class="font-medium text-espresso">Evening Flow Class</span>
                                                <span class="text-xs bg-successBg text-successTextDark px-2 py-1 rounded">COMPLETED</span>
                                            </div>
                                            <p class="text-sm text-espresso/70">
                                                <i class="fas fa-calendar-alt mr-2"></i>
                                                Thursday, Nov 14 • 7:00 PM • Studio C
                                            </p>
                                            <div class="flex items-center justify-between mt-2 text-xs">
                                                <span class="text-espresso/60">
                                                    <i class="fas fa-user-friends mr-1"></i>
                                                    9 students attended
                                                </span>
                                                <span class="text-successTextDark font-medium">
                                                    <i class="fas fa-star mr-1"></i>
                                                    4.5/5 rating
                                                </span>
                                            </div>
                                        </div>

                                        <div class="p-3 rounded-lg bg-whitePure/50 border border-successBg/30">
                                            <div class="flex items-center justify-between mb-1">
                                                <span class="font-medium text-espresso">Weekend Reformer</span>
                                                <span class="text-xs bg-successBg text-successTextDark px-2 py-1 rounded">COMPLETED</span>
                                            </div>
                                            <p class="text-sm text-espresso/70">
                                                <i class="fas fa-calendar-alt mr-2"></i>
                                                Saturday, Nov 9 • 9:00 AM • Studio B
                                            </p>
                                            <div class="flex items-center justify-between mt-2 text-xs">
                                                <span class="text-espresso/60">
                                                    <i class="fas fa-user-friends mr-1"></i>
                                                    7 students attended
                                                </span>
                                                <span class="text-successTextDark font-medium">
                                                    <i class="fas fa-star mr-1"></i>
                                                    4.8/5 rating
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-4 pt-3 border-t border-successBg/30">
                                        <p class="text-xs text-espresso/60 text-center">
                                            <i class="fas fa-info-circle mr-1"></i>
                                            You successfully relieved 2 classes this month
                                        </p>
                                    </div>
                                </div>

                                <!-- Upcoming Relief Opportunities -->
                                <div class="p-4 rounded-lg border border-infoBg/50 bg-infoBg/10">
                                    <div class="flex items-center mb-3">
                                        <div class="w-10 h-10 rounded-full bg-infoBg flex items-center justify-center mr-3">
                                            <i class="fas fa-clock text-infoText"></i>
                                        </div>
                                        <div>
                                            <h4 class="font-semibold text-espresso">Available for Relief</h4>
                                            <p class="text-xs text-espresso/70">Position in queue</p>
                                        </div>
                                    </div>
                                    <p class="text-sm text-espresso/80 mb-2">
                                        <i class="fas fa-list-ol text-infoText mr-2"></i>
                                        "Morning Flow" - Position #3
                                    </p>
                                    <div class="flex items-center text-xs text-espresso/60 mb-3">
                                        <i class="fas fa-info-circle mr-1"></i>
                                        You will be notified if position #1 becomes available
                                    </div>
                                    <div class="bg-whitePure/50 p-3 rounded-lg border border-infoBg/30">
                                        <p class="text-xs text-espresso/70 mb-1">Next in line:</p>
                                        <div class="flex items-center justify-between">
                                            <span class="text-sm font-medium text-espresso">Michael Chen</span>
                                            <span class="text-xs bg-infoBg text-infoText px-2 py-1 rounded">POSITION #1</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- AVAILABLE CLASSES -->
                        <div class="section-card">
                            <div class="flex items-center justify-between mb-6">
                                <h2 class="section-title">
                                    <i class="fas fa-search text-teal"></i>
                                    Available Classes
                                </h2>
                                <a href="view_class.jsp" class="text-teal text-sm font-medium hover:text-tealHover">
                                    Browse All →
                                </a>
                            </div>

                            <div class="space-y-4">
                                <!-- New Class -->
                                <div class="p-4 rounded-lg border border-infoBg/30 bg-infoBg/5">
                                    <div class="flex justify-between items-start mb-2">
                                        <h4 class="font-semibold text-espresso">Weekend Reformer</h4>
                                        <span class="text-xs bg-infoBg text-infoText px-2 py-1 rounded">NEW</span>
                                    </div>
                                    <p class="text-sm text-espresso/70 mb-3">
                                        <i class="fas fa-calendar-alt mr-2"></i>
                                        Saturday, Nov 16 • 9:00 AM • Studio B
                                    </p>
                                    <div class="flex justify-between items-center">
                                        <span class="text-xs text-espresso/60">
                                            <i class="fas fa-user-friends mr-1"></i>
                                            6/8 spots filled
                                        </span>
                                        <span class="text-xs text-espresso/60">Available</span>
                                    </div>
                                </div>

                                <!-- Available Class -->
                                <div class="p-4 rounded-lg border border-blush/30">
                                    <div class="flex justify-between items-start mb-2">
                                        <h4 class="font-semibold text-espresso">Morning Flow</h4>
                                        <span class="text-xs bg-blush text-dusty px-2 py-1 rounded">OPEN</span>
                                    </div>
                                    <p class="text-sm text-espresso/70 mb-3">
                                        <i class="fas fa-calendar-alt mr-2"></i>
                                        Monday, Nov 18 • 8:00 AM • Studio A
                                    </p>
                                    <div class="flex justify-between items-center">
                                        <span class="text-xs text-espresso/60">
                                            <i class="fas fa-user-friends mr-1"></i>
                                            4/10 spots filled
                                        </span>
                                        <span class="text-xs text-espresso/60">Available</span>
                                    </div>
                                </div>
                            </div>

                            <div class="mt-6 pt-4 border-t border-petal">
                                <a href="view_class.jsp" class="text-dusty font-medium text-sm hover:text-dustyHover flex items-center justify-center">
                                    <i class="fas fa-plus-circle mr-2"></i>
                                    View All 8 Available Classes
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </main>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
                                                        // Initialize when page loads
                                                        document.addEventListener('DOMContentLoaded', function () {
                                                            // Set current date
                                                            const now = new Date();
                                                            const options = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'};
                                                            document.getElementById('current-date').textContent = now.toLocaleDateString('en-US', options);

                                                            // Initialize mini calendar
                                                            initializeMiniCalendar();

                                                            // Close QR when clicking outside
                                                            document.addEventListener('click', function (event) {
                                                                const qrExpanded = document.querySelectorAll('.qr-expanded.show');
                                                                qrExpanded.forEach(qr => {
                                                                    if (!qr.contains(event.target) && !event.target.closest('.qr-placeholder')) {
                                                                        qr.classList.remove('show');
                                                                    }
                                                                });
                                                            });
                                                        });

                                                        function initializeMiniCalendar() {
                                                            const calendarEl = document.getElementById('mini-calendar');
                                                            const now = new Date();
                                                            const currentMonth = now.getMonth();
                                                            const currentYear = now.getFullYear();
                                                            const currentDay = now.getDate();

                                                            // Get first day of month
                                                            const firstDay = new Date(currentYear, currentMonth, 1);
                                                            const startingDay = firstDay.getDay(); // 0 = Sunday

                                                            // Get days in month
                                                            const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

                                                            // Days with classes (simulated data)
                                                            const classDays = [12, 15, 18, 20, 22]; // Regular classes
                                                            const reliefAvailableDays = [16, 19]; // Available for relief
                                                            const completedReliefDays = [9, 14]; // Completed relief classes

                                                            let calendarHTML = '';

                                                            // Empty cells for days before month starts
                                                            for (let i = 0; i < startingDay; i++) {
                                                                calendarHTML += '<div class="calendar-day"></div>';
                                                            }

                                                            // Days of the month
                                                            for (let day = 1; day <= daysInMonth; day++) {
                                                                let dayClass = 'calendar-day';
                                                                let dayContent = day;

                                                                // Highlight today
                                                                if (day === currentDay) {
                                                                    dayClass += ' bg-dusty text-whitePure';
                                                                }
                                                                // Mark days with regular classes
                                                                else if (classDays.includes(day)) {
                                                                    dayClass += ' has-class';
                                                                }
                                                                // Mark days available for relief
                                                                else if (reliefAvailableDays.includes(day)) {
                                                                    dayClass += ' border-2 border-teal';
                                                                }
                                                                // Mark completed relief days
                                                                else if (completedReliefDays.includes(day)) {
                                                                    dayClass += ' border-2 border-successTextDark';
                                                                }

                                                                calendarHTML += `<div class="${dayClass}" title="${day} Nov ${currentYear}">${dayContent}</div>`;
                                                            }

                                                            calendarEl.innerHTML = calendarHTML;
                                                        }

                                                        function toggleQR(qrId) {
                                                            const qrElement = document.getElementById(qrId);

                                                            // Close all other QR codes
                                                            document.querySelectorAll('.qr-expanded.show').forEach(qr => {
                                                                if (qr.id !== qrId) {
                                                                    qr.classList.remove('show');
                                                                }
                                                            });

                                                            // Toggle current QR code
                                                            qrElement.classList.toggle('show');
                                                        }
        </script>

    </body>
</html>