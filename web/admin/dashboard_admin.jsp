<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%
    // Check if user is admin
    if (!SessionUtil.checkAdminAccess(session)) {
        // Always redirect to login with appropriate message
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("../general/login.jsp?error=access_denied&message=Please_login_to_access_admin_pages");
        } else {
            // If logged in but not admin
            response.sendRedirect("../general/login.jsp?error=admin_access_required&message=Admin_privileges_required_to_access_this_page");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Admin Dashboard Page</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
                            condensed: ['Roboto Condensed', 'ui-sans-serif'],
                            mono: ['Roboto Mono', 'monospace']
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

                            /* Chips */
                            chipRose: '#FCE4EC',
                            chipSand: '#D9C5B2',
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-xl font-semibold mb-1 text-espresso">
                        Admin Dashboard Page
                    </h2>
                    <p class="text-sm text-espresso/60">
                        Welcome back, Admin! Here's an overview of your studio management.
                    </p>
                </div>

                <!-- Quick Links Section -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <!-- Schedule Management Card -->
                    <a href="schedule_admin.jsp" 
                       class="bg-whitePure border border-blush rounded-xl p-6 hover:border-dusty hover:shadow-md transition-all duration-300 group relative">
                        <div class="flex items-start justify-between">
                            <div>
                                <div class="w-12 h-12 rounded-lg bg-blush flex items-center justify-center mb-4 group-hover:bg-dusty group-hover:text-whitePure transition-colors">
                                    📅
                                </div>
                                <h3 class="font-semibold text-lg text-espresso mb-2">Schedule Management</h3>
                                <p class="text-sm text-espresso/60">Manage class schedules and timings</p>
                            </div>
                            <span class="bg-dusty text-whitePure text-xs font-semibold px-3 py-1 rounded-full">
                                5 classes today
                            </span>
                        </div>
                        <div class="mt-4 pt-4 border-t border-blush text-dusty font-medium text-sm">
                            View schedule →
                        </div>
                    </a>

                    <!-- Instructor Monitor Card -->
                    <a href="monitor_instructor.jsp"
                       class="bg-whitePure border border-blush rounded-xl p-6 hover:border-teal hover:shadow-md transition-all duration-300 group relative">
                        <div class="flex items-start justify-between">
                            <div>
                                <div class="w-12 h-12 rounded-lg bg-tealSoft/30 flex items-center justify-center mb-4 group-hover:bg-teal group-hover:text-whitePure transition-colors">
                                    👤
                                </div>
                                <h3 class="font-semibold text-lg text-espresso mb-2">Instructor Monitor</h3>
                                <p class="text-sm text-espresso/60">Track instructor performance and status</p>
                            </div>
                            <span class="bg-teal text-whitePure text-xs font-semibold px-3 py-1 rounded-full">
                                12 active
                            </span>
                        </div>
                        <div class="mt-4 pt-4 border-t border-blush text-teal font-medium text-sm">
                            Monitor instructors →
                        </div>
                    </a>

                    <!-- Registration Review Card -->
                    <a href="review_registration.jsp"
                       class="bg-whitePure border border-blush rounded-xl p-6 hover:border-warningText hover:shadow-md transition-all duration-300 group relative">
                        <div class="flex items-start justify-between">
                            <div>
                                <div class="w-12 h-12 rounded-lg bg-warningBg/50 flex items-center justify-center mb-4 group-hover:bg-warningText group-hover:text-whitePure transition-colors">
                                    📋
                                </div>
                                <h3 class="font-semibold text-lg text-espresso mb-2">Registration Review</h3>
                                <p class="text-sm text-espresso/60">Approve or reject new registrations</p>
                            </div>
                            <span class="bg-warningText text-whitePure text-xs font-semibold px-3 py-1 rounded-full">
                                3 pending
                            </span>
                        </div>
                        <div class="mt-4 pt-4 border-t border-blush text-warningText font-medium text-sm">
                            Review registrations →
                        </div>
                    </a>
                </div>

                <!-- Stats Overview -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <!-- Total Active Classes -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Active Classes</h3>
                            <span class="text-successTextDark text-sm font-medium flex items-center">
                                ↑ 12%
                                <svg class="w-4 h-4 ml-1" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L11 7.414V15a1 1 0 11-2 0V7.414L6.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
                                </svg>
                            </span>
                        </div>
                        <div class="text-3xl font-bold text-espresso mb-2">48</div>
                        <p class="text-sm text-espresso/50">Total active classes this month</p>
                    </div>

                    <!-- Total Active Instructors -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Active Instructors</h3>
                            <span class="text-successTextDark text-sm font-medium flex items-center">
                                ↑ 8%
                                <svg class="w-4 h-4 ml-1" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L11 7.414V15a1 1 0 11-2 0V7.414L6.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
                                </svg>
                            </span>
                        </div>
                        <div class="text-3xl font-bold text-espresso mb-2">12</div>
                        <p class="text-sm text-espresso/50">Instructors currently active</p>
                    </div>

                    <!-- Average Class Rating -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Avg. Class Rating</h3>
                            <span class="text-dusty text-sm font-medium">This month</span>
                        </div>
                        <div class="flex items-center">
                            <div class="text-3xl font-bold text-espresso mb-2 mr-3">4.7</div>
                            <div class="flex">
                                <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                </svg>
                                <span class="text-sm text-espresso/60 ml-1">/ 5.0</span>
                            </div>
                        </div>
                        <p class="text-sm text-espresso/50">Based on 156 feedbacks</p>
                    </div>

                    <!-- Upcoming Classes Today -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-medium text-espresso/70">Today's Classes</h3>
                            <span class="bg-blush text-dusty text-xs font-semibold px-2 py-1 rounded">
                                Next: 2 hours
                            </span>
                        </div>
                        <div class="text-3xl font-bold text-espresso mb-2">5</div>
                        <p class="text-sm text-espresso/50">Classes scheduled for today</p>
                    </div>
                </div>

                <!-- Charts Section -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                    <!-- Bar Chart - Monthly Classes -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-6">
                            <h3 class="font-semibold text-lg text-espresso">Monthly Classes Overview</h3>
                            <span class="text-sm text-espresso/50">Last 6 months</span>
                        </div>
                        <div class="h-72">
                            <canvas id="monthlyClassesChart"></canvas>
                        </div>
                    </div>

                    <!-- Pie Chart - Class Type Distribution -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-6">
                            <h3 class="font-semibold text-lg text-espresso">Class Type Distribution</h3>
                            <span class="text-sm text-espresso/50">Current Month</span>
                        </div>
                        <div class="h-72">
                            <canvas id="classTypeChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Recent Activities & Top Instructors -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <!-- Recent Activities -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-6">
                            <h3 class="font-semibold text-lg text-espresso">Recent Activities</h3>
                            <a href="#" class="text-dusty text-sm font-medium hover:text-dustyHover">View all →</a>
                        </div>
                        <div class="space-y-4">
                            <div class="flex items-start pb-4 border-b border-blush last:border-0">
                                <div class="w-8 h-8 rounded-full bg-successBg flex items-center justify-center mr-3 flex-shrink-0">
                                    <span class="text-successTextDark text-sm">✓</span>
                                </div>
                                <div class="flex-1">
                                    <p class="text-sm font-medium text-espresso">Class confirmed by Sarah Lim</p>
                                    <p class="text-xs text-espresso/50">Mat Pilates Advanced • 10:00 AM</p>
                                </div>
                                <span class="text-xs text-espresso/50">10 min ago</span>
                            </div>
                            <div class="flex items-start pb-4 border-b border-blush last:border-0">
                                <div class="w-8 h-8 rounded-full bg-infoBg flex items-center justify-center mr-3 flex-shrink-0">
                                    <span class="text-infoText text-sm">👤</span>
                                </div>
                                <div class="flex-1">
                                    <p class="text-sm font-medium text-espresso">New instructor approved</p>
                                    <p class="text-xs text-espresso/50">Michael Chen • Reformer Specialist</p>
                                </div>
                                <span class="text-xs text-espresso/50">1 hour ago</span>
                            </div>
                            <div class="flex items-start pb-4 border-b border-blush last:border-0">
                                <div class="w-8 h-8 rounded-full bg-blush flex items-center justify-center mr-3 flex-shrink-0">
                                    <span class="text-dusty text-sm">⭐</span>
                                </div>
                                <div class="flex-1">
                                    <p class="text-sm font-medium text-espresso">Feedback submitted</p>
                                    <p class="text-xs text-espresso/50">Morning Flow Class • Rating: 4.8/5</p>
                                </div>
                                <span class="text-xs text-espresso/50">2 hours ago</span>
                            </div>
                            <div class="flex items-start pb-4 border-b border-blush last:border-0">
                                <div class="w-8 h-8 rounded-full bg-warningBg flex items-center justify-center mr-3 flex-shrink-0">
                                    <span class="text-warningText text-sm">!</span>
                                </div>
                                <div class="flex-1">
                                    <p class="text-sm font-medium text-espresso">Class schedule updated</p>
                                    <p class="text-xs text-espresso/50">Evening Reformer • Moved to Studio B</p>
                                </div>
                                <span class="text-xs text-espresso/50">3 hours ago</span>
                            </div>
                            <div class="flex items-start">
                                <div class="w-8 h-8 rounded-full bg-chipSand/50 flex items-center justify-center mr-3 flex-shrink-0">
                                    <span class="text-espresso text-sm">📊</span>
                                </div>
                                <div class="flex-1">
                                    <p class="text-sm font-medium text-espresso">Monthly report generated</p>
                                    <p class="text-xs text-espresso/50">October 2024 Performance Summary</p>
                                </div>
                                <span class="text-xs text-espresso/50">5 hours ago</span>
                            </div>
                        </div>
                    </div>

                    <!-- Top Instructors -->
                    <div class="bg-whitePure border border-blush rounded-xl p-6">
                        <div class="flex items-center justify-between mb-6">
                            <h3 class="font-semibold text-lg text-espresso">Top Rated Instructors</h3>
                            <a href="monitor_instructor.jsp" class="text-dusty text-sm font-medium hover:text-dustyHover">View all →</a>
                        </div>
                        <div class="space-y-4">
                            <div class="flex items-center pb-4 border-b border-blush last:border-0">
                                <div class="w-10 h-10 rounded-full bg-blush flex items-center justify-center mr-3">
                                    <span class="text-dusty font-semibold">SL</span>
                                </div>
                                <div class="flex-1">
                                    <p class="font-medium text-espresso">Sarah Lim</p>
                                    <p class="text-sm text-espresso/60">Mat Pilates Specialist</p>
                                </div>
                                <div class="text-right">
                                    <div class="flex items-center justify-end mb-1">
                                        <span class="text-dusty font-bold mr-2">4.9</span>
                                        <div class="flex">
                                            <svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                            </svg>
                                        </div>
                                    </div>
                                    <span class="text-xs bg-successBg text-successTextDark px-2 py-1 rounded">48 classes</span>
                                </div>
                            </div>
                            <div class="flex items-center pb-4 border-b border-blush last:border-0">
                                <div class="w-10 h-10 rounded-full bg-tealSoft/30 flex items-center justify-center mr-3">
                                    <span class="text-teal font-semibold">MC</span>
                                </div>
                                <div class="flex-1">
                                    <p class="font-medium text-espresso">Michael Chen</p>
                                    <p class="text-sm text-espresso/60">Reformer Expert</p>
                                </div>
                                <div class="text-right">
                                    <div class="flex items-center justify-end mb-1">
                                        <span class="text-dusty font-bold mr-2">4.8</span>
                                        <div class="flex">
                                            <svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                            </svg>
                                        </div>
                                    </div>
                                    <span class="text-xs bg-infoBg text-infoText px-2 py-1 rounded">42 classes</span>
                                </div>
                            </div>
                            <div class="flex items-center">
                                <div class="w-10 h-10 rounded-full bg-chipRose flex items-center justify-center mr-3">
                                    <span class="text-espresso font-semibold">AJ</span>
                                </div>
                                <div class="flex-1">
                                    <p class="font-medium text-espresso">Aisha Johnson</p>
                                    <p class="text-sm text-espresso/60">Beginner Classes</p>
                                </div>
                                <div class="text-right">
                                    <div class="flex items-center justify-end mb-1">
                                        <span class="text-dusty font-bold mr-2">4.7</span>
                                        <div class="flex">
                                            <svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                            </svg>
                                        </div>
                                    </div>
                                    <span class="text-xs bg-warningBg text-warningText px-2 py-1 rounded">36 classes</span>
                                </div>
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
            // Initialize Monthly Classes Chart (Bar Chart)
            const monthlyCtx = document.getElementById('monthlyClassesChart').getContext('2d');
            const monthlyClassesChart = new Chart(monthlyCtx, {
                type: 'bar',
                data: {
                    labels: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
                    datasets: [{
                            label: 'Number of Classes',
                            data: [32, 38, 42, 45, 48, 52],
                            backgroundColor: '#B36D6D', // dusty
                            borderColor: '#965656', // dustyHover
                            borderWidth: 1,
                            borderRadius: 6,
                            hoverBackgroundColor: '#965656' // dustyHover
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            backgroundColor: '#3D3434', // espresso
                            titleColor: '#FDF8F8', // cloud
                            bodyColor: '#FDF8F8', // cloud
                            borderColor: '#B36D6D', // dusty
                            borderWidth: 1
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: '#EFE1E1' // petal
                            },
                            ticks: {
                                color: '#3D3434' // espresso
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                color: '#3D3434' // espresso
                            }
                        }
                    }
                }
            });

            // Initialize Class Type Chart (Pie Chart)
            const classTypeCtx = document.getElementById('classTypeChart').getContext('2d');
            const classTypeChart = new Chart(classTypeCtx, {
                type: 'pie',
                data: {
                    labels: ['Mat Pilates', 'Reformer'],
                    datasets: [{
                            data: [65, 35],
                            backgroundColor: [
                                '#B36D6D', // dusty for Mat Pilates
                                '#6D9B9B'  // teal for Reformer
                            ],
                            borderColor: '#FDF8F8', // cloud
                            borderWidth: 2,
                            hoverOffset: 12
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                color: '#3D3434', // espresso
                                padding: 20,
                                font: {
                                    size: 14
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: '#3D3434', // espresso
                            titleColor: '#FDF8F8', // cloud
                            bodyColor: '#FDF8F8', // cloud
                            callbacks: {
                                label: function (context) {
                                    const label = context.label || '';
                                    const value = context.raw || 0;
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = Math.round((value / total) * 100);
                                    return `${label}: ${value} classes (${percentage}%)`;
                                }
                            }
                        }
                    }
                }
            });

            // Add hover effects for cards
            document.addEventListener('DOMContentLoaded', function () {
                const cards = document.querySelectorAll('a[href*=".jsp"]');
                cards.forEach(card => {
                    card.addEventListener('mouseenter', function () {
                        this.style.transform = 'translateY(-4px)';
                    });
                    card.addEventListener('mouseleave', function () {
                        this.style.transform = 'translateY(0)';
                    });
                });
            });
        </script>

    </body>
</html>