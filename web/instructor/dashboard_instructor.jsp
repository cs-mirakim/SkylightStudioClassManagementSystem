<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    // Check if user is instructor - keep for security
    if (!SessionUtil.checkInstructorAccess(session)) {
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_instructor_pages");
        } else {
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
            /* Only keep essential non-Tailwind styles */
            @media (max-width: 640px) {
                .mobile-stack { flex-direction: column !important; }
                .mobile-full { width: 100% !important; }
            }

            .qr-expanded {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 1000;
                background: white;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 30px;
                display: none;
                width: 320px;
                text-align: center;
                border: 3px solid #F2D1D1;
            }

            .qr-expanded img {
                width: 200px;
                height: 200px;
                margin: 0 auto 15px;
                border-radius: 8px;
                border: 1px solid #EFE1E1;
                display: block;
            }

            .qr-expanded.show {
                display: block;
                animation: fadeInScale 0.3s ease-out;
            }

            .qr-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.5);
                z-index: 999;
                display: none;
            }

            .qr-overlay.show {
                display: block;
            }

            @keyframes fadeInScale {
                from {
                    opacity: 0;
                    transform: translate(-50%, -50%) scale(0.9);
                }
                to {
                    opacity: 1;
                    transform: translate(-50%, -50%) scale(1);
                }
            }

            .qr-close-btn {
                position: absolute;
                top: 12px;
                right: 12px;
                background: #EFE1E1;
                border: none;
                border-radius: 50%;
                width: 30px;
                height: 30px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                color: #3D3434;
                font-size: 16px;
                transition: all 0.2s ease;
                z-index: 1001;
            }

            .qr-close-btn:hover {
                background: #F2D1D1;
                color: #B36D6D;
            }

            /* Weekly Calendar Grid */
            .week-day-classes {
                display: flex;
                flex-direction: column;
                gap: 0.375rem;
            }

            .week-class-item {
                font-size: 0.75rem;
                padding: 0.375rem;
                border-radius: 6px;
                border-left: 3px solid;
                background: white;
            }

            .week-class-item.confirm {
                border-left-color: #1B5E20;
                background-color: #A5D6A7;
            }

            .week-class-item.pending {
                border-left-color: #E65100;
                background-color: #FFCC80;
            }

            .week-class-time {
                font-size: 0.7rem;
                color: rgba(61, 52, 52, 0.7);
                margin-top: 0.125rem;
            }

            .week-class-title {
                font-weight: 500;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="py-6 px-4 md:px-8 flex-1 flex flex-col items-center">
            <!-- MAIN CONTAINER -->
            <div class="w-full bg-whitePure rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Welcome Header -->
                <div class="bg-gradient-to-br from-blush to-petal rounded-t-xl py-8 px-6 md:px-8 border-b border-petal">
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
                                        Registered • Since 2020
                                    </p>
                                    <div class="flex items-center mt-3 space-x-4">
                                        <span class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-calendar-check text-dusty mr-2"></i>
                                            12 Classes This Month
                                        </span>
                                        <span class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-star text-yellow-500 mr-2"></i>
                                            4.5 Avg Rating
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Dashboard Content Grid -->
                <div class="p-6 md:p-8 space-y-8 flex-1">
                    <!-- TODAY'S SCHEDULE -->
                    <div class="bg-white rounded-xl border border-petal p-6 shadow-sm hover:shadow-md transition-shadow duration-300">
                        <h2 class="text-xl font-bold text-espresso mb-2 flex items-center">
                            <i class="fas fa-calendar-day text-dusty mr-3"></i>
                            Today's Schedule
                        </h2>
                        <p class="text-sm text-espresso/60 mb-6">
                            <span id="current-date"></span> • You have 3 classes today
                        </p>

                        <!-- Today's Classes Timeline -->
                        <div class="space-y-4">
                            <!-- Class 1 -->
                            <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30 hover:border-dusty/30 transition-colors duration-200">
                                <div class="w-20 text-center flex-shrink-0">
                                    <div class="text-lg font-bold text-dusty">
                                        9:00 AM
                                    </div>
                                    <div class="text-xs text-espresso/60">
                                        60 mins
                                    </div>
                                </div>
                                <div class="flex-1 ml-6">
                                    <div class="flex justify-between items-start mobile-stack">
                                        <div class="mobile-full mobile-mb-2 md:mb-0">
                                            <h3 class="font-semibold text-espresso text-lg">Mat Pilates Beginner</h3>
                                            <p class="text-sm text-espresso/70 mt-1">
                                                <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                Studio A • <span class="font-medium">12 students enrolled</span>
                                            </p>
                                        </div>
                                        <div class="flex items-center space-x-3 flex-shrink-0">
                                            <!-- QR Code Placeholder -->
                                            <div class="relative">
                                                <div class="w-14 h-14 bg-gray-50 border-2 border-dashed border-dusty rounded-lg flex items-center justify-center cursor-pointer hover:bg-blush transition-colors duration-200"
                                                     onclick="toggleQR('qr1')">
                                                    <i class="fas fa-qrcode text-dusty text-xl"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-3 flex items-center text-sm text-espresso/60">
                                        <span class="mr-4">
                                            <i class="fas fa-user mr-1"></i>Sarah Lim (You)
                                        </span>
                                        <span>
                                            <i class="fas fa-chart-bar mr-1"></i>Avg. Rating: 4.5/5
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Class 2 -->
                            <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30 hover:border-dusty/30 transition-colors duration-200">
                                <div class="w-20 text-center flex-shrink-0">
                                    <div class="text-lg font-bold text-dusty">
                                        2:00 PM
                                    </div>
                                    <div class="text-xs text-espresso/60">
                                        90 mins
                                    </div>
                                </div>
                                <div class="flex-1 ml-6">
                                    <div class="flex justify-between items-start mobile-stack">
                                        <div class="mobile-full mobile-mb-2 md:mb-0">
                                            <h3 class="font-semibold text-espresso text-lg">Reformer Intermediate</h3>
                                            <p class="text-sm text-espresso/70 mt-1">
                                                <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                Studio B • <span class="font-medium">8 students enrolled</span>
                                            </p>
                                        </div>
                                        <div class="flex items-center space-x-3 flex-shrink-0">
                                            <div class="relative">
                                                <div class="w-14 h-14 bg-gray-50 border-2 border-dashed border-dusty rounded-lg flex items-center justify-center cursor-pointer hover:bg-blush transition-colors duration-200"
                                                     onclick="toggleQR('qr2')">
                                                    <i class="fas fa-qrcode text-dusty text-xl"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-3 flex items-center text-sm text-espresso/60">
                                        <span class="mr-4">
                                            <i class="fas fa-user mr-1"></i>Sarah Lim (You)
                                        </span>
                                        <span>
                                            <i class="fas fa-chart-bar mr-1"></i>Avg. Rating: 4.7/5
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Class 3 -->
                            <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30 hover:border-dusty/30 transition-colors duration-200">
                                <div class="w-20 text-center flex-shrink-0">
                                    <div class="text-lg font-bold text-dusty">
                                        6:00 PM
                                    </div>
                                    <div class="text-xs text-espresso/60">
                                        75 mins
                                    </div>
                                </div>
                                <div class="flex-1 ml-6">
                                    <div class="flex justify-between items-start mobile-stack">
                                        <div class="mobile-full mobile-mb-2 md:mb-0">
                                            <h3 class="font-semibold text-espresso text-lg">Advanced Pilates</h3>
                                            <p class="text-sm text-espresso/70 mt-1">
                                                <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                Studio C • <span class="font-medium">10 students enrolled</span>
                                            </p>
                                        </div>
                                        <div class="flex items-center space-x-3 flex-shrink-0">
                                            <div class="relative">
                                                <div class="w-14 h-14 bg-gray-50 border-2 border-dashed border-dusty rounded-lg flex items-center justify-center cursor-pointer hover:bg-blush transition-colors duration-200"
                                                     onclick="toggleQR('qr3')">
                                                    <i class="fas fa-qrcode text-dusty text-xl"></i>
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
                        </div>
                    </div>

                    <!-- WEEK OVERVIEW -->
                    <div class="bg-white rounded-xl border border-petal p-6 shadow-sm hover:shadow-md transition-shadow duration-300">
                        <div class="flex items-center justify-between mb-6">
                            <h2 class="text-xl font-bold text-espresso flex items-center">
                                <i class="fas fa-calendar text-dusty mr-3"></i>
                                Week Overview
                            </h2>
                            <span class="text-sm text-espresso/60" id="current-week-range">
                                Feb 6 - Feb 12
                            </span>
                        </div>

                        <!-- Weekly Calendar Grid -->
                        <div class="mb-8">
                            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-7 gap-3" id="week-calendar-grid">
                                <!-- Will be populated by JavaScript -->
                            </div>
                        </div>

                        <div class="w-full pt-6 border-t border-petal">
                            <h4 class="font-medium text-espresso mb-4">This Week Summary</h4>

                            <!-- Use SAME 7-column grid as calendar -->
                            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-7 gap-3 w-full">

                                <!-- Total Confirm Class (span 4/7) -->
                                <div class="md:col-span-4 col-span-2 sm:col-span-2">
                                    <div class="text-center p-6 rounded-lg bg-successBg/20 border border-successBg/30 w-full h-full">
                                        <div class="text-2xl font-bold text-successTextDark">8</div>
                                        <div class="text-sm text-espresso/70 mt-1">Total Confirm Class</div>
                                    </div>
                                </div>

                                <!-- Pending Relief (span 3/7) -->
                                <div class="md:col-span-3 col-span-2 sm:col-span-1">
                                    <div class="text-center p-6 rounded-lg bg-warningBg/20 border border-warningBg/30 w-full h-full">
                                        <div class="text-2xl font-bold text-warningText">3</div>
                                        <div class="text-sm text-espresso/70 mt-1">Pending Relief</div>
                                    </div>
                                </div>

                            </div>
                        </div>


                    </div>
                </div>
            </div>
        </main>

        <!-- QR Code Modals -->
        <div class="qr-overlay" id="overlay-qr1" onclick="closeAllQR()"></div>
        <div class="qr-expanded" id="qr1">
            <button class="qr-close-btn" onclick="closeAllQR()">
                <i class="fas fa-times"></i>
            </button>
            <h4 class="font-semibold text-espresso mb-3">Mat Pilates Beginner</h4>
            <p class="text-sm text-espresso/70 mb-6">
                9:00 AM • Studio A
            </p>
            <img src="../qr_codes/dummy.png" alt="QR Code for Mat Pilates Beginner">
            <button onclick="location.href = 'feedback.jsp?classID=101&instructorID=1'" 
                    class="mt-6 w-full bg-dusty text-whitePure py-3 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                <i class="fas fa-chart-bar mr-2"></i>Submit Feedback
            </button>
        </div>

        <div class="qr-overlay" id="overlay-qr2" onclick="closeAllQR()"></div>
        <div class="qr-expanded" id="qr2">
            <button class="qr-close-btn" onclick="closeAllQR()">
                <i class="fas fa-times"></i>
            </button>
            <h4 class="font-semibold text-espresso mb-3">Reformer Intermediate</h4>
            <p class="text-sm text-espresso/70 mb-6">
                2:00 PM • Studio B
            </p>
            <img src="../qr_codes/dummy.png" alt="QR Code for Reformer Intermediate">
            <button onclick="location.href = 'feedback.jsp?classID=102&instructorID=1'" 
                    class="mt-6 w-full bg-dusty text-whitePure py-3 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                <i class="fas fa-chart-bar mr-2"></i>View Feedback
            </button>
        </div>

        <div class="qr-overlay" id="overlay-qr3" onclick="closeAllQR()"></div>
        <div class="qr-expanded" id="qr3">
            <button class="qr-close-btn" onclick="closeAllQR()">
                <i class="fas fa-times"></i>
            </button>
            <h4 class="font-semibold text-espresso mb-3">Advanced Pilates</h4>
            <p class="text-sm text-espresso/70 mb-6">
                6:00 PM • Studio C
            </p>
            <img src="../qr_codes/dummy.png" alt="QR Code for Advanced Pilates">
            <button onclick="location.href = 'feedback.jsp?classID=103&instructorID=1'" 
                    class="mt-6 w-full bg-dusty text-whitePure py-3 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                <i class="fas fa-chart-bar mr-2"></i>View Feedback
            </button>
        </div>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
                document.addEventListener('DOMContentLoaded', function () {
                    // Set current date
                    const now = new Date();
                    const options = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'};
                    document.getElementById('current-date').textContent = now.toLocaleDateString('en-US', options);

                    // Initialize weekly calendar grid
                    initializeWeekCalendarGrid();

                    // Close QR when clicking outside
                    document.addEventListener('click', function (event) {
                        if (event.target.classList.contains('qr-overlay')) {
                            closeAllQR();
                        }
                    });

                    // Close QR with Escape key
                    document.addEventListener('keydown', function (event) {
                        if (event.key === 'Escape') {
                            closeAllQR();
                        }
                    });
                });

                function initializeWeekCalendarGrid() {
                    const weekGrid = document.getElementById('week-calendar-grid');

                    // Week data: Feb 5 to Feb 11, 2026 (Today: Feb 6)
                    const weekData = [
                        {
                            dayName: "Thu",
                            date: 5,
                            isToday: false,
                            classes: [
                                {title: "Morning Flow", time: "8:00 AM", type: "confirm"}
                            ]
                        },
                        {
                            dayName: "Fri",
                            date: 6,
                            isToday: true,
                            classes: [
                                {title: "Mat Pilates Beginner", time: "9:00 AM", type: "confirm"},
                                {title: "Reformer Intermediate", time: "2:00 PM", type: "confirm"},
                                {title: "Advanced Pilates", time: "6:00 PM", type: "confirm"}
                            ]
                        },
                        {
                            dayName: "Sat",
                            date: 7,
                            isToday: false,
                            classes: [
                                {title: "Pilates for Seniors", time: "10:00 AM", type: "pending"},
                                {title: "Weekend Yoga", time: "3:00 PM", type: "confirm"}
                            ]
                        },
                        {
                            dayName: "Sun",
                            date: 8,
                            isToday: false,
                            classes: []
                        },
                        {
                            dayName: "Mon",
                            date: 9,
                            isToday: false,
                            classes: [
                                {title: "Core Strength", time: "7:00 PM", type: "pending"}
                            ]
                        },
                        {
                            dayName: "Tue",
                            date: 10,
                            isToday: false,
                            classes: [
                                {title: "Postnatal Pilates", time: "11:00 AM", type: "confirm"},
                                {title: "Evening Stretch", time: "6:30 PM", type: "pending"}
                            ]
                        },
                        {
                            dayName: "Wed",
                            date: 11,
                            isToday: false,
                            classes: [
                                {title: "Corporate Wellness", time: "4:30 PM", type: "confirm"}
                            ]
                        }
                    ];

                    let weekHTML = '';
                    for (let i = 0; i < weekData.length; i++) {
                        const day = weekData[i];
                        const isToday = day.date === 6;

                        weekHTML += '<div class="bg-cloud border border-petal rounded-lg p-4 min-h-[140px] hover:border-dusty/30 transition-colors cursor-pointer ' + (isToday ? 'bg-gradient-to-br from-blush to-petal/50 border-dusty' : '') + '">';
                        weekHTML += '<div class="flex justify-between items-center mb-3 pb-2 border-b border-petal">';
                        weekHTML += '<span class="font-semibold text-espresso ' + (isToday ? 'text-dusty' : '') + '">' + day.dayName + '</span>';
                        weekHTML += '<span class="text-sm ' + (isToday ? 'bg-dusty text-white' : 'bg-gray-100 text-espresso/70') + ' px-2 py-1 rounded">Feb ' + day.date + '</span>';
                        weekHTML += '</div>';
                        weekHTML += '<div class="week-day-classes">';

                        if (day.classes.length > 0) {
                            for (let j = 0; j < day.classes.length; j++) {
                                const cls = day.classes[j];
                                weekHTML += '<div class="week-class-item ' + cls.type + '">';
                                weekHTML += '<div class="week-class-title">' + cls.title + '</div>';
                                weekHTML += '<div class="week-class-time">' + cls.time + '</div>';
                                weekHTML += '</div>';
                            }
                        } else {
                            weekHTML += '<div class="text-center text-espresso/40 text-xs py-4">';
                            weekHTML += 'No classes';
                            weekHTML += '</div>';
                        }

                        weekHTML += '</div></div>';
                    }

                    weekGrid.innerHTML = weekHTML;

                    // Add click handlers to each day
                    const dayElements = document.querySelectorAll('#week-calendar-grid > div');
                    for (let i = 0; i < dayElements.length; i++) {
                        dayElements[i].addEventListener('click', function () {
                            const dayData = weekData[i];
                            if (dayData.classes.length > 0) {
                                let message = dayData.dayName + ', Feb ' + dayData.date + ':\n\n';
                                for (let j = 0; j < dayData.classes.length; j++) {
                                    const cls = dayData.classes[j];
                                    const statusText = cls.type === 'confirm' ? 'Confirm Placement' : 'Pending Relief';
                                    message += '• ' + cls.title + ' (' + cls.time + ') - ' + statusText + '\n';
                                }
                                alert(message);
                            }
                        });
                    }
                }

                function toggleQR(qrId) {
                    closeAllQR();
                    const qrElement = document.getElementById(qrId);
                    const overlayElement = document.getElementById('overlay-' + qrId);

                    if (qrElement) {
                        qrElement.classList.add('show');
                    }
                    if (overlayElement) {
                        overlayElement.classList.add('show');
                    }
                }

                function closeAllQR() {
                    document.querySelectorAll('.qr-expanded.show').forEach(qr => {
                        qr.classList.remove('show');
                    });
                    document.querySelectorAll('.qr-overlay.show').forEach(overlay => {
                        overlay.classList.remove('show');
                    });
                }
        </script>

    </body>
</html>