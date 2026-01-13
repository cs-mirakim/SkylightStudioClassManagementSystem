<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Message Page</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        
        <!-- Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        
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
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            blushHover: '#E8BEBE',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',
                            espresso: '#3D3434',
                            successText: '#1E3A1E',
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',
                            successBg: '#A5D6A7',
                            successTextDark: '#1B5E20',
                            warningBg: '#FFCC80',
                            warningText: '#E65100',
                            dangerBg: '#EF9A9A',
                            dangerText: '#B71C1C',
                            infoBg: '#A3C1D6',
                            infoText: '#2C5555',
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

        <!-- Header -->
        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">
            <div class="w-full bg-whitePure py-6 px-6 md:px-8 rounded-xl shadow-sm border border-blush flex-1 flex flex-col" style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-xl font-semibold mb-1 text-espresso">
                        Message for you
                    </h2>
                </div>

                <!-- Notifications Card -->
                <div class="bg-whitePure rounded-xl p-6 border border-blush shadow-sm mb-8">
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center">
                            <div class="p-2 rounded-lg bg-blush/10 mr-3">
                                <i class="fas fa-bell text-dusty text-lg"></i>
                            </div>
                            <div>
                                <h2 class="text-xl font-semibold text-espresso">
                                    Notifications
                                </h2>
                                <p class="text-xs text-espresso/60 mt-1">Stay updated with your class activities</p>
                            </div>
                        </div>
                        <div class="relative">
                            <span class="absolute -top-2 -right-2 bg-dangerText text-whitePure text-xs w-5 h-5 rounded-full flex items-center justify-center">3</span>
                        </div>
                    </div>
                    
                    <!-- Removed filter tabs -->
                    
                    <div class="notification-scroll space-y-3 max-h-80 overflow-y-auto pr-2">
                        <!-- Notification 1: New Class Created -->
                        <div class="p-4 rounded-lg bg-infoBg/5 border border-infoBg/20 status-unread notification-item">
                            <div class="flex items-start">
                                <div class="relative mr-3 flex-shrink-0">
                                    <div class="w-10 h-10 rounded-lg bg-teal/10 flex items-center justify-center">
                                        <i class="fas fa-plus text-teal"></i>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-start">
                                        <div>
                                            <h4 class="text-sm font-semibold text-espresso mb-1">New Class Available</h4>
                                            <p class="text-xs text-espresso/70 mb-2">"Weekend Reformer" class has been created and is ready for confirmation</p>
                                        </div>
                                        <span class="text-xs text-espresso/40 whitespace-nowrap ml-2">2 hours ago</span>
                                    </div>
                                    <div class="flex flex-wrap items-center gap-2 mt-2">
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-teal/10 text-teal">
                                            <i class="fas fa-clock text-xs mr-1"></i>Needs confirmation
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-calendar mr-1"></i>Sat & Sun • 9:00 AM
                                        </span>
                                    </div>
                                    <!-- Removed action buttons -->
                                </div>
                            </div>
                        </div>
                        
                        <!-- Notification 2: Class Reminder -->
                        <div class="p-4 rounded-lg bg-blush/10 border border-blush/20 notification-item">
                            <div class="flex items-start">
                                <div class="relative mr-3 flex-shrink-0">
                                    <div class="w-10 h-10 rounded-lg bg-dusty/10 flex items-center justify-center">
                                        <i class="fas fa-bell text-dusty"></i>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-start">
                                        <div>
                                            <h4 class="text-sm font-semibold text-espresso mb-1">Class Reminder</h4>
                                            <p class="text-xs text-espresso/70 mb-2">Your "Advanced Pilates" class is coming up in 3 days</p>
                                        </div>
                                        <span class="text-xs text-espresso/40 whitespace-nowrap ml-2">1 day ago</span>
                                    </div>
                                    <div class="flex flex-wrap items-center gap-2 mt-2">
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-dusty/10 text-dusty">
                                            <i class="fas fa-calendar-day mr-1"></i>Friday, Nov 15
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-clock mr-1"></i>10:00 AM - 11:30 AM
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-map-marker-alt mr-1"></i>Studio B
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Notification 3: Admin Cancellation -->
                        <div class="p-4 rounded-lg bg-dangerBg/5 border border-dangerBg/20 status-unread notification-item">
                            <div class="flex items-start">
                                <div class="relative mr-3 flex-shrink-0">
                                    <div class="w-10 h-10 rounded-lg bg-dangerText/10 flex items-center justify-center">
                                        <i class="fas fa-times-circle text-dangerText"></i>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-start">
                                        <div>
                                            <h4 class="text-sm font-semibold text-espresso mb-1">Class Cancelled</h4>
                                            <p class="text-xs text-espresso/70 mb-2">"Morning Flow" has been cancelled due to insufficient enrollment</p>
                                        </div>
                                        <span class="text-xs text-espresso/40 whitespace-nowrap ml-2">1 day ago</span>
                                    </div>
                                    <div class="flex flex-wrap items-center gap-2 mt-2">
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-dangerText/10 text-dangerText">
                                            <i class="fas fa-exclamation-triangle mr-1"></i>Cancelled
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-calendar-times mr-1"></i>Was scheduled for Nov 15
                                        </span>
                                    </div>
                                    <!-- Removed action buttons -->
                                </div>
                            </div>
                        </div>
                        
                        <!-- Notification 4: Pending Update -->
                        <div class="p-4 rounded-lg bg-warningBg/5 border border-warningBg/20 status-unread notification-item">
                            <div class="flex items-start">
                                <div class="relative mr-3 flex-shrink-0">
                                    <div class="w-10 h-10 rounded-lg bg-warningText/10 flex items-center justify-center">
                                        <i class="fas fa-user-clock text-warningText"></i>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-start">
                                        <div>
                                            <h4 class="text-sm font-semibold text-espresso mb-1">Waitlist Update</h4>
                                            <p class="text-xs text-espresso/70 mb-2">You've moved to position #1 for "Evening Reformer"</p>
                                        </div>
                                        <span class="text-xs text-espresso/40 whitespace-nowrap ml-2">2 days ago</span>
                                    </div>
                                    <div class="flex flex-wrap items-center gap-2 mt-2">
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-warningText/10 text-warningText">
                                            <i class="fas fa-chart-line mr-1"></i>Position #1
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-fire mr-1"></i>High chance of opening
                                        </span>
                                    </div>
                                    <!-- Removed action button -->
                                </div>
                            </div>
                        </div>
                        
                        <!-- Notification 5: Tomorrow's Class -->
                        <div class="p-4 rounded-lg bg-successBg/5 border border-successBg/20 notification-item">
                            <div class="flex items-start">
                                <div class="relative mr-3 flex-shrink-0">
                                    <div class="w-10 h-10 rounded-lg bg-successTextDark/10 flex items-center justify-center">
                                        <i class="fas fa-calendar-check text-successTextDark"></i>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex justify-between items-start">
                                        <div>
                                            <h4 class="text-sm font-semibold text-espresso mb-1">Class Tomorrow</h4>
                                            <p class="text-xs text-espresso/70 mb-2">"Mat Pilates Advanced" is scheduled for tomorrow</p>
                                        </div>
                                        <span class="text-xs text-espresso/40 whitespace-nowrap ml-2">3 days ago</span>
                                    </div>
                                    <div class="flex flex-wrap items-center gap-2 mt-2">
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-successTextDark/10 text-successTextDark">
                                            <i class="fas fa-users mr-1"></i>12 students enrolled
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-clock mr-1"></i>10:00 AM - 11:00 AM
                                        </span>
                                        <span class="inline-flex items-center text-xs px-2 py-1 rounded-full bg-blush/20 text-espresso/80">
                                            <i class="fas fa-map-marker-alt mr-1"></i>Studio A
                                        </span>
                                    </div>
                                    <!-- Removed action buttons -->
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- View all link -->
                    <div class="mt-6 pt-4 border-t border-blush">
                        <a href="#" 
                           class="block text-center text-sm text-espresso/70 hover:text-espresso py-2 hover:bg-blush/10 rounded-lg transition-colors">
                            <i class="fas fa-list mr-2"></i>View all notifications
                        </a>
                    </div>
                </div>

                <div class="mt-auto pt-10 text-center text-xs text-espresso/30 italic">
                </div>
            </div>
        </main>

        <!-- Footer -->
        <jsp:include page="../util/footer.jsp" />
        
        <!-- Sidebar -->
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
            // Highlight current page in sidebar
            document.addEventListener('DOMContentLoaded', function() {
                highlightCurrentPage();
            });
            
            function highlightCurrentPage() {
                // Highlight current page in sidebar
                const currentPage = 'inboxMessages_instructor.jsp';
                const sidebarLinks = document.querySelectorAll('#sidebar a');
                
                sidebarLinks.forEach(link => {
                    const href = link.getAttribute('href');
                    if (href && href.includes(currentPage)) {
                        link.classList.add('bg-blush/30', 'text-dusty', 'font-medium');
                        link.classList.remove('hover:bg-blush/20', 'text-espresso');
                    }
                });
            }
        </script>
    </body>
</html>