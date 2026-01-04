<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Monitor Instructor - Skylight Studio</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Chart.js -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <!-- Date Range Picker -->
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
        <script src="https://cdn.jsdelivr.net/jquery/latest/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>

        <!-- jsPDF untuk export -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

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

                            /* Chips */
                            chipRose: '#FCE4EC',
                            chipSand: '#D9C5B2',
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>

        <style>
            /* Custom Scrollbar */
            .custom-scrollbar::-webkit-scrollbar {
                width: 6px;
            }
            .custom-scrollbar::-webkit-scrollbar-track {
                background: #FDF8F8;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background: #B36D6D;
                border-radius: 3px;
            }

            /* Modal Backdrop Blur */
            .modal-backdrop {
                backdrop-filter: blur(4px);
                background-color: rgba(0, 0, 0, 0.3);
            }

            /* Performance Rating Colors */
            .rating-excellent { color: #1B5E20; background-color: #A5D6A7; }
            .rating-good { color: #E65100; background-color: #FFCC80; }
            .rating-poor { color: #B71C1C; background-color: #EF9A9A; }

            /* Chart Customization */
            .chart-container {
                position: relative;
                height: 300px;
                width: 100%;
            }

            /* Remove pointer cursor from stats */
            .stats-container {
                cursor: default !important;
            }
            .stats-container:hover {
                transform: none !important;
                box-shadow: none !important;
            }

            /* Pagination styles */
            .pagination-btn {
                transition: all 0.2s ease;
            }
            .pagination-btn:hover:not(.disabled) {
                background-color: #F2D1D1;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Page Header -->
                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <h2 class="text-2xl font-semibold mb-1 text-espresso">
                        Monitor Instructor
                    </h2>
                    <p class="text-sm text-espresso/60">
                        Manage and monitor instructor performance, view details, and generate reports
                    </p>
                </div>

                <!-- Quick Stats Overview dengan susunan dan warna baru -->
                <div class="mb-8 grid grid-cols-1 md:grid-cols-4 gap-4">
                    <!-- Total Active Instructors -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">Total Active Instructors</p>
                                <p id="statActiveInstructors" class="text-2xl font-bold text-espresso">6</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-successBg flex items-center justify-center">
                                <svg class="w-6 h-6 text-successTextDark" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <!-- Total Inactive Instructors -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">Total Inactive</p>
                                <p id="statInactiveInstructors" class="text-2xl font-bold text-espresso">2</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-dangerBg flex items-center justify-center">
                                <svg class="w-6 h-6 text-dangerText" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <!-- Average Overall Rating -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">Avg. Overall Rating</p>
                                <p id="statAvgRating" class="text-2xl font-bold text-espresso">4.0</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-infoBg flex items-center justify-center">
                                <svg class="w-6 h-6 text-infoText" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>

                    <!-- New This Month -->
                    <div class="bg-petal p-4 rounded-lg border border-blush stats-container">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-espresso/60">New This Month</p>
                                <p id="statNewThisMonth" class="text-2xl font-bold text-espresso">1</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-chipRose flex items-center justify-center">
                                <svg class="w-6 h-6 text-dusty" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v3.586L7.707 9.293a1 1 0 00-1.414 1.414l2.828 2.829a1 1 0 101.415-1.415L11 10.586V7z" clip-rule="evenodd"/>
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filter Section dengan filter nama -->
                <div class="mb-6 bg-petal p-4 rounded-lg border border-blush">
                    <h3 class="text-lg font-medium mb-4 text-espresso">Filter Instructors</h3>
                    <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                        <!-- Name Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Instructor Name</label>
                            <select id="nameFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent">
                                <option value="">All Instructors</option>
                                <!-- Options akan diisi oleh JavaScript -->
                            </select>
                        </div>

                        <!-- Experience Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Experience</label>
                            <select id="experienceFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent">
                                <option value="">All Experience</option>
                                <option value="1">1 Year</option>
                                <option value="2">2 Years</option>
                                <option value="3">3 Years</option>
                                <option value="4">4 Years</option>
                                <option value="5+">5+ Years</option>
                            </select>
                        </div>

                        <!-- Date Joined Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Date Joined</label>
                            <input type="text" id="dateRangeFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent" placeholder="Select date range">
                        </div>

                        <!-- Status Filter -->
                        <div>
                            <label class="block text-sm font-medium text-espresso/70 mb-1">Status</label>
                            <select id="statusFilter" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-teal focus:border-transparent">
                                <option value="">All Status</option>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>

                        <!-- Filter Buttons -->
                        <div class="flex items-end space-x-2">
                            <button id="applyFilterBtn" class="px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors focus:outline-none focus:ring-2 focus:ring-dusty focus:ring-offset-2">
                                Apply Filters
                            </button>
                            <button id="resetFilterBtn" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors focus:outline-none focus:ring-2 focus:ring-dusty focus:ring-offset-2">
                                Reset
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Instructor List Table -->
                <div class="flex-1 overflow-hidden">
                    <div class="bg-whitePure rounded-lg border border-blush overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-blush">
                                <thead class="bg-petal">
                                    <tr>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Instructor</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Experience</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Date Joined</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Total Classes</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Overall Rating</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Status</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-espresso uppercase tracking-wider">Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="instructorTableBody" class="bg-whitePure divide-y divide-blush">
                                    <!-- Instructor rows will be generated by JavaScript -->
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        <div class="bg-petal px-6 py-4 border-t border-blush flex items-center justify-between">
                            <div class="text-sm text-espresso/60">
                                Showing <span id="paginationStart">1</span> to <span id="paginationEnd">5</span> of <span id="paginationTotal">8</span> instructors
                            </div>
                            <div class="flex space-x-2">
                                <button id="prevPageBtn" class="pagination-btn px-3 py-1 rounded border border-blush text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                    Previous
                                </button>
                                <div class="flex space-x-1" id="pageNumbers">
                                    <!-- Page numbers will be generated by JavaScript -->
                                </div>
                                <button id="nextPageBtn" class="pagination-btn px-3 py-1 rounded border border-blush text-espresso disabled:opacity-50 disabled:cursor-not-allowed">
                                    Next
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- View Details Modal -->
        <div id="detailsModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0 transition-opacity" onclick="closeDetails()"></div>

            <div class="fixed inset-0 overflow-y-auto">
                <div class="flex items-center justify-center min-h-full p-4">
                    <div class="relative bg-whitePure rounded-lg shadow-xl border border-blush w-full max-w-4xl">
                        <!-- Modal Header -->
                        <div class="flex items-center justify-between p-6 border-b border-blush">
                            <div>
                                <h3 class="text-xl font-semibold text-espresso">Instructor Details</h3>
                                <p class="text-sm text-espresso/60 mt-1">Complete profile information</p>
                            </div>
                            <button onclick="closeDetails()" class="text-espresso/40 hover:text-espresso">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>

                        <!-- Modal Content -->
                        <div class="p-6">
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <!-- Left Column - Profile -->
                                <div class="md:col-span-1">
                                    <div class="bg-petal rounded-lg p-4 border border-blush">
                                        <div class="flex flex-col items-center">
                                            <img id="detailProfileImg" class="w-32 h-32 rounded-full object-cover border-4 border-whitePure shadow mb-4" src="../profile_pictures/instructor/dummy.png" alt="Profile">
                                            <h4 id="detailName" class="text-lg font-semibold text-espresso">Sarah Chen</h4>
                                            <p id="detailEmail" class="text-sm text-espresso/60 mb-4">sarah.chen@email.com</p>

                                            <div class="w-full space-y-3">
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Phone</label>
                                                    <p id="detailPhone" class="text-sm text-espresso">+60 12-345 6789</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">NRIC</label>
                                                    <p id="detailNRIC" class="text-sm text-espresso">901234-56-7890</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Date of Birth</label>
                                                    <p id="detailBOD" class="text-sm text-espresso">15 June 1990</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Certification Section -->
                                    <div class="mt-4 bg-petal rounded-lg p-4 border border-blush">
                                        <h5 class="font-medium text-espresso mb-3">Certification</h5>
                                        <div class="space-y-2">
                                            <div class="flex items-center justify-between">
                                                <span class="text-sm text-espresso">Yoga Alliance RYT-500</span>
                                                <button onclick="viewCertification()" class="text-xs text-teal hover:text-tealHover px-2 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">View PDF</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right Column - Details -->
                                <div class="md:col-span-2">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <!-- Registration Details -->
                                        <div class="bg-petal rounded-lg p-4 border border-blush">
                                            <h5 class="font-medium text-espresso mb-3">Registration Details</h5>
                                            <div class="space-y-2">
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Register Date</label>
                                                    <p id="detailRegDate" class="text-sm text-espresso">14 Jan 2021 10:30 AM</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Registration Status</label>
                                                    <p id="detailRegStatus" class="text-sm text-espresso">
                                                        <span class="px-2 py-1 text-xs rounded-full bg-successBg text-successTextDark">Approved</span>
                                                    </p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">User Type</label>
                                                    <p id="detailUserType" class="text-sm text-espresso">Instructor</p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Professional Details -->
                                        <div class="bg-petal rounded-lg p-4 border border-blush">
                                            <h5 class="font-medium text-espresso mb-3">Professional Details</h5>
                                            <div class="space-y-2">
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Years of Experience</label>
                                                    <p id="detailExperience" class="text-sm text-espresso">5 years</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">Date Joined</label>
                                                    <p id="detailDateJoined" class="text-sm text-espresso">15 Jan 2021</p>
                                                </div>
                                                <div>
                                                    <label class="block text-xs font-medium text-espresso/50 mb-1">System Status</label>
                                                    <p id="detailStatus" class="text-sm text-espresso">
                                                        <span class="px-2 py-1 text-xs rounded-full bg-successBg text-successTextDark">Active</span>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Address -->
                                        <div class="md:col-span-2 bg-petal rounded-lg p-4 border border-blush">
                                            <h5 class="font-medium text-espresso mb-3">Address</h5>
                                            <p id="detailAddress" class="text-sm text-espresso">123 Fitness Street, Bukit Jalil, 57000 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur</p>
                                        </div>

                                        <!-- Performance Summary -->
                                        <div class="md:col-span-2 bg-petal rounded-lg p-4 border border-blush">
                                            <div class="flex items-center justify-between mb-3">
                                                <h5 class="font-medium text-espresso">Performance Summary</h5>
                                                <button onclick="showPerformance()" class="text-sm text-teal hover:text-tealHover flex items-center px-3 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">
                                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.414L11 9.586V6z" clip-rule="evenodd"/>
                                                    </svg>
                                                    View Detailed Performance
                                                </button>
                                            </div>
                                            <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                                                <div class="text-center">
                                                    <div id="statTotalClasses" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Total Classes</div>
                                                </div>
                                                <div class="text-center">
                                                    <div id="statCancelled" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Cancelled</div>
                                                </div>
                                                <div class="text-center">
                                                    <div id="statAvgRating" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Avg Rating</div>
                                                </div>
                                                <div class="text-center">
                                                    <div id="statFeedbacks" class="text-2xl font-bold text-espresso">0</div>
                                                    <div class="text-xs text-espresso/60">Feedbacks</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Separator and Action Buttons -->
                                    <div class="mt-8 pt-6 border-t border-blush flex justify-end space-x-3">
                                        <button onclick="exportPerformancePDF()" class="px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors flex items-center">
                                            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"/>
                                            </svg>
                                            Export Performance Report
                                        </button>
                                        <button onclick="closeDetails()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                            Close
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Performance Modal -->
        <div id="performanceModal" class="fixed inset-0 z-[60] hidden">
            <div class="fixed inset-0 bg-black/50" onclick="closePerformance()"></div>

            <div class="fixed inset-0 overflow-y-auto">
                <div class="flex items-center justify-center min-h-full p-4">
                    <div class="relative bg-whitePure rounded-lg shadow-xl border border-blush w-full max-w-6xl">
                        <!-- Modal Header -->
                        <div class="flex items-center justify-between p-6 border-b border-blush">
                            <div>
                                <h3 class="text-xl font-semibold text-espresso">Performance Analysis</h3>
                                <p class="text-sm text-espresso/60 mt-1" id="performanceInstructorName">Sarah Chen</p>
                            </div>
                            <div class="flex items-center space-x-4">
                                <!-- Time Period Selector -->
                                <select id="timePeriod" onchange="updateCharts()" class="px-3 py-1 border border-blush rounded-lg bg-whitePure text-sm focus:outline-none focus:ring-2 focus:ring-teal">
                                    <option value="3months">Last 3 Months</option>
                                    <option value="6months">Last 6 Months</option>
                                    <option value="1year">Last 1 Year</option>
                                    <option value="all">All Time</option>
                                </select>

                                <button onclick="closePerformance()" class="text-espresso/40 hover:text-espresso">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <!-- Modal Content -->
                        <div class="p-6">
                            <!-- Performance Metrics Cards -->
                            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfOverallRating">4.7</div>
                                    <div class="text-xs text-espresso/60">Overall Rating</div>
                                </div>
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfTotalClasses">142</div>
                                    <div class="text-xs text-espresso/60">Total Classes</div>
                                </div>
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfCancelled">8</div>
                                    <div class="text-xs text-espresso/60">Cancelled Classes</div>
                                </div>
                                <div class="bg-petal p-4 rounded-lg border border-blush">
                                    <div class="text-2xl font-bold text-espresso" id="perfCompletion">94%</div>
                                    <div class="text-xs text-espresso/60">Completion Rate</div>
                                </div>
                            </div>

                            <!-- Charts Grid -->
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                                <!-- Category Ratings Chart -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Rating by Category</h4>
                                    <div class="chart-container">
                                        <canvas id="categoryChart"></canvas>
                                    </div>
                                </div>

                                <!-- Monthly Trend Chart -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Monthly Performance Trend</h4>
                                    <div class="chart-container">
                                        <canvas id="trendChart"></canvas>
                                    </div>
                                </div>

                                <!-- Class Distribution Chart -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Class Distribution</h4>
                                    <div class="chart-container">
                                        <canvas id="distributionChart"></canvas>
                                    </div>
                                </div>

                                <!-- Rating Breakdown Table -->
                                <div class="bg-whitePure p-4 rounded-lg border border-blush">
                                    <h4 class="font-medium text-espresso mb-4">Rating Breakdown</h4>
                                    <div class="overflow-x-auto">
                                        <table class="min-w-full">
                                            <thead>
                                                <tr class="border-b border-blush">
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Category</th>
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Average</th>
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Highest</th>
                                                    <th class="text-left py-2 text-sm font-medium text-espresso">Lowest</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr class="border-b border-blush/30">
                                                    <td class="py-3 text-sm text-espresso">Teaching Skill</td>
                                                    <td class="py-3">
                                                        <span class="px-2 py-1 text-xs rounded-full rating-excellent">4.8</span>
                                                    </td>
                                                    <td class="py-3 text-sm text-espresso">5.0 (Jan 2024)</td>
                                                    <td class="py-3 text-sm text-espresso">4.5 (Mar 2024)</td>
                                                </tr>
                                                <tr class="border-b border-blush/30">
                                                    <td class="py-3 text-sm text-espresso">Communication</td>
                                                    <td class="py-3">
                                                        <span class="px-2 py-1 text-xs rounded-full rating-excellent">4.7</span>
                                                    </td>
                                                    <td class="py-3 text-sm text-espresso">5.0 (Feb 2024)</td>
                                                    <td class="py-3 text-sm text-espresso">4.3 (Apr 2024)</td>
                                                </tr>
                                                <tr class="border-b border-blush/30">
                                                    <td class="py-3 text-sm text-espresso">Support & Interaction</td>
                                                    <td class="py-3">
                                                        <span class="px-2 py-1 text-xs rounded-full rating-good">4.2</span>
                                                    </td>
                                                    <td class="py-3 text-sm text-espresso">4.8 (Dec 2023)</td>
                                                    <td class="py-3 text-sm text-espresso">3.8 (Jan 2024)</td>
                                                </tr>
                                                <tr>
                                                    <td class="py-3 text-sm text-espresso">Punctuality</td>
                                                    <td class="py-3">
                                                        <span class="px-2 py-1 text-xs rounded-full rating-good">4.5</span>
                                                    </td>
                                                    <td class="py-3 text-sm text-espresso">5.0 (Multiple)</td>
                                                    <td class="py-3 text-sm text-espresso">4.0 (Feb 2024)</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <!-- Insights Section -->
                            <div class="bg-petal p-4 rounded-lg border border-blush mb-6">
                                <h4 class="font-medium text-espresso mb-3">Performance Insights</h4>
                                <div class="space-y-2">
                                    <div class="flex items-start">
                                        <svg class="w-5 h-5 text-successTextDark mt-0.5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                                        </svg>
                                        <p class="text-sm text-espresso"><strong>Strengths:</strong> Excellent teaching skills and communication. Consistently receives high marks for clarity and expertise.</p>
                                    </div>
                                    <div class="flex items-start">
                                        <svg class="w-5 h-5 text-warningText mt-0.5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                                        </svg>
                                        <p class="text-sm text-espresso"><strong>Areas for Improvement:</strong> Student interaction scores show some variability. Consider implementing more group activities.</p>
                                    </div>
                                    <div class="flex items-start">
                                        <svg class="w-5 h-5 text-teal mt-0.5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M12 7a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0V8.414l-4.293 4.293a1 1 0 01-1.414 0L8 10.414l-4.293 4.293a1 1 0 01-1.414-1.414l5-5a1 1 0 011.414 0L11 10.586 14.586 7H12z" clip-rule="evenodd"/>
                                        </svg>
                                        <p class="text-sm text-espresso"><strong>Trend:</strong> Overall performance shows positive trend over the last 6 months with 15% improvement in support interaction scores.</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="flex justify-end space-x-3">
                                <button onclick="exportDetailedPDF()" class="px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors flex items-center">
                                    <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"/>
                                    </svg>
                                    Export This Report
                                </button>
                                <button onclick="closePerformance()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                    Close
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Certification Viewer Modal -->
        <div id="certModal" class="fixed inset-0 z-[70] hidden">
            <div class="fixed inset-0 bg-black/70" onclick="closeCert()"></div>

            <div class="fixed inset-0 flex items-center justify-center p-2 sm:p-4">
                <div class="bg-whitePure rounded-lg shadow-2xl w-full max-w-5xl h-[95vh] flex flex-col">

                    <div class="flex items-center justify-between p-4 border-b border-blush">
                        <h3 id="certModalTitle" class="text-lg font-semibold text-espresso">Certification Document</h3>
                        <button onclick="closeCert()" class="text-espresso/40 hover:text-espresso">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>

                    <div class="flex-1 overflow-hidden p-2">
                        <iframe id="certFrame" src="../certifications/instructor/dummy.pdf" class="w-full h-full border border-blush rounded"></iframe>
                    </div>

                    <div class="p-4 border-t border-blush flex justify-end">
                        <button onclick="closeCert()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                            Close
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Deactivate/Activate Confirmation Modal -->
        <div id="activateDeactivateModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0" onclick="closeActivateDeactivate()"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-lg shadow-xl border border-blush w-full max-w-md">
                    <div class="p-6">
                        <div id="modalIcon" class="flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full">
                            <!-- Icon akan diisi oleh JavaScript -->
                        </div>
                        <h3 id="modalTitle" class="text-lg font-semibold text-center text-espresso mb-2"></h3>
                        <p id="modalText" class="text-sm text-espresso/70 text-center mb-6">
                        </p>
                        <div class="flex justify-center space-x-3">
                            <button onclick="confirmActivateDeactivate()" id="confirmButton" class="px-4 py-2 text-whitePure rounded-lg transition-colors">
                                Confirm
                            </button>
                            <button onclick="closeActivateDeactivate()" class="px-4 py-2 border border-dusty text-dusty rounded-lg hover:bg-blush transition-colors">
                                Cancel
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <script>
                                // Dummy instructor data - 8 instructors
                                var instructors = {
                                    1: {
                                        name: "Sarah Chen",
                                        email: "sarah.chen@email.com",
                                        phone: "+60 12-345 6789",
                                        nric: "901234-56-7890",
                                        bod: "15 June 1990",
                                        regDate: "14 Jan 2021 10:30 AM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "5 years",
                                        dateJoined: "15 Jan 2021",
                                        status: "active",
                                        address: "123 Fitness Street, Bukit Jalil, 57000 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur",
                                        totalClasses: 142,
                                        cancelledClasses: 8,
                                        completedClasses: 134,
                                        avgRating: 4.7,
                                        totalFeedbacks: 89,
                                        categoryRatings: {
                                            teaching: 4.8,
                                            communication: 4.7,
                                            support: 4.2,
                                            punctuality: 4.5
                                        },
                                        monthlyTrend: [4.5, 4.6, 4.4, 4.7, 4.8, 4.7],
                                        classDistribution: {
                                            completed: 134,
                                            cancelled: 8
                                        }
                                    },
                                    2: {
                                        name: "Michael Wong",
                                        email: "michael.w@email.com",
                                        phone: "+60 13-456 7890",
                                        nric: "891234-12-3456",
                                        bod: "22 March 1988",
                                        regDate: "21 Mar 2023 09:15 AM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "2 years",
                                        dateJoined: "22 Mar 2023",
                                        status: "active",
                                        address: "456 Wellness Avenue, Damansara Heights, 50490 Kuala Lumpur",
                                        totalClasses: 67,
                                        cancelledClasses: 3,
                                        completedClasses: 64,
                                        avgRating: 3.8,
                                        totalFeedbacks: 45,
                                        categoryRatings: {
                                            teaching: 4.0,
                                            communication: 3.9,
                                            support: 3.5,
                                            punctuality: 3.8
                                        },
                                        monthlyTrend: [3.6, 3.7, 3.8, 3.9, 4.0, 3.9],
                                        classDistribution: {
                                            completed: 64,
                                            cancelled: 3
                                        }
                                    },
                                    3: {
                                        name: "Aisha Patel",
                                        email: "aisha.p@email.com",
                                        phone: "+60 14-567 8901",
                                        nric: "950123-78-9012",
                                        bod: "10 October 1995",
                                        regDate: "9 Aug 2024 02:45 PM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "1 year",
                                        dateJoined: "10 Aug 2024",
                                        status: "active",
                                        address: "789 Yoga Lane, Bangsar South, 59200 Kuala Lumpur",
                                        totalClasses: 23,
                                        cancelledClasses: 2,
                                        completedClasses: 21,
                                        avgRating: 3.2,
                                        totalFeedbacks: 18,
                                        categoryRatings: {
                                            teaching: 3.5,
                                            communication: 3.3,
                                            support: 2.8,
                                            punctuality: 3.2
                                        },
                                        monthlyTrend: [3.0, 3.1, 3.2, 3.3, 3.2, 3.1],
                                        classDistribution: {
                                            completed: 21,
                                            cancelled: 2
                                        }
                                    },
                                    4: {
                                        name: "David Lee",
                                        email: "david.lee@email.com",
                                        phone: "+60 16-789 0123",
                                        nric: "881122-33-4455",
                                        bod: "5 May 1985",
                                        regDate: "15 Feb 2020 11:00 AM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "4 years",
                                        dateJoined: "16 Feb 2020",
                                        status: "inactive",
                                        address: "321 Fitness Road, Mont Kiara, 50480 Kuala Lumpur",
                                        totalClasses: 210,
                                        cancelledClasses: 12,
                                        completedClasses: 198,
                                        avgRating: 4.5,
                                        totalFeedbacks: 156,
                                        categoryRatings: {
                                            teaching: 4.6,
                                            communication: 4.4,
                                            support: 4.3,
                                            punctuality: 4.7
                                        },
                                        monthlyTrend: [4.4, 4.5, 4.5, 4.6, 4.5, 4.4],
                                        classDistribution: {
                                            completed: 198,
                                            cancelled: 12
                                        }
                                    },
                                    5: {
                                        name: "Lisa Tan",
                                        email: "lisa.tan@email.com",
                                        phone: "+60 17-890 1234",
                                        nric: "920304-55-6677",
                                        bod: "30 April 1992",
                                        regDate: "10 Nov 2022 03:30 PM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "3 years",
                                        dateJoined: "11 Nov 2022",
                                        status: "active",
                                        address: "654 Health Boulevard, Subang Jaya, 47600 Selangor",
                                        totalClasses: 98,
                                        cancelledClasses: 5,
                                        completedClasses: 93,
                                        avgRating: 4.3,
                                        totalFeedbacks: 76,
                                        categoryRatings: {
                                            teaching: 4.4,
                                            communication: 4.2,
                                            support: 4.1,
                                            punctuality: 4.5
                                        },
                                        monthlyTrend: [4.1, 4.2, 4.3, 4.4, 4.3, 4.2],
                                        classDistribution: {
                                            completed: 93,
                                            cancelled: 5
                                        }
                                    },
                                    6: {
                                        name: "Raj Kumar",
                                        email: "raj.kumar@email.com",
                                        phone: "+60 18-901 2345",
                                        nric: "870909-11-2233",
                                        bod: "9 September 1987",
                                        regDate: "5 Jun 2021 09:45 AM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "5+ years",
                                        dateJoined: "6 Jun 2021",
                                        status: "active",
                                        address: "987 Wellness Drive, Petaling Jaya, 46200 Selangor",
                                        totalClasses: 178,
                                        cancelledClasses: 7,
                                        completedClasses: 171,
                                        avgRating: 4.6,
                                        totalFeedbacks: 132,
                                        categoryRatings: {
                                            teaching: 4.7,
                                            communication: 4.5,
                                            support: 4.4,
                                            punctuality: 4.8
                                        },
                                        monthlyTrend: [4.5, 4.6, 4.6, 4.7, 4.8, 4.7],
                                        classDistribution: {
                                            completed: 171,
                                            cancelled: 7
                                        }
                                    },
                                    7: {
                                        name: "Emily Wong",
                                        email: "emily.wong@email.com",
                                        phone: "+60 19-012 3456",
                                        nric: "930707-44-5566",
                                        bod: "7 July 1993",
                                        regDate: "20 Sep 2023 01:15 PM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "2 years",
                                        dateJoined: "21 Sep 2023",
                                        status: "active",
                                        address: "741 Fitness Lane, Cheras, 56000 Kuala Lumpur",
                                        totalClasses: 45,
                                        cancelledClasses: 2,
                                        completedClasses: 43,
                                        avgRating: 4.1,
                                        totalFeedbacks: 38,
                                        categoryRatings: {
                                            teaching: 4.2,
                                            communication: 4.0,
                                            support: 3.9,
                                            punctuality: 4.3
                                        },
                                        monthlyTrend: [4.0, 4.1, 4.2, 4.1, 4.2, 4.1],
                                        classDistribution: {
                                            completed: 43,
                                            cancelled: 2
                                        }
                                    },
                                    8: {
                                        name: "James Lim",
                                        email: "james.lim@email.com",
                                        phone: "+60 11-234 5678",
                                        nric: "880808-22-3344",
                                        bod: "8 August 1988",
                                        regDate: "3 Dec 2024 10:00 AM",
                                        regStatus: "Approved",
                                        userType: "Instructor",
                                        experience: "1 year",
                                        dateJoined: "4 Dec 2024",
                                        status: "inactive",
                                        address: "852 Health Street, Puchong, 47100 Selangor",
                                        totalClasses: 15,
                                        cancelledClasses: 1,
                                        completedClasses: 14,
                                        avgRating: 3.9,
                                        totalFeedbacks: 12,
                                        categoryRatings: {
                                            teaching: 4.0,
                                            communication: 3.8,
                                            support: 3.7,
                                            punctuality: 4.1
                                        },
                                        monthlyTrend: [3.8, 3.9, 4.0, 3.9, 4.0, 3.8],
                                        classDistribution: {
                                            completed: 14,
                                            cancelled: 1
                                        }
                                    }
                                };

                                // Global variables
                                var currentInstructorId = null;
                                var chartInstances = {};
                                var currentPage = 1;
                                var itemsPerPage = 5;
                                var filteredInstructors = [];
                                var isViewingPDF = false;

                                // Initialize Date Range Picker dan komponen lainnya
                                $(document).ready(function () {
                                    $('#dateRangeFilter').daterangepicker({
                                        opens: 'left',
                                        drops: 'down',
                                        locale: {
                                            format: 'DD/MM/YYYY',
                                            applyLabel: 'Apply',
                                            cancelLabel: 'Cancel'
                                        }
                                    });

                                    // Initialize instructor table
                                    initializeInstructorTable();

                                    // Initialize stats
                                    updateStats();

                                    // Populate name filter dropdown
                                    populateNameFilter();

                                    // Add event listeners for filters
                                    document.getElementById('applyFilterBtn').addEventListener('click', applyFilters);
                                    document.getElementById('resetFilterBtn').addEventListener('click', resetFilters);
                                    document.getElementById('prevPageBtn').addEventListener('click', goToPrevPage);
                                    document.getElementById('nextPageBtn').addEventListener('click', goToNextPage);

                                    // Initialize Charts
                                    initializeCharts();
                                });

                                // Populate name filter dropdown dengan data dari instructors
                                function populateNameFilter() {
                                    var nameFilter = document.getElementById('nameFilter');

                                    // Clear existing options kecuali "All Instructors"
                                    while (nameFilter.options.length > 1) {
                                        nameFilter.remove(1);
                                    }

                                    // Add instructor names
                                    for (var id in instructors) {
                                        var instructor = instructors[id];
                                        var option = document.createElement('option');
                                        option.value = id;
                                        option.textContent = instructor.name;
                                        nameFilter.appendChild(option);
                                    }
                                }

                                // Initialize instructor table with pagination
                                function initializeInstructorTable() {
                                    // Reset filtered instructors to all
                                    filteredInstructors = [];
                                    for (var id in instructors) {
                                        filteredInstructors.push({
                                            id: id,
                                            data: instructors[id]
                                        });
                                    }

                                    // Render table
                                    renderInstructorTable();
                                }

                                // Render instructor table based on current page
                                function renderInstructorTable() {
                                    var tableBody = document.getElementById('instructorTableBody');
                                    tableBody.innerHTML = '';

                                    // Calculate start and end indices
                                    var startIndex = (currentPage - 1) * itemsPerPage;
                                    var endIndex = Math.min(startIndex + itemsPerPage, filteredInstructors.length);

                                    // Update pagination info
                                    document.getElementById('paginationStart').textContent = startIndex + 1;
                                    document.getElementById('paginationEnd').textContent = endIndex;
                                    document.getElementById('paginationTotal').textContent = filteredInstructors.length;

                                    // Update pagination buttons
                                    document.getElementById('prevPageBtn').disabled = (currentPage === 1);
                                    document.getElementById('nextPageBtn').disabled = (currentPage === Math.ceil(filteredInstructors.length / itemsPerPage));

                                    // Render page numbers
                                    renderPageNumbers();

                                    // Render table rows
                                    for (var i = startIndex; i < endIndex; i++) {
                                        var instructor = filteredInstructors[i];
                                        var row = createInstructorRow(instructor.id, instructor.data);
                                        tableBody.appendChild(row);
                                    }

                                    // Show empty state if no results
                                    if (filteredInstructors.length === 0) {
                                        var emptyRow = document.createElement('tr');
                                        emptyRow.id = 'noResults';
                                        emptyRow.innerHTML = '<td colspan="7" class="px-6 py-12 text-center">' +
                                                '<div class="text-espresso/40">' +
                                                '<svg class="mx-auto h-12 w-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>' +
                                                '</svg>' +
                                                '<p class="text-lg font-medium">No instructors found</p>' +
                                                '<p class="text-sm mt-1">Try adjusting your filters</p>' +
                                                '<button onclick="resetFilters()" class="mt-4 px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors">' +
                                                'Reset Filters' +
                                                '</button>' +
                                                '</div>' +
                                                '</td>';
                                        tableBody.appendChild(emptyRow);
                                    }
                                }

                                // Render page numbers
                                function renderPageNumbers() {
                                    var pageNumbersContainer = document.getElementById('pageNumbers');
                                    pageNumbersContainer.innerHTML = '';

                                    var totalPages = Math.ceil(filteredInstructors.length / itemsPerPage);

                                    // Always show first page
                                    addPageButton(1);

                                    // Show ellipsis if needed
                                    if (currentPage > 3) {
                                        var ellipsis = document.createElement('span');
                                        ellipsis.className = 'px-3 py-1';
                                        ellipsis.textContent = '...';
                                        pageNumbersContainer.appendChild(ellipsis);
                                    }

                                    // Show pages around current page
                                    var startPage = Math.max(2, currentPage - 1);
                                    var endPage = Math.min(totalPages - 1, currentPage + 1);

                                    for (var i = startPage; i <= endPage; i++) {
                                        addPageButton(i);
                                    }

                                    // Show ellipsis if needed
                                    if (currentPage < totalPages - 2) {
                                        var ellipsis = document.createElement('span');
                                        ellipsis.className = 'px-3 py-1';
                                        ellipsis.textContent = '...';
                                        pageNumbersContainer.appendChild(ellipsis);
                                    }

                                    // Always show last page if more than 1 page
                                    if (totalPages > 1) {
                                        addPageButton(totalPages);
                                    }
                                }

                                function addPageButton(pageNumber) {
                                    var pageNumbersContainer = document.getElementById('pageNumbers');
                                    var button = document.createElement('button');
                                    button.className = 'pagination-btn px-3 py-1 rounded border ' +
                                            (pageNumber === currentPage ? 'bg-dusty text-whitePure' : 'border-blush text-espresso');
                                    button.textContent = pageNumber;
                                    button.onclick = function () {
                                        goToPage(pageNumber);
                                    };
                                    pageNumbersContainer.appendChild(button);
                                }

                                // Pagination functions
                                function goToPage(page) {
                                    currentPage = page;
                                    renderInstructorTable();
                                }

                                function goToPrevPage() {
                                    if (currentPage > 1) {
                                        currentPage--;
                                        renderInstructorTable();
                                    }
                                }

                                function goToNextPage() {
                                    var totalPages = Math.ceil(filteredInstructors.length / itemsPerPage);
                                    if (currentPage < totalPages) {
                                        currentPage++;
                                        renderInstructorTable();
                                    }
                                }

                                // Create instructor table row dengan button yang sesuai
                                function createInstructorRow(id, instructor) {
                                    var row = document.createElement('tr');
                                    row.className = 'hover:bg-cloud';

                                    // Determine status badge
                                    var statusBadge = '';
                                    if (instructor.status === 'active') {
                                        statusBadge = '<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-successBg text-successTextDark">Active</span>';
                                    } else {
                                        statusBadge = '<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-dangerBg text-dangerText">Inactive</span>';
                                    }

                                    // Calculate rating percentage for progress bar
                                    var ratingPercentage = (instructor.avgRating / 5) * 100;
                                    var ratingColor = instructor.avgRating >= 4 ? 'bg-successBg' : (instructor.avgRating >= 3 ? 'bg-warningBg' : 'bg-dangerBg');

                                    // Determine button text based on status
                                    var actionButtonText = instructor.status === 'active' ? 'Deactivate' : 'Activate';
                                    var actionButtonClass = instructor.status === 'active' ? 'text-dusty hover:text-dustyHover' : 'text-teal hover:text-tealHover';
                                    var actionButtonBorder = instructor.status === 'active' ? 'border-dusty' : 'border-teal';

                                    row.innerHTML = '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="flex items-center">' +
                                            '<div class="flex-shrink-0 h-10 w-10">' +
                                            '<img class="h-10 w-10 rounded-full object-cover" src="../profile_pictures/instructor/dummy.png" alt="' + instructor.name + '">' +
                                            '</div>' +
                                            '<div class="ml-4">' +
                                            '<div class="text-sm font-medium text-espresso">' + instructor.name + '</div>' +
                                            '<div class="text-sm text-espresso/60">' + instructor.email + '</div>' +
                                            '</div>' +
                                            '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="text-sm text-espresso">' + instructor.experience + '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="text-sm text-espresso">' + instructor.dateJoined + '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="text-sm font-medium text-espresso">' + instructor.totalClasses + '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            '<div class="flex items-center">' +
                                            '<div class="text-sm font-medium text-espresso mr-2">' + instructor.avgRating + '</div>' +
                                            '<div class="w-24 bg-blush rounded-full h-2">' +
                                            '<div class="' + ratingColor + ' h-2 rounded-full" style="width:' + ratingPercentage + '%"></div>' +
                                            '</div>' +
                                            '</div>' +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap">' +
                                            statusBadge +
                                            '</td>' +
                                            '<td class="px-6 py-4 whitespace-nowrap text-sm font-medium">' +
                                            '<button onclick="showDetails(' + id + ')" class="text-teal hover:text-tealHover mr-3 px-3 py-1 rounded border border-teal hover:bg-teal/5 transition-colors">View Details</button>' +
                                            '<button onclick="toggleActivateInstructor(' + id + ')" class="' + actionButtonClass + ' px-3 py-1 rounded border ' + actionButtonBorder + ' hover:bg-' + (instructor.status === 'active' ? 'dusty' : 'teal') + '/5 transition-colors">' +
                                            actionButtonText +
                                            '</button>' +
                                            '</td>';

                                    return row;
                                }

                                // Update statistics
                                function updateStats() {
                                    var activeCount = 0;
                                    var inactiveCount = 0;
                                    var newThisMonth = 0;
                                    var totalRating = 0;
                                    var instructorCount = 0;

                                    var currentMonth = new Date().getMonth() + 1;
                                    var currentYear = new Date().getFullYear();

                                    for (var id in instructors) {
                                        var instructor = instructors[id];

                                        if (instructor.status === 'active') {
                                            activeCount++;
                                        } else {
                                            inactiveCount++;
                                        }

                                        // Check if joined this month (for demo, checking Dec 2024)
                                        if (instructor.dateJoined.includes('Dec 2024')) {
                                            newThisMonth++;
                                        }

                                        totalRating += instructor.avgRating;
                                        instructorCount++;
                                    }

                                    var avgRating = instructorCount > 0 ? (totalRating / instructorCount).toFixed(1) : '0.0';

                                    document.getElementById('statActiveInstructors').textContent = activeCount;
                                    document.getElementById('statInactiveInstructors').textContent = inactiveCount;
                                    document.getElementById('statNewThisMonth').textContent = newThisMonth;
                                    document.getElementById('statAvgRating').textContent = avgRating;
                                }

                                // Filter Functions dengan filter nama
                                function applyFilters() {
                                    var name = document.getElementById('nameFilter').value;
                                    var experience = document.getElementById('experienceFilter').value;
                                    var dateRange = document.getElementById('dateRangeFilter').value;
                                    var status = document.getElementById('statusFilter').value;

                                    filteredInstructors = [];

                                    for (var id in instructors) {
                                        var instructor = instructors[id];
                                        var matches = true;

                                        // Filter by name
                                        if (name && name !== "" && id !== name) {
                                            matches = false;
                                        }

                                        // Filter by experience
                                        if (experience && matches) {
                                            if (experience === '5+') {
                                                if (!instructor.experience.includes('+') && !instructor.experience.includes('5')) {
                                                    matches = false;
                                                }
                                            } else if (!instructor.experience.includes(experience)) {
                                                matches = false;
                                            }
                                        }

                                        // Filter by status
                                        if (status && matches && instructor.status !== status) {
                                            matches = false;
                                        }

                                        // Filter by date range (simplified for demo)
                                        if (dateRange && matches) {
                                            // In real implementation, you would parse the date range
                                            // and compare with instructor.dateJoined
                                            // This is simplified for demo
                                        }

                                        if (matches) {
                                            filteredInstructors.push({
                                                id: id,
                                                data: instructor
                                            });
                                        }
                                    }

                                    // Reset to first page
                                    currentPage = 1;
                                    renderInstructorTable();
                                }

                                function resetFilters() {
                                    document.getElementById('nameFilter').value = '';
                                    document.getElementById('experienceFilter').value = '';
                                    document.getElementById('dateRangeFilter').value = '';
                                    document.getElementById('statusFilter').value = '';

                                    initializeInstructorTable();
                                }

                                // Modal Functions
                                function showDetails(instructorId) {
                                    currentInstructorId = instructorId;
                                    var instructor = instructors[instructorId];

                                    if (!instructor)
                                        return;

                                    // Update modal content basic info
                                    document.getElementById('detailName').textContent = instructor.name;
                                    document.getElementById('detailEmail').textContent = instructor.email;
                                    document.getElementById('detailPhone').textContent = instructor.phone;
                                    document.getElementById('detailNRIC').textContent = instructor.nric;
                                    document.getElementById('detailBOD').textContent = instructor.bod;
                                    document.getElementById('detailRegDate').textContent = instructor.regDate;
                                    document.getElementById('detailExperience').textContent = instructor.experience;
                                    document.getElementById('detailDateJoined').textContent = instructor.dateJoined;
                                    document.getElementById('detailAddress').textContent = instructor.address;

                                    // Update performance summary menggunakan ID yang baru ditambah
                                    document.getElementById('statTotalClasses').textContent = instructor.totalClasses;
                                    document.getElementById('statCancelled').textContent = instructor.cancelledClasses;
                                    document.getElementById('statAvgRating').textContent = instructor.avgRating;
                                    document.getElementById('statFeedbacks').textContent = instructor.totalFeedbacks;

                                    // Update status badges
                                    var regStatusEl = document.getElementById('detailRegStatus');
                                    regStatusEl.innerHTML = instructor.regStatus === 'Approved'
                                            ? '<span class="px-2 py-1 text-xs rounded-full bg-successBg text-successTextDark">Approved</span>'
                                            : '<span class="px-2 py-1 text-xs rounded-full bg-warningBg text-warningText">Pending</span>';

                                    var statusEl = document.getElementById('detailStatus');
                                    if (instructor.status === 'active') {
                                        statusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-successBg text-successTextDark">Active</span>';
                                    } else {
                                        statusEl.innerHTML = '<span class="px-2 py-1 text-xs rounded-full bg-dangerBg text-dangerText">Inactive</span>';
                                    }

                                    // Paparkan modal
                                    document.getElementById('detailsModal').classList.remove('hidden');
                                }

                                function closeDetails() {
                                    document.getElementById('detailsModal').classList.add('hidden');
                                    currentInstructorId = null;
                                }

                                function showPerformance() {
                                    if (!currentInstructorId)
                                        return;

                                    var instructor = instructors[currentInstructorId];
                                    document.getElementById('performanceInstructorName').textContent = instructor.name;

                                    // Update performance metrics
                                    document.getElementById('perfOverallRating').textContent = instructor.avgRating;
                                    document.getElementById('perfTotalClasses').textContent = instructor.totalClasses;
                                    document.getElementById('perfCancelled').textContent = instructor.cancelledClasses;
                                    var completionRate = Math.round((instructor.completedClasses / instructor.totalClasses) * 100);
                                    document.getElementById('perfCompletion').textContent = completionRate + '%';

                                    // Tunjuk modal dulu, baru update chart
                                    document.getElementById('performanceModal').classList.remove('hidden');

                                    // Update charts with instructor specific data
                                    setTimeout(function () {
                                        updateCharts();
                                    }, 100);
                                }

                                function closePerformance() {
                                    document.getElementById('performanceModal').classList.add('hidden');
                                }

                                function viewCertification() {
                                    // Reset to certification view
                                    isViewingPDF = false;
                                    document.getElementById('certModalTitle').textContent = 'Certification Document';
                                    document.getElementById('certFrame').src = '../certifications/instructor/dummy.pdf';
                                    document.getElementById('certModal').classList.remove('hidden');
                                }

                                function closeCert() {
                                    document.getElementById('certModal').classList.add('hidden');
                                    // Reset iframe source to dummy PDF
                                    document.getElementById('certFrame').src = '../certifications/instructor/dummy.pdf';
                                    isViewingPDF = false;
                                }

                                // Activate/Deactivate Functions
                                function toggleActivateInstructor(instructorId) {
                                    currentInstructorId = instructorId;
                                    var instructor = instructors[instructorId];

                                    // Update modal elements based on current status
                                    var modalIcon = document.getElementById('modalIcon');
                                    var modalTitle = document.getElementById('modalTitle');
                                    var modalText = document.getElementById('modalText');
                                    var confirmButton = document.getElementById('confirmButton');

                                    if (instructor.status === 'active') {
                                        // Deactivate mode
                                        modalIcon.innerHTML = '<svg class="w-6 h-6 text-dangerText" fill="currentColor" viewBox="0 0 20 20">' +
                                                '<path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>' +
                                                '</svg>';
                                        modalIcon.className = 'flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full bg-dangerBg';

                                        modalTitle.textContent = 'Deactivate Instructor?';
                                        modalText.textContent = 'Are you sure you want to deactivate ' + instructor.name + '? They will no longer be able to access the system or be assigned to new classes.';

                                        confirmButton.textContent = 'Yes, Deactivate';
                                        confirmButton.className = 'px-4 py-2 bg-dusty text-whitePure rounded-lg hover:bg-dustyHover transition-colors';
                                    } else {
                                        // Activate mode
                                        modalIcon.innerHTML = '<svg class="w-6 h-6 text-successTextDark" fill="currentColor" viewBox="0 0 20 20">' +
                                                '<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>' +
                                                '</svg>';
                                        modalIcon.className = 'flex items-center justify-center w-12 h-12 mx-auto mb-4 rounded-full bg-successBg';

                                        modalTitle.textContent = 'Activate Instructor?';
                                        modalText.textContent = 'Are you sure you want to activate ' + instructor.name + '? They will be able to access the system and be assigned to new classes.';

                                        confirmButton.textContent = 'Yes, Activate';
                                        confirmButton.className = 'px-4 py-2 bg-teal text-whitePure rounded-lg hover:bg-tealHover transition-colors';
                                    }

                                    document.getElementById('activateDeactivateModal').classList.remove('hidden');
                                }

                                function closeActivateDeactivate() {
                                    document.getElementById('activateDeactivateModal').classList.add('hidden');
                                    currentInstructorId = null;
                                }

                                function confirmActivateDeactivate() {
                                    if (currentInstructorId) {
                                        var instructor = instructors[currentInstructorId];

                                        // Toggle status
                                        if (instructor.status === 'active') {
                                            instructor.status = 'inactive';
                                            alert('Instructor ' + instructor.name + ' has been deactivated.');
                                        } else {
                                            instructor.status = 'active';
                                            alert('Instructor ' + instructor.name + ' has been activated.');
                                        }

                                        // Update table and stats
                                        initializeInstructorTable();
                                        updateStats();
                                    }
                                    closeActivateDeactivate();
                                }

                                // Chart Functions
                                function initializeCharts() {
                                    // Destroy existing charts
                                    for (var key in chartInstances) {
                                        if (chartInstances[key]) {
                                            chartInstances[key].destroy();
                                        }
                                    }

                                    // Category Ratings Chart
                                    var categoryCtx = document.getElementById('categoryChart').getContext('2d');
                                    chartInstances.categoryChart = new Chart(categoryCtx, {
                                        type: 'bar',
                                        data: {
                                            labels: ['Teaching Skill', 'Communication', 'Support & Interaction', 'Punctuality'],
                                            datasets: [{
                                                    label: 'Average Rating',
                                                    data: [4.8, 4.7, 4.2, 4.5],
                                                    backgroundColor: ['#6D9B9B', '#A3C1D6', '#F2D1D1', '#B36D6D'],
                                                    borderColor: ['#557878', '#8AA9C4', '#E8BEBE', '#965656'],
                                                    borderWidth: 1,
                                                    borderRadius: 4
                                                }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            scales: {
                                                y: {
                                                    beginAtZero: true,
                                                    max: 5,
                                                    grid: {
                                                        color: '#EFE1E1'
                                                    },
                                                    ticks: {
                                                        color: '#3D3434'
                                                    }
                                                },
                                                x: {
                                                    grid: {
                                                        color: '#EFE1E1'
                                                    },
                                                    ticks: {
                                                        color: '#3D3434'
                                                    }
                                                }
                                            },
                                            plugins: {
                                                legend: {
                                                    display: false
                                                },
                                                tooltip: {
                                                    backgroundColor: '#3D3434',
                                                    titleColor: '#FDF8F8',
                                                    bodyColor: '#FDF8F8'
                                                }
                                            }
                                        }
                                    });

                                    // Monthly Trend Chart
                                    var trendCtx = document.getElementById('trendChart').getContext('2d');
                                    chartInstances.trendChart = new Chart(trendCtx, {
                                        type: 'line',
                                        data: {
                                            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                                            datasets: [{
                                                    label: 'Overall Rating',
                                                    data: [4.5, 4.6, 4.4, 4.7, 4.8, 4.7],
                                                    borderColor: '#6D9B9B',
                                                    backgroundColor: 'rgba(109, 155, 155, 0.1)',
                                                    borderWidth: 2,
                                                    fill: true,
                                                    tension: 0.4
                                                }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            scales: {
                                                y: {
                                                    beginAtZero: true,
                                                    max: 5,
                                                    grid: {
                                                        color: '#EFE1E1'
                                                    },
                                                    ticks: {
                                                        color: '#3D3434'
                                                    }
                                                },
                                                x: {
                                                    grid: {
                                                        color: '#EFE1E1'
                                                    },
                                                    ticks: {
                                                        color: '#3D3434'
                                                    }
                                                }
                                            },
                                            plugins: {
                                                legend: {
                                                    display: false
                                                },
                                                tooltip: {
                                                    backgroundColor: '#3D3434',
                                                    titleColor: '#FDF8F8',
                                                    bodyColor: '#FDF8F8'
                                                }
                                            }
                                        }
                                    });

                                    // Class Distribution Chart
                                    var distributionCtx = document.getElementById('distributionChart').getContext('2d');
                                    chartInstances.distributionChart = new Chart(distributionCtx, {
                                        type: 'pie',
                                        data: {
                                            labels: ['Completed', 'Cancelled'],
                                            datasets: [{
                                                    data: [134, 8],
                                                    backgroundColor: ['#A5D6A7', '#EF9A9A'],
                                                    borderColor: ['#8BC34A', '#F44336'],
                                                    borderWidth: 2
                                                }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            plugins: {
                                                legend: {
                                                    position: 'bottom',
                                                    labels: {
                                                        color: '#3D3434',
                                                        padding: 20,
                                                        font: {
                                                            size: 12
                                                        }
                                                    }
                                                },
                                                tooltip: {
                                                    backgroundColor: '#3D3434',
                                                    titleColor: '#FDF8F8',
                                                    bodyColor: '#FDF8F8'
                                                }
                                            }
                                        }
                                    });
                                }

                                function updateCharts() {
                                    if (!currentInstructorId)
                                        return;

                                    var instructor = instructors[currentInstructorId];
                                    var period = document.getElementById('timePeriod').value;

                                    var trendData;
                                    switch (period) {
                                        case '3months':
                                            trendData = instructor.monthlyTrend.slice(-3);
                                            break;
                                        case '6months':
                                            trendData = instructor.monthlyTrend;
                                            break;
                                        case '1year':
                                            trendData = instructor.monthlyTrend.concat([4.6, 4.7, 4.8, 4.7, 4.8, 4.9]);
                                            break;
                                        default:
                                            trendData = instructor.monthlyTrend;
                                    }

                                    // Update charts with instructor data
                                    var categoryData = [
                                        instructor.categoryRatings.teaching,
                                        instructor.categoryRatings.communication,
                                        instructor.categoryRatings.support,
                                        instructor.categoryRatings.punctuality
                                    ];

                                    chartInstances.trendChart.data.datasets[0].data = trendData;
                                    chartInstances.trendChart.data.labels = trendData.map(function (_, i) {
                                        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                        return months[i] || 'Month ' + (i + 1);
                                    });

                                    chartInstances.categoryChart.data.datasets[0].data = categoryData;

                                    chartInstances.distributionChart.data.datasets[0].data = [
                                        instructor.classDistribution.completed,
                                        instructor.classDistribution.cancelled
                                    ];

                                    chartInstances.trendChart.update();
                                    chartInstances.categoryChart.update();
                                    chartInstances.distributionChart.update();
                                }

                                function exportPerformancePDF() {
                                    var jsPDF = window.jspdf.jsPDF;
                                    var doc = new jsPDF('p', 'mm', 'a4');

                                    // --- 1. HEADER ---
                                    doc.setFillColor(179, 109, 109); // Warna Dusty
                                    doc.rect(0, 0, 210, 40, 'F');
                                    doc.setTextColor(255, 255, 255);
                                    doc.setFont("helvetica", "bold");
                                    doc.setFontSize(22);
                                    doc.text('SKYLIGHT STUDIO', 105, 18, {align: 'center'});
                                    doc.setFontSize(12);
                                    doc.setFont("helvetica", "normal");
                                    doc.text('INSTRUCTOR PERFORMANCE REPORT', 105, 28, {align: 'center'});

                                    // --- 2. MAKLUMAT LAPORAN ---
                                    doc.setTextColor(61, 52, 52); // Warna Espresso
                                    doc.setFontSize(10);
                                    var instructor = instructors[currentInstructorId] || instructors[1];
                                    var currentDate = new Date();
                                    var formattedDate = currentDate.getDate() + ' ' +
                                            currentDate.toLocaleDateString('en-GB', {month: 'long'}) + ' ' +
                                            currentDate.getFullYear();

                                    var currentY = 50; // Kita guna variable currentY supaya senang kawal jarak
                                    doc.setFont("helvetica", "bold");
                                    doc.text('Instructor Information', 20, currentY);
                                    doc.setFont("helvetica", "normal");
                                    currentY += 7;
                                    doc.text('Name: ' + instructor.name, 20, currentY);
                                    doc.text('Date Generated: ' + formattedDate, 120, currentY);
                                    currentY += 6;
                                    doc.text('Email: ' + instructor.email, 20, currentY);
                                    doc.text('Experience: ' + instructor.experience, 120, currentY);

                                    currentY += 15;

                                    // --- 3. EXECUTIVE SUMMARY ---
                                    doc.setFont("helvetica", "bold");
                                    doc.setFontSize(14);
                                    doc.text('Executive Summary', 20, currentY);
                                    currentY += 2;
                                    doc.setDrawColor(242, 209, 209);
                                    doc.line(20, currentY, 190, currentY);

                                    currentY += 10;
                                    doc.setFontSize(10);
                                    doc.setFont("helvetica", "normal");
                                    var completionRate = Math.round((instructor.completedClasses / instructor.totalClasses) * 100);

                                    // Grid Summary
                                    doc.text('Overall Rating: ' + instructor.avgRating + ' / 5.0', 20, currentY);
                                    doc.text('Total Classes: ' + instructor.totalClasses, 100, currentY);
                                    currentY += 7;
                                    doc.text('Completion Rate: ' + completionRate + '%', 20, currentY);
                                    doc.text('Total Feedbacks: ' + instructor.totalFeedbacks, 100, currentY);

                                    currentY += 15;

                                    // --- 4. PERFORMANCE BREAKDOWN ---
                                    doc.setFont("helvetica", "bold");
                                    doc.setFontSize(14);
                                    doc.text('Performance Breakdown by Category', 20, currentY);
                                    currentY += 2;
                                    doc.line(20, currentY, 190, currentY);

                                    currentY += 12;
                                    doc.setFontSize(10);

                                    var categories = [
                                        {name: 'Teaching Skill', rating: instructor.categoryRatings.teaching},
                                        {name: 'Communication', rating: instructor.categoryRatings.communication},
                                        {name: 'Support & Interaction', rating: instructor.categoryRatings.support},
                                        {name: 'Punctuality', rating: instructor.categoryRatings.punctuality}
                                    ];

                                    for (var i = 0; i < categories.length; i++) {
                                        var cat = categories[i];
                                        // Teks Kategori
                                        doc.setFont("helvetica", "bold");
                                        doc.setTextColor(61, 52, 52);
                                        doc.text(cat.name, 20, currentY);

                                        // Skor Teks (Hujung Kanan)
                                        doc.text(cat.rating + '/5.0', 180, currentY, {align: 'right'});

                                        // Lukis Bar Latar Belakang (Soft Pink)
                                        doc.setFillColor(245, 230, 230);
                                        doc.rect(70, currentY - 4, 80, 5, 'F');

                                        // Lukis Bar Prestasi (Teal)
                                        var barWidth = (cat.rating / 5) * 80;
                                        doc.setFillColor(109, 155, 155);
                                        doc.rect(70, currentY - 4, barWidth, 5, 'F');

                                        currentY += 12; // Tambah jarak antara baris supaya tak nampak sesak
                                    }

                                    currentY += 5;

                                    // --- 5. INSIGHTS & RECOMMENDATIONS ---
                                    doc.setFont("helvetica", "bold");
                                    doc.setFontSize(14);
                                    doc.text('Strategic Insights', 20, currentY);
                                    currentY += 2;
                                    doc.line(20, currentY, 190, currentY);

                                    currentY += 10;
                                    doc.setFontSize(10);
                                    doc.setFont("helvetica", "normal");

                                    var insights = [];
                                    if (instructor.avgRating >= 4.0) {
                                        insights = [
                                            "Maintain current high standards in teaching methodology.",
                                            "Consider role as mentor for junior instructors.",
                                            "Consistent excellence in student communication and punctuality."
                                        ];
                                    } else {
                                        insights = [
                                            "Priority: Improve Support & Interaction scores.",
                                            "Schedule training for better student engagement.",
                                            "Monitor punctuality and attendance for the next 30 days."
                                        ];
                                    }

                                    for (var j = 0; j < insights.length; j++) {
                                        doc.text('• ' + insights[j], 25, currentY);
                                        currentY += 7;
                                    }

                                    // --- FOOTER ---
                                    var pageHeight = doc.internal.pageSize.height;
                                    doc.setFontSize(8);
                                    doc.setTextColor(150, 150, 150);
                                    doc.text('Confidential - Skylight Studio Management System', 105, pageHeight - 15, {align: 'center'});
                                    doc.text('Page 1 of 1', 105, pageHeight - 10, {align: 'center'});

                                    // --- PREVIEW LOGIC ---
                                    var blobURL = doc.output('bloburl');
                                    var certFrame = document.getElementById('certFrame');
                                    certFrame.src = blobURL;

                                    // Set flag and update modal title
                                    isViewingPDF = true;
                                    document.getElementById('certModalTitle').textContent = 'Preview Instructor Report';
                                    document.getElementById('certModal').classList.remove('hidden');
                                }

                                // Function for exporting detailed report
                                function exportDetailedPDF() {
                                    exportPerformancePDF();
                                }

                                // Close modals on ESC key
                                document.addEventListener('keydown', function (e) {
                                    if (e.key === 'Escape') {
                                        closeDetails();
                                        closePerformance();
                                        closeCert();
                                        closeActivateDeactivate();
                                    }
                                });
        </script>
    </body>
</html>