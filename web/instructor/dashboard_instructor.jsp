<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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

            /* QR Code Styles */
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
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 1000;
                background: white;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 25px;
                display: none;
                width: 280px;
                text-align: center;
                border: 3px solid #F2D1D1;
            }

            .qr-expanded img {
                width: 200px;
                height: 200px;
                margin-bottom: 15px;
                border-radius: 8px;
                border: 1px solid #EFE1E1;
            }

            .qr-expanded.show {
                display: block;
                animation: fadeInScale 0.3s ease-out;
            }

            /* Add overlay for when QR is shown */
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

            /* Add close button for QR modal */
            .qr-close-btn {
                position: absolute;
                top: 10px;
                right: 10px;
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
            }

            .qr-close-btn:hover {
                background: #F2D1D1;
                color: #B36D6D;
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

            .section-title.no-border {
                border-bottom: 0 !important;
                padding-bottom: 0 !important;
                margin-bottom: 0 !important;
            }

            /* Square QR Modal */
            .qr-expanded {
                width: 280px;
                height: 380px;
                padding: 25px;
            }

            .qr-expanded img {
                width: 200px;
                height: 200px;
                object-fit: contain;
            }

            /* Weekly Calendar Grid Styles */
            .week-calendar {
                display: grid;
                grid-template-columns: repeat(7, 1fr);
                gap: 0.5rem;
                margin-bottom: 1.5rem;
            }

            .week-day {
                background: #FDF8F8;
                border-radius: 10px;
                padding: 0.75rem;
                border: 1px solid #EFE1E1;
                min-height: 120px;
                transition: all 0.2s ease;
            }

            .week-day:hover {
                border-color: #F2D1D1;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(179, 109, 109, 0.1);
            }

            .week-day.today {
                background: linear-gradient(135deg, #F2D1D1 0%, #EFE1E1 100%);
                border: 2px solid #B36D6D;
            }

            .week-day-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 0.5rem;
                padding-bottom: 0.5rem;
                border-bottom: 1px solid #EFE1E1;
            }

            .week-day-name {
                font-size: 0.875rem;
                font-weight: 600;
                color: #3D3434;
            }

            .week-day-date {
                font-size: 0.75rem;
                color: #3D3434/70;
                background: white;
                padding: 0.125rem 0.375rem;
                border-radius: 4px;
            }

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
                color: #3D3434/70;
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

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <!-- MAIN CONTAINER: Welcome Sarah Lim! -->
            <div class="w-full main-container" style="max-width:1500px">

                <!-- Welcome Header -->
                <div class="welcome-header">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mobile-stack">
                        <div class="mobile-full mobile-mb-4 md:mb-0">
                            <div class="flex items-center mb-3">
                                <div class="w-16 h-16 rounded-full bg-whitePure border-4 border-whitePure shadow-md flex items-center justify-center mr-4">
                                    <c:choose>
                                        <c:when test="${not empty instructor.profileImageFilePath and instructor.profileImageFilePath != ''}">
                                            <img src="${instructor.profileImageFilePath}" alt="Profile Picture" class="w-full h-full rounded-full object-cover">
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-user text-dusty text-2xl"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div>
                                    <h1 class="text-3xl font-bold text-espresso">
                                        Welcome, <span class="text-dusty">${instructor.name}</span>!
                                    </h1>
                                    <p class="text-espresso/70 text-sm mt-1">
                                        <i class="fas fa-certificate text-dusty mr-2"></i>
                                        Certified Mat Pilates Instructor • Since <fmt:formatDate value="${instructor.dateJoined}" pattern="yyyy" />
                                    </p>
                                    <div class="flex items-center mt-3 space-x-4">
                                        <span class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-calendar-check text-dusty mr-2"></i>
                                            ${classesThisMonth} Classes This Month
                                        </span>
                                        <span class="text-sm bg-whitePure/80 px-3 py-1 rounded-full text-espresso">
                                            <i class="fas fa-star text-yellow-500 mr-2"></i>
                                            <c:choose>
                                                <c:when test="${avgRating != '0.0' and avgRating != '0'}">
                                                    ${avgRating} Avg Rating
                                                </c:when>
                                                <c:otherwise>
                                                    No ratings yet
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="flex space-x-6 mobile-full mobile-justify-center">
                            <div class="text-center bg-whitePure/90 p-4 rounded-xl shadow-sm min-w-[100px]">
                                <div class="text-3xl font-bold text-dusty">${todayClasses}</div>
                                <div class="text-sm text-espresso/70">Today</div>
                                <div class="text-xs text-espresso/50 mt-1">Classes</div>
                            </div>
                            <div class="text-center bg-whitePure/90 p-4 rounded-xl shadow-sm min-w-[100px]">
                                <div class="text-3xl font-bold text-teal">${availableClassesCount}</div>
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
                            <span id="current-date"></span> • You have ${todayClasses} classes today
                        </p>

                        <!-- Today's Classes Timeline -->
                        <div class="space-y-4">
                            <c:choose>
                                <c:when test="${not empty todaysClasses}">
                                    <c:forEach var="classItem" items="${todaysClasses}" varStatus="status">
                                        <div class="flex items-center p-4 rounded-lg border border-blush bg-cloud/30">
                                            <div class="w-20 text-center">
                                                <div class="text-lg font-bold text-dusty">
                                                    <fmt:formatDate value="${classItem.classStartTime}" pattern="h:mm a" />
                                                </div>
                                                <div class="text-xs text-espresso/60">
                                                    <c:set var="startTime" value="${classItem.classStartTime}" />
                                                    <c:set var="endTime" value="${classItem.classEndTime}" />
                                                    <c:if test="${not empty startTime and not empty endTime}">
                                                        <c:set var="durationMillis" value="${endTime.time - startTime.time}" />
                                                        <c:set var="durationMinutes" value="${durationMillis / (1000 * 60)}" />
                                                        <fmt:formatNumber value="${durationMinutes}" maxFractionDigits="0" /> mins
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="flex-1 ml-6">
                                                <div class="flex justify-between items-start mobile-stack">
                                                    <div class="mobile-full mobile-mb-2 md:mb-0">
                                                        <h3 class="font-semibold text-espresso text-lg">${classItem.className}</h3>
                                                        <p class="text-sm text-espresso/70">
                                                            <i class="fas fa-map-marker-alt mr-2 text-dusty"></i>
                                                            ${classItem.location} • <span class="font-medium">${classItem.enrolledStudents} students enrolled</span>
                                                        </p>
                                                    </div>
                                                    <div class="flex items-center space-x-3">
                                                        <!-- QR Code Placeholder -->
                                                        <div class="qr-container">
                                                            <div class="qr-placeholder" onclick="toggleQR('qr${status.index}')">
                                                                <i class="fas fa-qrcode text-dusty text-xl"></i>
                                                            </div>
                                                            <div class="qr-overlay" id="overlay-qr${status.index}" onclick="closeAllQR()"></div>
                                                            <div class="qr-expanded" id="qr${status.index}">
                                                                <button class="qr-close-btn" onclick="closeAllQR()">
                                                                    <i class="fas fa-times"></i>
                                                                </button>
                                                                <h4 class="font-semibold text-espresso mb-2">${classItem.className}</h4>
                                                                <p class="text-sm text-espresso/70 mb-4">
                                                                    <fmt:formatDate value="${classItem.classStartTime}" pattern="h:mm a" /> • ${classItem.location}
                                                                </p>
                                                                <c:choose>
                                                                    <c:when test="${not empty classItem.qrcodeFilePath}">
                                                                        <img src="${classItem.qrcodeFilePath}" alt="QR Code for ${classItem.className}">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <img src="qr_codes/dummy.PNG" alt="QR Code for ${classItem.className}">
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <button onclick="location.href = 'feedback.jsp?classID=${classItem.classID}&instructorID=${instructor.instructorID}'" 
                                                                        class="mt-4 w-full bg-dusty text-whitePure py-3 rounded-lg hover:bg-dustyHover transition-colors text-sm font-medium">
                                                                    <i class="fas fa-chart-bar mr-2"></i>View Feedback
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="mt-3 flex items-center text-sm text-espresso/60">
                                                    <span class="mr-4">
                                                        <i class="fas fa-user mr-1"></i>${instructor.name} (You)
                                                    </span>
                                                    <span>
                                                        <i class="fas fa-chart-bar mr-1"></i>Avg. Rating: ${avgRating}/5
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-8">
                                        <i class="fas fa-calendar-times text-dusty text-4xl mb-4"></i>
                                        <p class="text-espresso/70">No classes scheduled for today</p>
                                        <p class="text-sm text-espresso/50 mt-2">Check the available classes below to take on new sessions</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- WEEK OVERVIEW - NOW BELOW TODAY'S SCHEDULE -->
                    <div class="section-card">
                        <div class="flex items-center justify-between mb-4">
                            <h2 class="section-title" style="margin-bottom: 0; border-bottom: 0; padding-bottom: 0;">
                                <i class="fas fa-calendar text-dusty"></i>
                                Week Overview
                            </h2>
                            <span class="text-sm text-espresso/60" id="current-week-range">
                                <fmt:formatDate value="${weekStart}" pattern="MMM d" /> - <fmt:formatDate value="${weekEnd}" pattern="MMM d" />
                            </span>
                        </div>

                        <!-- Weekly Calendar Grid -->
                        <div class="mt-2 mb-6">
                            <div class="week-calendar" id="week-calendar-grid">
                                <!-- Will be populated by JavaScript -->
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-6 border-t border-petal">
                            <!-- Class Status Legend -->
                            <div>
                                <h4 class="font-medium text-espresso mb-3">Class Status</h4>
                                <div class="space-y-2">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center">
                                            <div class="w-3 h-3 rounded-full bg-successTextDark mr-2"></div>
                                            <span class="text-sm text-espresso/70">Your Class (Confirm Placement)</span>
                                        </div>
                                        <span class="text-xs text-espresso/60">
                                            <c:choose>
                                                <c:when test="${not empty weeklySummary and not empty weeklySummary.confirmedClasses}">
                                                    ${weeklySummary.confirmedClasses} classes
                                                </c:when>
                                                <c:otherwise>
                                                    0 classes
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center">
                                            <div class="w-3 h-3 rounded-full bg-warningText mr-2"></div>
                                            <span class="text-sm text-espresso/70">Pending Relief</span>
                                        </div>
                                        <span class="text-xs text-espresso/60">
                                            <c:choose>
                                                <c:when test="${not empty weeklySummary and not empty weeklySummary.pendingClasses}">
                                                    ${weeklySummary.pendingClasses} classes
                                                </c:when>
                                                <c:otherwise>
                                                    0 classes
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Quick Stats -->
                            <div>
                                <h4 class="font-medium text-espresso mb-3">This Week Summary</h4>
                                <div class="grid grid-cols-2 gap-3">
                                    <div class="text-center p-3 rounded-lg bg-successBg/20 border border-successBg/30">
                                        <div class="text-lg font-bold text-successTextDark">
                                            <c:choose>
                                                <c:when test="${not empty weeklySummary and not empty weeklySummary.confirmedClasses}">
                                                    ${weeklySummary.confirmedClasses}
                                                </c:when>
                                                <c:otherwise>
                                                    0
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="text-xs text-espresso/70">Total Confirm Class</div>
                                    </div>
                                    <div class="text-center p-3 rounded-lg bg-warningBg/20 border border-warningBg/30">
                                        <div class="text-lg font-bold text-warningText">
                                            <c:choose>
                                                <c:when test="${not empty weeklySummary and not empty weeklySummary.pendingClasses}">
                                                    ${weeklySummary.pendingClasses}
                                                </c:when>
                                                <c:otherwise>
                                                    0
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="text-xs text-espresso/70">Pending Relief</div>
                                    </div>
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
                            </div>

                            <div class="space-y-4">
                                <!-- Successfully Relieved Class -->
                                <c:if test="${not empty reliefUpdates}">
                                    <c:forEach var="update" items="${reliefUpdates}">
                                        <c:if test="${update.type == 'completed'}">
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
                                                    <c:forEach var="reliefClass" items="${update.classes}">
                                                        <div class="p-3 rounded-lg bg-whitePure/50 border border-successBg/30">
                                                            <div class="flex items-center justify-between mb-1">
                                                                <span class="font-medium text-espresso">${reliefClass.className}</span>
                                                                <span class="text-xs bg-successBg text-successTextDark px-2 py-1 rounded">COMPLETED</span>
                                                            </div>
                                                            <p class="text-sm text-espresso/70">
                                                                <i class="fas fa-calendar-alt mr-2"></i>
                                                                <fmt:formatDate value="${reliefClass.classDate}" pattern="EEEE, MMM d" /> • 
                                                                <fmt:formatDate value="${reliefClass.classStartTime}" pattern="h:mm a" /> • ${reliefClass.location}
                                                            </p>
                                                            <div class="flex items-center justify-between mt-2 text-xs">
                                                                <span class="text-espresso/60">
                                                                    <i class="fas fa-user-friends mr-1"></i>
                                                                    ${reliefClass.studentsAttended} students attended
                                                                </span>
                                                                <span class="text-successTextDark font-medium">
                                                                    <i class="fas fa-star mr-1"></i>
                                                                    <c:choose>
                                                                        <c:when test="${reliefClass.rating != 'No ratings yet'}">
                                                                            ${reliefClass.rating}/5 rating
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            No ratings yet
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                                <div class="mt-4 pt-3 border-t border-successBg/30">
                                                    <p class="text-xs text-espresso/60 text-center">
                                                        <i class="fas fa-info-circle mr-1"></i>
                                                        You successfully relieved ${update.count} classes this month
                                                    </p>
                                                </div>
                                            </div>
                                        </c:if>

                                        <!-- Upcoming Relief Opportunities -->
                                        <c:if test="${update.type == 'pending'}">
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
                                                <c:forEach var="position" items="${update.positions}">
                                                    <p class="text-sm text-espresso/80 mb-2">
                                                        <i class="fas fa-list-ol text-infoText mr-2"></i>
                                                        "${position.className}" - Position #${position.position}
                                                    </p>
                                                    <div class="flex items-center text-xs text-espresso/60 mb-3">
                                                        <i class="fas fa-info-circle mr-1"></i>
                                                        You will be notified if position #1 becomes available
                                                    </div>
                                                    <div class="bg-whitePure/50 p-3 rounded-lg border border-infoBg/30">
                                                        <p class="text-xs text-espresso/70 mb-1">Next in line:</p>
                                                        <div class="flex items-center justify-between">
                                                            <span class="text-sm font-medium text-espresso">${position.firstInLine}</span>
                                                            <span class="text-xs bg-infoBg text-infoText px-2 py-1 rounded">POSITION #1</span>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                <c:if test="${empty reliefUpdates}">
                                    <div class="text-center py-8">
                                        <i class="fas fa-exchange-alt text-dusty text-4xl mb-4"></i>
                                        <p class="text-espresso/70">No relief updates available</p>
                                        <p class="text-sm text-espresso/50 mt-2">Check available classes to take on relief opportunities</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- AVAILABLE CLASSES -->
                        <div class="section-card">
                            <div class="flex items-center justify-between mb-6">
                                <h2 class="section-title">
                                    <i class="fas fa-search text-teal"></i>
                                    Available Classes
                                </h2>
                                <a href="schedule_instructor.jsp" class="text-teal text-sm font-medium hover:text-tealHover">
                                    Browse All →
                                </a>
                            </div>

                            <div class="space-y-4">
                                <c:choose>
                                    <c:when test="${not empty availableClasses}">
                                        <c:forEach var="availableClass" items="${availableClasses}" varStatus="status">
                                            <div class="p-4 rounded-lg border <c:if test="${status.index == 0}">border-infoBg/30 bg-infoBg/5</c:if><c:if test="${status.index > 0}">border-blush/30</c:if>">
                                                <div class="flex justify-between items-start mb-2">
                                                    <h4 class="font-semibold text-espresso">${availableClass.className}</h4>
                                                    <c:choose>
                                                        <c:when test="${status.index == 0}">
                                                            <span class="text-xs bg-infoBg text-infoText px-2 py-1 rounded">NEW</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-xs bg-blush text-dusty px-2 py-1 rounded">OPEN</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <p class="text-sm text-espresso/70 mb-3">
                                                    <i class="fas fa-calendar-alt mr-2"></i>
                                                    <fmt:formatDate value="${availableClass.classDate}" pattern="EEEE, MMM d" /> • 
                                                    <fmt:formatDate value="${availableClass.classStartTime}" pattern="h:mm a" /> • ${availableClass.location}
                                                </p>
                                                <div class="flex justify-between items-center">
                                                    <span class="text-xs text-espresso/60">
                                                        <i class="fas fa-user-friends mr-1"></i>
                                                        ${availableClass.enrolledStudents}/${availableClass.noOfParticipant} spots filled
                                                    </span>
                                                    <span class="text-xs text-espresso/60">
                                                        <c:choose>
                                                            <c:when test="${availableClass.instructorCount == 0}">No instructors assigned</c:when>
                                                            <c:when test="${availableClass.instructorCount == 1}">1 instructor assigned</c:when>
                                                            <c:otherwise>${availableClass.instructorCount} instructors assigned</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-8">
                                            <i class="fas fa-search text-dusty text-4xl mb-4"></i>
                                            <p class="text-espresso/70">No available classes at the moment</p>
                                            <p class="text-sm text-espresso/50 mt-2">Check back later for new opportunities</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
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
            document.addEventListener('DOMContentLoaded', function () {
                // Set current date
                const now = new Date();
                const options = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'};
                document.getElementById('current-date').textContent = now.toLocaleDateString('en-US', options);

                // Set week range
                const weekStart = new Date(now);
                weekStart.setDate(now.getDate() - now.getDay());
                const weekEnd = new Date(weekStart);
                weekEnd.setDate(weekStart.getDate() + 6);

                const weekStartStr = weekStart.toLocaleDateString('en-US', {month: 'short', day: 'numeric'});
                const weekEndStr = weekEnd.toLocaleDateString('en-US', {month: 'short', day: 'numeric'});
                
                // Only update if JSTL didn't already set it
                const weekRangeElement = document.getElementById('current-week-range');
                if (weekRangeElement.textContent.trim() === '') {
                    document.getElementById('current-week-range').textContent = weekStartStr + ' - ' + weekEndStr;
                }

                // Initialize weekly calendar grid
                initializeWeekCalendarGrid();

                // Close QR when clicking outside overlay
                document.addEventListener('click', function (event) {
                    // If clicking on overlay, close all QR codes
                    if (event.target.classList.contains('qr-overlay')) {
                        closeAllQR();
                    }
                    // If clicking outside QR modal and not on QR placeholder
                    else if (!event.target.closest('.qr-expanded') && !event.target.closest('.qr-placeholder')) {
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

            // BUANG SEMUA FUNCTION initializeMiniCalendar() DAN PAKAIANNYA

            function initializeWeekCalendarGrid() {
                const weekGrid = document.getElementById('week-calendar-grid');
                const now = new Date();
                const today = now.getDate();

                // Check if weekClasses data is available from backend
                const hasWeekData = document.querySelector('input[name="weekDataExists"]') ? 
                                    document.querySelector('input[name="weekDataExists"]').value === 'true' : 
                                    ${not empty weekClasses};

                if (hasWeekData) {
                    // Use dynamic data from backend
                    const weekData = [
                        <c:forEach var="day" items="${weekClasses}" varStatus="status">
                        {
                            dayName: "${day.dayName}",
                            date: ${day.date},
                            isToday: ${day.isToday},
                            classes: [
                                <c:forEach var="cls" items="${day.classes}" varStatus="classStatus">
                                {
                                    title: "${fn:escapeXml(cls.title)}",
                                    time: "${cls.time}",
                                    type: "${cls.type}"
                                }<c:if test="${!classStatus.last}">,</c:if>
                                </c:forEach>
                            ]
                        }<c:if test="${!status.last}">,</c:if>
                        </c:forEach>
                    ];

                    let weekHTML = '';

                    weekData.forEach(day => {
                        const isToday = day.isToday;
                        let dayClass = 'week-day';
                        if (isToday) {
                            dayClass += ' today';
                        }

                        weekHTML += '<div class="' + dayClass + '">';
                        weekHTML += '<div class="week-day-header">';
                        weekHTML += '<span class="week-day-name">' + day.dayName + '</span>';
                        weekHTML += '<span class="week-day-date">' + day.date + '</span>';
                        weekHTML += '</div>';
                        weekHTML += '<div class="week-day-classes">';

                        if (day.classes.length > 0) {
                            day.classes.forEach(cls => {
                                weekHTML += '<div class="week-class-item ' + cls.type + '">';
                                weekHTML += '<div class="week-class-title">' + cls.title + '</div>';
                                weekHTML += '<div class="week-class-time">' + cls.time + '</div>';
                                weekHTML += '</div>';
                            });
                        } else {
                            weekHTML += '<div class="text-center text-espresso/40 text-xs py-4">';
                            weekHTML += 'No classes';
                            weekHTML += '</div>';
                        }

                        weekHTML += '</div>';
                        weekHTML += '</div>';
                    });

                    weekGrid.innerHTML = weekHTML;

                    // Add click handlers to each day
                    document.querySelectorAll('.week-day').forEach((dayElement, index) => {
                        dayElement.addEventListener('click', function () {
                            const dayData = weekData[index];
                            if (dayData.classes.length > 0) {
                                let message = dayData.dayName + ', ' + dayData.date + ':\n\n';
                                dayData.classes.forEach(cls => {
                                    message += '• ' + cls.title + ' (' + cls.time + ') - ' +
                                            (cls.type === 'confirm' ? 'Confirm Placement' : 'Pending Relief') + '\n';
                                });
                                alert(message);
                            }
                        });
                    });
                } else {
                    // Fallback to hardcoded data if no backend data
                    const weekData = [
                        {
                            dayName: "Sun",
                            date: 10,
                            classes: []
                        },
                        {
                            dayName: "Mon",
                            date: 11,
                            classes: [
                                {title: "Mat Pilates Beginner", time: "9:00 AM", type: "confirm"},
                                {title: "Advanced Pilates", time: "6:00 PM", type: "confirm"}
                            ]
                        },
                        {
                            dayName: "Tue",
                            date: 12,
                            classes: [
                                {title: "Reformer Intermediate", time: "2:00 PM", type: "confirm"}
                            ]
                        },
                        {
                            dayName: "Wed",
                            date: 13,
                            isToday: true,
                            classes: [
                                {title: "Mat Pilates Beginner", time: "9:00 AM", type: "confirm"},
                                {title: "Reformer Intermediate", time: "2:00 PM", type: "confirm"},
                                {title: "Advanced Pilates", time: "6:00 PM", type: "confirm"}
                            ]
                        },
                        {
                            dayName: "Thu",
                            date: 14,
                            classes: [
                                {title: "Morning Flow Class", time: "8:00 AM", type: "pending"}
                            ]
                        },
                        {
                            dayName: "Fri",
                            date: 15,
                            classes: [
                                {title: "Pilates for Seniors", time: "10:00 AM", type: "confirm"},
                                {title: "Evening Stretch", time: "5:30 PM", type: "pending"}
                            ]
                        },
                        {
                            dayName: "Sat",
                            date: 16,
                            classes: []
                        }
                    ];

                    let weekHTML = '';

                    weekData.forEach(day => {
                        const isToday = day.date === today;
                        let dayClass = 'week-day';
                        if (isToday) {
                            dayClass += ' today';
                        }

                        weekHTML += '<div class="' + dayClass + '">';
                        weekHTML += '<div class="week-day-header">';
                        weekHTML += '<span class="week-day-name">' + day.dayName + '</span>';
                        weekHTML += '<span class="week-day-date">' + day.date + '</span>';
                        weekHTML += '</div>';
                        weekHTML += '<div class="week-day-classes">';

                        if (day.classes.length > 0) {
                            day.classes.forEach(cls => {
                                weekHTML += '<div class="week-class-item ' + cls.type + '">';
                                weekHTML += '<div class="week-class-title">' + cls.title + '</div>';
                                weekHTML += '<div class="week-class-time">' + cls.time + '</div>';
                                weekHTML += '</div>';
                            });
                        } else {
                            weekHTML += '<div class="text-center text-espresso/40 text-xs py-4">';
                            weekHTML += 'No classes';
                            weekHTML += '</div>';
                        }

                        weekHTML += '</div>';
                        weekHTML += '</div>';
                    });

                    weekGrid.innerHTML = weekHTML;

                    // Add click handlers to each day
                    document.querySelectorAll('.week-day').forEach((dayElement, index) => {
                        dayElement.addEventListener('click', function () {
                            const dayData = weekData[index];
                            if (dayData.classes.length > 0) {
                                let message = dayData.dayName + ', ' + dayData.date + ':\n\n';
                                dayData.classes.forEach(cls => {
                                    message += '• ' + cls.title + ' (' + cls.time + ') - ' +
                                            (cls.type === 'confirm' ? 'Confirm Placement' : 'Pending Relief') + '\n';
                                });
                                alert(message);
                            }
                        });
                    });
                }
            }

            function toggleQR(qrId) {
                // Close all other QR codes first
                closeAllQR();

                const qrElement = document.getElementById(qrId);
                const overlayElement = document.getElementById('overlay-' + qrId);

                // Show current QR code
                qrElement.classList.add('show');
                if (overlayElement) {
                    overlayElement.classList.add('show');
                }
            }

            function closeAllQR() {
                // Close all QR modals and overlays
                document.querySelectorAll('.qr-expanded.show').forEach(qr => {
                    qr.classList.remove('show');
                });

                document.querySelectorAll('.qr-overlay.show').forEach(overlay => {
                    overlay.classList.remove('show');
                });
            }
        </script>

        <!-- Debug information - hidden by default -->
        <input type="hidden" name="weekDataExists" value="${not empty weekClasses}" />
        
        <div style="display: none; position: fixed; top: 10px; right: 10px; background: white; padding: 10px; border: 1px solid #ccc; z-index: 9999;">
            <h3>Debug Info:</h3>
            <p>Instructor: ${instructor.name}</p>
            <p>Today's Classes Count: ${todaysClasses != null ? todaysClasses.size() : 'null'}</p>
            <p>Week Classes Count: ${weekClasses != null ? weekClasses.size() : 'null'}</p>
            <p>Available Classes Count: ${availableClasses != null ? availableClasses.size() : 'null'}</p>
            <p>Relief Updates Count: ${reliefUpdates != null ? reliefUpdates.size() : 'null'}</p>
            <p>Current Date: ${currentDate}</p>
            <p>Week Start: ${weekStart}</p>
            <p>Week End: ${weekEnd}</p>
        </div>

    </body>
</html>