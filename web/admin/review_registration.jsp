<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Review Registration Page</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
                            chipTeal: '#6D9B9B',
                            certBlue: '#4F8A8B',
                            certBlueHover: '#3D6B6C'
                        }
                    }
                }
            }
        </script>
        <style>
            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                backdrop-filter: blur(5px);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }

            .modal-content {
                background-color: white;
                border-radius: 0.75rem;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                max-width: 800px;
                width: 90%;
                max-height: 90vh;
                overflow-y: auto;
            }

            .status-pending {
                background-color: #FFCC80;
                color: #E65100;
            }

            .status-approved {
                background-color: #A5D6A7;
                color: #1B5E20;
            }

            .status-rejected {
                background-color: #EF9A9A;
                color: #B71C1C;
            }

            .pagination-btn {
                transition: all 0.2s ease;
            }

            .pagination-btn:hover:not(.disabled) {
                background-color: #F2D1D1;
            }

            .table-row {
                transition: background-color 0.2s ease;
                border-bottom: 2px solid #EFE1E1;
            }

            .table-row:hover {
                background-color: #FDF8F8;
            }

            .action-modal {
                max-width: 500px;
            }

            .badge-experience {
                background-color: #A3C1D6;
                color: #2C5555;
            }

            .cert-badge {
                background-color: #4F8A8B;
                color: white;
            }

            .cert-badge:hover {
                background-color: #3D6B6C;
            }

            .textarea-fixed {
                resize: none;
                overflow-y: auto;
                min-height: 100px;
                max-height: 200px;
            }

            /* Custom class untuk button yang seragam */
            .uniform-button {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 0.5rem;
                padding: 0.625rem 1rem; /* py-2.5 px-4 */
                border-radius: 0.5rem; /* rounded-lg */
                font-size: 0.875rem; /* text-sm */
                font-weight: 500; /* font-medium */
                transition: all 0.2s ease;
                width: 100%;
                min-height: 2.75rem;
                border: 1px solid transparent;
            }

            /* Untuk button dalam td (table cell) */
            td .uniform-button {
                min-width: 140px;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8 rounded-xl shadow-sm border border-blush flex-1 flex flex-col" style="max-width:1500px">

                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                            <h2 class="text-xl font-semibold mb-1 text-espresso">
                                Instructor Registration Review
                            </h2>
                            <p class="text-sm text-espresso/60">
                                Manage and review all pending instructor registration applications
                            </p>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Total:</span>
                                <span id="totalApplications" class="font-medium text-espresso ml-1">8</span>
                            </div>
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Pending:</span>
                                <span id="pendingApplications" class="font-medium text-warningText ml-1">5</span>
                            </div>
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Approved:</span>
                                <span id="approvedApplications" class="font-medium text-successTextDark ml-1">2</span>
                            </div>
                            <div class="text-sm bg-cloud px-3 py-1.5 rounded-lg border border-blush">
                                <span class="text-espresso/60">Rejected:</span>
                                <span id="rejectedApplications" class="font-medium text-dangerText ml-1">1</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filters Section -->
                <div class="mb-6">
                    <div class="flex flex-wrap items-center gap-3">
                        <span class="text-sm font-medium text-espresso">Filter by:</span>

                        <!-- Status Filter -->
                        <div class="relative">
                            <select id="statusFilter" class="appearance-none bg-whitePure border border-blush rounded-lg px-4 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty cursor-pointer">
                                <option value="all">All Status</option>
                                <option value="pending">Pending</option>
                                <option value="approved">Approved</option>
                                <option value="rejected">Rejected</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-espresso/60">
                                <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
                                </svg>
                            </div>
                        </div>

                        <!-- Date Filter -->
                        <div class="relative">
                            <select id="dateFilter" class="appearance-none bg-whitePure border border-blush rounded-lg px-4 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty cursor-pointer">
                                <option value="newest">Newest First</option>
                                <option value="oldest">Oldest First</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-espresso/60">
                                <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
                                </svg>
                            </div>
                        </div>

                        <!-- Experience Filter -->
                        <div class="relative">
                            <select id="experienceFilter" class="appearance-none bg-whitePure border border-blush rounded-lg px-4 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty cursor-pointer">
                                <option value="all">All Experience</option>
                                <option value="0-2">0-2 Years</option>
                                <option value="3-5">3-5 Years</option>
                                <option value="6-10">6-10 Years</option>
                                <option value="10+">10+ Years</option>
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-espresso/60">
                                <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
                                </svg>
                            </div>
                        </div>

                        <!-- Apply Filter Button -->
                        <button onclick="applyFilters()" class="bg-dusty hover:bg-dustyHover text-whitePure px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200">
                            Apply Filters
                        </button>

                        <!-- Reset Filter Button -->
                        <button onclick="resetFilters()" class="bg-petal hover:bg-blushHover text-espresso px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200">
                            Reset Filters
                        </button>
                    </div>
                </div>

                <!-- Table Section -->
                <div class="flex-1 overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b-2 border-espresso/20">
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Instructor</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Contact Info</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Experience</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Registration Date</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Status</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">View Details</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Certification</th>
                                <th class="text-left py-3 px-4 text-sm font-medium text-espresso">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="registrationTable">
                            <!-- Table rows will be loaded here by JavaScript -->
                        </tbody>
                    </table>

                    <!-- No Results State -->
                    <div id="noResultsState" class="text-center py-12 hidden">
                        <svg class="mx-auto h-16 w-16 text-espresso/20" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <p class="mt-4 text-espresso/50">No registrations found matching your filters.</p>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="mt-8 pt-6 border-t border-espresso/10">
                    <div class="flex items-center justify-between">
                        <div class="text-sm text-espresso/60">
                            Showing <span id="currentRange">0-0</span> of <span id="totalRegistrations">0</span> registrations
                        </div>
                        <div class="flex items-center space-x-2">
                            <button id="prevPage" onclick="changePage(currentPage - 1)" class="pagination-btn p-2 rounded-lg border border-blush text-espresso/60 hover:text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                                </svg>
                            </button>
                            <div class="flex items-center space-x-1">
                                <!-- Page numbers will be inserted here by JavaScript -->
                            </div>
                            <button id="nextPage" onclick="changePage(currentPage + 1)" class="pagination-btn p-2 rounded-lg border border-blush text-espresso/60 hover:text-espresso disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- Details Modal Overlay -->
        <div id="modalOverlay" class="modal-overlay" onclick="closeModal()">
            <div class="modal-content" onclick="stopPropagation(event)">
                <!-- Modal content will be inserted here by JavaScript -->
            </div>
        </div>

        <!-- PDF Viewer Modal -->
        <div id="pdfModalOverlay" class="modal-overlay" onclick="closePdfModal()">
            <div class="modal-content" style="max-width: 90%; height: 90vh;" onclick="stopPropagation(event)">
                <div class="p-4 h-full flex flex-col">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-espresso">Certificate Preview</h3>
                        <button onclick="closePdfModal()" class="text-espresso/60 hover:text-espresso">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="flex-1 border border-blush rounded-lg bg-cloud overflow-hidden">
                        <iframe id="pdfViewer" class="w-full h-full" frameborder="0"></iframe>
                    </div>
                </div>
            </div>
        </div>

        <!-- Approve/Reject Confirmation Modal -->
        <div id="actionModalOverlay" class="modal-overlay" onclick="closeActionModal()">
            <div class="modal-content action-modal" onclick="stopPropagation(event)">
                <!-- Action modal content will be inserted here by JavaScript -->
            </div>
        </div>

        <jsp:include page="../util/footer.jsp" />
        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

        <script>
                // Dummy data for registrations
                var dummyRegistrations = [
                    {
                        id: 1,
                        name: "Ahmad bin Ali",
                        email: "ahmad.ali@example.com",
                        phone: "012-3456789",
                        nric: "900101-01-1234",
                        bod: "1990-01-01",
                        yearOfExperience: 3,
                        address: "123 Jalan Merdeka, Kuala Lumpur",
                        registerDate: "2024-01-15 10:30:00",
                        status: "pending",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 2,
                        name: "Siti binti Mohd",
                        email: "siti.mohd@example.com",
                        phone: "013-9876543",
                        nric: "880215-02-5678",
                        bod: "1988-02-15",
                        yearOfExperience: 7,
                        address: "456 Jalan Tunku, Petaling Jaya",
                        registerDate: "2024-01-10 14:20:00",
                        status: "approved",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 3,
                        name: "Rajesh Kumar",
                        email: "rajesh.k@example.com",
                        phone: "011-2233445",
                        nric: "850530-03-9012",
                        bod: "1985-05-30",
                        yearOfExperience: 12,
                        address: "789 Jalan SS2, Petaling Jaya",
                        registerDate: "2024-01-05 09:15:00",
                        status: "rejected",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 4,
                        name: "Mei Ling Tan",
                        email: "meiling.tan@example.com",
                        phone: "016-7788990",
                        nric: "920710-04-3456",
                        bod: "1992-07-10",
                        yearOfExperience: 1,
                        address: "321 Jalan Bukit Bintang, Kuala Lumpur",
                        registerDate: "2024-01-20 16:45:00",
                        status: "pending",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 5,
                        name: "David Chen",
                        email: "david.chen@example.com",
                        phone: "017-5566778",
                        nric: "870825-05-7890",
                        bod: "1987-08-25",
                        yearOfExperience: 8,
                        address: "654 Jalan Puchong, Puchong",
                        registerDate: "2024-01-18 11:10:00",
                        status: "pending",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 6,
                        name: "Nor Azizah Abdullah",
                        email: "nor.azizah@example.com",
                        phone: "019-3344556",
                        nric: "891212-06-1234",
                        bod: "1989-12-12",
                        yearOfExperience: 4,
                        address: "987 Jalan Damansara, Damansara",
                        registerDate: "2024-01-12 13:25:00",
                        status: "approved",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 7,
                        name: "Kumaravel Muthu",
                        email: "kumaravel@example.com",
                        phone: "018-6677889",
                        nric: "830404-07-5678",
                        bod: "1983-04-04",
                        yearOfExperience: 15,
                        address: "147 Jalan Klang, Klang",
                        registerDate: "2024-01-08 15:40:00",
                        status: "pending",
                        certification: "../certifications/instructor/dummy.pdf"
                    },
                    {
                        id: 8,
                        name: "Sarah Johnson",
                        email: "sarah.j@example.com",
                        phone: "014-8899001",
                        nric: "940606-08-9012",
                        bod: "1994-06-06",
                        yearOfExperience: 0,
                        address: "258 Jalan Bangsar, Bangsar",
                        registerDate: "2024-01-22 08:50:00",
                        status: "pending",
                        certification: "../certifications/instructor/dummy.pdf"
                    }
                ];

                // Global variables
                var currentPage = 1;
                var registrationsPerPage = 5;
                var filteredRegistrations = [];
                var currentPdfUrl = null;
                var currentActionRegId = null;
                var currentActionType = null;
                var currentDetailsRegId = null;

                // DOM elements
                var registrationTable = document.getElementById('registrationTable');
                var noResultsState = document.getElementById('noResultsState');
                var totalApplications = document.getElementById('totalApplications');
                var pendingApplications = document.getElementById('pendingApplications');

                // Initialize page
                document.addEventListener('DOMContentLoaded', function () {
                    // Load registrations
                    filteredRegistrations = dummyRegistrations.slice();

                    // Update statistics
                    updateStatistics();

                    // Display initial data
                    updateDisplay();
                });

                // Update statistics function
                function updateStatistics() {
                    var total = dummyRegistrations.length;
                    var pending = dummyRegistrations.filter(function (reg) {
                        return reg.status === 'pending';
                    }).length;
                    var approved = dummyRegistrations.filter(function (reg) {
                        return reg.status === 'approved';
                    }).length;
                    var rejected = dummyRegistrations.filter(function (reg) {
                        return reg.status === 'rejected';
                    }).length;

                    totalApplications.textContent = total;
                    pendingApplications.textContent = pending;
                    document.getElementById('approvedApplications').textContent = approved;
                    document.getElementById('rejectedApplications').textContent = rejected;
                }

                // Stop propagation function
                function stopPropagation(event) {
                    event.stopPropagation();
                }

                // Apply filters function (manual - triggered by button)
                function applyFilters() {
                    var statusFilter = document.getElementById('statusFilter').value;
                    var dateFilter = document.getElementById('dateFilter').value;
                    var experienceFilter = document.getElementById('experienceFilter').value;

                    filteredRegistrations = dummyRegistrations.filter(function (reg) {
                        // Status filter
                        if (statusFilter !== 'all' && reg.status !== statusFilter) {
                            return false;
                        }

                        // Experience filter
                        if (experienceFilter !== 'all') {
                            var exp = reg.yearOfExperience;
                            switch (experienceFilter) {
                                case '0-2':
                                    if (exp > 2)
                                        return false;
                                    break;
                                case '3-5':
                                    if (exp < 3 || exp > 5)
                                        return false;
                                    break;
                                case '6-10':
                                    if (exp < 6 || exp > 10)
                                        return false;
                                    break;
                                case '10+':
                                    if (exp < 10)
                                        return false;
                                    break;
                            }
                        }

                        return true;
                    });

                    // Date sorting
                    filteredRegistrations.sort(function (a, b) {
                        var dateA = new Date(a.registerDate);
                        var dateB = new Date(b.registerDate);

                        if (dateFilter === 'newest') {
                            return dateB - dateA;
                        } else {
                            return dateA - dateB;
                        }
                    });

                    currentPage = 1;
                    updateDisplay();
                }

                // Reset filters function
                function resetFilters() {
                    document.getElementById('statusFilter').value = 'all';
                    document.getElementById('dateFilter').value = 'newest';
                    document.getElementById('experienceFilter').value = 'all';
                    applyFilters();
                }

                // Update display function
                function updateDisplay() {
                    // Clear current table
                    registrationTable.innerHTML = '';
                    noResultsState.classList.add('hidden');

                    if (filteredRegistrations.length === 0) {
                        noResultsState.classList.remove('hidden');
                        updatePagination();
                        return;
                    }

                    // Calculate pagination
                    var startIndex = (currentPage - 1) * registrationsPerPage;
                    var endIndex = Math.min(startIndex + registrationsPerPage, filteredRegistrations.length);
                    var currentRegistrations = filteredRegistrations.slice(startIndex, endIndex);

                    // Add registrations to table
                    for (var i = 0; i < currentRegistrations.length; i++) {
                        var reg = currentRegistrations[i];
                        registrationTable.appendChild(createTableRow(reg));
                    }

                    updatePagination();
                }

                // Create table row function
                function createTableRow(reg) {
                    var row = document.createElement('tr');
                    row.className = 'table-row';

                    var statusClass = 'status-' + reg.status;
                    var statusText = reg.status.charAt(0).toUpperCase() + reg.status.slice(1);
                    var expText = reg.yearOfExperience + ' year' + (reg.yearOfExperience !== 1 ? 's' : '');

                    row.innerHTML =
                            '<td class="py-4 px-4">' +
                            '<div class="flex items-center gap-3">' +
                            '<div class="w-10 h-10 rounded-full overflow-hidden bg-petal flex-shrink-0">' +
                            '<img src="../profile_pictures/instructor/dummy.png" alt="Profile" class="w-full h-full object-cover">' +
                            '</div>' +
                            '<div>' +
                            '<div class="font-medium text-espresso">' + reg.name + '</div>' +
                            '<div class="text-xs text-espresso/60">IC: ' + reg.nric + '</div>' +
                            '</div>' +
                            '</div>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<div class="text-sm">' + reg.email + '</div>' +
                            '<div class="text-xs text-espresso/60">' + reg.phone + '</div>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<span class="px-3 py-1 rounded-full text-xs font-medium badge-experience">' + expText + '</span>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<div class="text-sm">' + formatDate(reg.registerDate) + '</div>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<span class="px-3 py-1 rounded-full text-xs font-medium ' + statusClass + '">' + statusText + '</span>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<button onclick="viewDetails(' + reg.id + ')" class="uniform-button bg-whitePure border border-teal text-teal hover:bg-tealSoft">' +
                            '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>' +
                            '</svg>' +
                            '<span>View Details</span>' +
                            '</button>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<button onclick="viewPdf(\'' + reg.certification + '\')" class="uniform-button cert-badge hover:certBlueHover">' +
                            '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>' +
                            '</svg>' +
                            '<span>View Certificate</span>' +
                            '</button>' +
                            '</td>' +
                            '<td class="py-4 px-4">' +
                            '<div class="flex flex-col gap-2">' +
                            (reg.status === 'pending' ?
                                    '<button onclick="showApproveModal(' + reg.id + ')" class="uniform-button bg-successBg hover:bg-successBg/80 text-successTextDark">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>' +
                                    '</svg>' +
                                    '<span>Approve</span>' +
                                    '</button>' +
                                    '<button onclick="showRejectModal(' + reg.id + ')" class="uniform-button bg-dangerBg hover:bg-dangerBg/80 text-dangerText">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                                    '</svg>' +
                                    '<span>Reject</span>' +
                                    '</button>' :
                                    '<span class="text-xs text-espresso/40 italic text-center py-2">Action completed</span>') +
                            '</div>' +
                            '</td>';

                    return row;
                }

                // Update pagination function
                function updatePagination() {
                    var totalPages = Math.ceil(filteredRegistrations.length / registrationsPerPage);
                    var startIndex = (currentPage - 1) * registrationsPerPage + 1;
                    var endIndex = Math.min(currentPage * registrationsPerPage, filteredRegistrations.length);

                    // Update range text
                    document.getElementById('currentRange').textContent = startIndex + '-' + endIndex;
                    document.getElementById('totalRegistrations').textContent = filteredRegistrations.length;

                    // Update pagination buttons
                    var prevBtn = document.getElementById('prevPage');
                    var nextBtn = document.getElementById('nextPage');

                    prevBtn.disabled = currentPage === 1;
                    nextBtn.disabled = currentPage === totalPages;

                    // Update page numbers
                    var pageNumbersContainer = document.querySelector('.flex.items-center.space-x-1');
                    pageNumbersContainer.innerHTML = '';

                    // Always show first page
                    addPageNumber(pageNumbersContainer, 1);

                    // Calculate range of pages to show
                    var startPage = Math.max(2, currentPage - 1);
                    var endPage = Math.min(totalPages - 1, currentPage + 1);

                    // Add ellipsis if needed
                    if (startPage > 2) {
                        pageNumbersContainer.innerHTML += '<span class="px-2 text-espresso/30">...</span>';
                    }

                    // Add middle pages
                    for (var i = startPage; i <= endPage; i++) {
                        addPageNumber(pageNumbersContainer, i);
                    }

                    // Add ellipsis if needed
                    if (endPage < totalPages - 1) {
                        pageNumbersContainer.innerHTML += '<span class="px-2 text-espresso/30">...</span>';
                    }

                    // Always show last page if different from first
                    if (totalPages > 1) {
                        addPageNumber(pageNumbersContainer, totalPages);
                    }
                }

                // Add page number function
                function addPageNumber(container, pageNum) {
                    var btn = document.createElement('button');
                    btn.className = 'pagination-btn px-3 py-1 rounded-lg text-sm ' +
                            (pageNum === currentPage ? 'bg-dusty text-whitePure' : 'border border-blush text-espresso/60 hover:text-espresso');
                    btn.textContent = pageNum;
                    btn.onclick = function () {
                        changePage(pageNum);
                    };
                    container.appendChild(btn);
                }

                // Change page function
                function changePage(pageNum) {
                    var totalPages = Math.ceil(filteredRegistrations.length / registrationsPerPage);
                    if (pageNum >= 1 && pageNum <= totalPages && pageNum !== currentPage) {
                        currentPage = pageNum;
                        updateDisplay();
                    }
                }

                // Format date function
                function formatDate(dateString) {
                    var date = new Date(dateString);
                    return date.toLocaleDateString('en-MY', {
                        day: '2-digit',
                        month: 'short',
                        year: 'numeric'
                    });
                }

                // View details modal function
                function viewDetails(regId) {
                    currentDetailsRegId = regId;
                    var reg = dummyRegistrations.find(function (r) {
                        return r.id === regId;
                    });
                    if (!reg)
                        return;

                    var modalContent = document.querySelector('#modalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex justify-between items-center mb-6">' +
                            '<h3 class="text-xl font-semibold text-espresso">Registration Details</h3>' +
                            '<button onclick="closeModal()" class="text-espresso/60 hover:text-espresso">' +
                            '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg>' +
                            '</button>' +
                            '</div>' +
                            '<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">' +
                            '<div class="col-span-1">' +
                            '<div class="w-40 h-40 rounded-lg overflow-hidden bg-petal mx-auto mb-4">' +
                            '<img src="../profile_pictures/instructor/dummy.png" alt="Profile" class="w-full h-full object-cover">' +
                            '</div>' +
                            '<h4 class="text-center text-lg font-semibold text-espresso">' + reg.name + '</h4>' +
                            '<p class="text-center text-espresso/60 mb-2">Instructor Applicant</p>' +
                            '<div class="flex justify-center">' +
                            '<span class="px-3 py-1 rounded-full text-sm font-medium ' + getStatusClass(reg.status) + '">' +
                            getStatusText(reg.status) +
                            '</span>' +
                            '</div>' +
                            '</div>' +
                            '<div class="col-span-2 grid grid-cols-1 md:grid-cols-2 gap-4">' +
                            '<div class="bg-cloud rounded-lg p-4">' +
                            '<h5 class="text-sm font-medium text-espresso/60 mb-2">Personal Information</h5>' +
                            '<div class="space-y-2">' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Email:</span>' +
                            '<p class="text-espresso">' + reg.email + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Phone:</span>' +
                            '<p class="text-espresso">' + reg.phone + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">NRIC:</span>' +
                            '<p class="text-espresso">' + reg.nric + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Date of Birth:</span>' +
                            '<p class="text-espresso">' + new Date(reg.bod).toLocaleDateString('en-MY') + '</p>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '<div class="bg-cloud rounded-lg p-4">' +
                            '<h5 class="text-sm font-medium text-espresso/60 mb-2">Professional Information</h5>' +
                            '<div class="space-y-2">' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Experience:</span>' +
                            '<p class="text-espresso">' + reg.yearOfExperience + ' year' + (reg.yearOfExperience !== 1 ? 's' : '') + '</p>' +
                            '</div>' +
                            '<div>' +
                            '<span class="text-xs text-espresso/40">Registration Date:</span>' +
                            '<p class="text-espresso">' + formatDate(reg.registerDate) + '</p>' +
                            '</div>' +
                            '<div class="mt-3">' +
                            '<span class="text-xs text-espresso/40 block mb-1">Certification:</span>' +
                            '<button onclick="viewPdf(\'' + reg.certification + '\')" class="uniform-button cert-badge hover:certBlueHover">' +
                            '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>' +
                            '</svg>' +
                            '<span>View Certificate</span>' +
                            '</button>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '<div class="bg-cloud rounded-lg p-4 mb-6">' +
                            '<h5 class="text-sm font-medium text-espresso/60 mb-2">Address</h5>' +
                            '<p class="text-espresso">' + reg.address + '</p>' +
                            '</div>' +
                            '<div class="border-t border-espresso/10 pt-4">' +
                            (reg.status === 'pending' ?
                                    '<div class="flex justify-end gap-3">' +
                                    '<button onclick="showRejectModal(' + reg.id + ')" class="uniform-button bg-dangerBg hover:bg-dangerBg/80 text-dangerText">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                                    '</svg>' +
                                    '<span>Reject</span>' +
                                    '</button>' +
                                    '<button onclick="showApproveModal(' + reg.id + ')" class="uniform-button bg-successBg hover:bg-successBg/80 text-successTextDark">' +
                                    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                                    '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>' +
                                    '</svg>' +
                                    '<span>Approve</span>' +
                                    '</button>' +
                                    '</div>' :
                                    '<div class="text-center text-espresso/60 italic">' +
                                    'This application has been ' + reg.status + ' on ' + formatDate(reg.registerDate) +
                                    '</div>') +
                            '</div>';

                    document.getElementById('modalOverlay').style.display = 'flex';
                }

                // Get status class function
                function getStatusClass(status) {
                    return 'status-' + status;
                }

                // Get status text function
                function getStatusText(status) {
                    return status.charAt(0).toUpperCase() + status.slice(1);
                }

                // Close modal function
                function closeModal() {
                    document.getElementById('modalOverlay').style.display = 'none';
                    currentDetailsRegId = null;
                }

                // View PDF function
                function viewPdf(pdfUrl) {
                    currentPdfUrl = pdfUrl;
                    var pdfViewer = document.getElementById('pdfViewer');
                    pdfViewer.src = pdfUrl;
                    document.getElementById('pdfModalOverlay').style.display = 'flex';
                }

                // Close PDF modal function
                function closePdfModal() {
                    document.getElementById('pdfModalOverlay').style.display = 'none';
                    var pdfViewer = document.getElementById('pdfViewer');
                    pdfViewer.src = '';
                }

                // Show approve modal function
                function showApproveModal(regId) {
                    currentActionRegId = regId;
                    currentActionType = 'approve';

                    var modalContent = document.querySelector('#actionModalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex justify-between items-center mb-6">' +
                            '<h3 class="text-xl font-semibold text-espresso">Approve Registration</h3>' +
                            '<button onclick="closeActionModal()" class="text-espresso/60 hover:text-espresso">' +
                            '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg>' +
                            '</button>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<div class="flex items-center gap-3 p-4 bg-successBg/20 rounded-lg">' +
                            '<svg class="w-6 h-6 text-successTextDark flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>' +
                            '</svg>' +
                            '<p class="text-successTextDark text-sm">Are you sure you want to approve this registration?</p>' +
                            '</div>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<label class="block text-sm font-medium text-espresso mb-2">Approval Message (Optional)</label>' +
                            '<textarea id="actionMessage" class="w-full border border-blush rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty textarea-fixed" rows="4" placeholder="Add a welcome message to the instructor..."></textarea>' +
                            '<p class="text-xs text-espresso/40 mt-1">This message will be sent to the applicant</p>' +
                            '</div>' +
                            '<div class="flex justify-end gap-3">' +
                            '<button onclick="closeActionModal()" class="bg-petal hover:bg-blushHover text-espresso px-6 py-2 rounded-lg font-medium transition-colors duration-200">Cancel</button>' +
                            '<button onclick="processAction()" class="bg-successBg hover:bg-successBg/80 text-successTextDark px-6 py-2 rounded-lg font-medium transition-colors duration-200">Approve Registration</button>' +
                            '</div>' +
                            '</div>';

                    document.getElementById('actionModalOverlay').style.display = 'flex';
                }

                // Show reject modal function
                function showRejectModal(regId) {
                    currentActionRegId = regId;
                    currentActionType = 'reject';

                    var modalContent = document.querySelector('#actionModalOverlay .modal-content');
                    modalContent.innerHTML =
                            '<div class="p-6">' +
                            '<div class="flex justify-between items-center mb-6">' +
                            '<h3 class="text-xl font-semibold text-espresso">Reject Registration</h3>' +
                            '<button onclick="closeActionModal()" class="text-espresso/60 hover:text-espresso">' +
                            '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                            '</svg>' +
                            '</button>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<div class="flex items-center gap-3 p-4 bg-dangerBg/20 rounded-lg">' +
                            '<svg class="w-6 h-6 text-dangerText flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.998-.833-2.732 0L4.342 16.5c-.77.833.192 2.5 1.732 2.5z"></path>' +
                            '</svg>' +
                            '<p class="text-dangerText text-sm">Are you sure you want to reject this registration?</p>' +
                            '</div>' +
                            '</div>' +
                            '<div class="mb-6">' +
                            '<label class="block text-sm font-medium text-espresso mb-2">Rejection Reason (Required)</label>' +
                            '<textarea id="actionMessage" class="w-full border border-blush rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-dusty focus:border-dusty textarea-fixed" rows="4" placeholder="Please provide a reason for rejection..." required></textarea>' +
                            '<p class="text-xs text-espresso/40 mt-1">This message will be sent to the applicant</p>' +
                            '</div>' +
                            '<div class="flex justify-end gap-3">' +
                            '<button onclick="closeActionModal()" class="bg-petal hover:bg-blushHover text-espresso px-6 py-2 rounded-lg font-medium transition-colors duration-200">Cancel</button>' +
                            '<button onclick="processAction()" class="bg-dangerBg hover:bg-dangerBg/80 text-dangerText px-6 py-2 rounded-lg font-medium transition-colors duration-200">Reject Registration</button>' +
                            '</div>' +
                            '</div>';

                    document.getElementById('actionModalOverlay').style.display = 'flex';
                }

                // Close action modal function
                function closeActionModal() {
                    document.getElementById('actionModalOverlay').style.display = 'none';
                    currentActionRegId = null;
                    currentActionType = null;
                }

                // Process action function
                function processAction() {
                    var message = document.getElementById('actionMessage').value;

                    if (currentActionType === 'reject' && !message.trim()) {
                        alert('Please provide a rejection reason.');
                        return;
                    }

                    var regIndex = dummyRegistrations.findIndex(function (r) {
                        return r.id === currentActionRegId;
                    });
                    if (regIndex !== -1) {
                        dummyRegistrations[regIndex].status = currentActionType === 'approve' ? 'approved' : 'rejected';

                        // Simulate saving action message (in real app, this would go to database)
                        console.log('Action: ' + currentActionType.toUpperCase() + ' for registration ID: ' + currentActionRegId);
                        console.log('Message: ' + (message || 'No message provided'));

                        applyFilters();
                        updateStatistics();

                        // Close action modal but NOT details modal
                        closeActionModal();

                        // If details modal is open, refresh it
                        if (currentDetailsRegId === currentActionRegId) {
                            viewDetails(currentActionRegId);
                        }

                        // Show success message
                        var actionText = currentActionType === 'approve' ? 'approved' : 'rejected';
                        alert('Registration ' + actionText + ' successfully!');
                    }
                }
        </script>

    </body>
</html>