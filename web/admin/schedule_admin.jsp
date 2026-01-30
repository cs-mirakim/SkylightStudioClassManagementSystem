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
        <title>Admin Schedule Management Page</title>

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
                            /* Primary & Background */
                            dusty: '#B36D6D',
                            dustyHover: '#8A5252',
                            blush: '#F2D1D1',
                            blushHover: '#E5BCBC',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',

                            /* Text */
                            espresso: '#3D3434',
                            espressoLight: '#5C4F4F',
                            espressoLighter: '#7A6A6A',

                            /* Blue Accents */
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',

                            /* Green Accents */
                            sage: '#8AA28A',
                            sageLight: '#A8C1A8',

                            /* Alerts */
                            successBg: '#D4EDDA',
                            successText: '#155724',

                            warningBg: '#FFF3CD',
                            warningText: '#856404',

                            dangerBg: '#F8D7DA',
                            dangerText: '#721C24',

                            infoBg: '#D1ECF1',
                            infoText: '#0C5460',

                            /* Status */
                            activeBg: '#E8F5E9',
                            activeText: '#2E7D32',
                            inactiveBg: '#FFEBEE',
                            inactiveText: '#C62828',

                            /* Chips */
                            chipRose: '#FCE4EC',
                            chipSand: '#F5E6D3',
                            chipTeal: '#E0F2F1'
                        }
                    }
                }
            }
        </script>

        <style>
            .modal-backdrop {
                background-color: rgba(61, 52, 52, 0.7);
                backdrop-filter: blur(4px);
            }
            .scrollbar-thin::-webkit-scrollbar {
                width: 6px;
                height: 6px;
            }
            .scrollbar-thin::-webkit-scrollbar-track {
                background: #FDF8F8;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb {
                background: #D9B8B8;
                border-radius: 3px;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb:hover {
                background: #B36D6D;
            }
            .btn-primary {
                background-color: #B36D6D;
                color: white;
            }
            .btn-primary:hover {
                background-color: #8A5252;
            }
            .btn-secondary {
                background-color: #F2D1D1;
                color: #3D3434;
            }
            .btn-secondary:hover {
                background-color: #E5BCBC;
            }
            .btn-accent {
                background-color: #6D9B9B;
                color: white;
            }
            .btn-accent:hover {
                background-color: #557878;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">

            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Page Header -->
                <div class="mb-8 pb-4 border-b border-espresso/10">
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between">
                        <div>
                            <h2 class="text-xl font-semibold mb-1 text-espresso">
                                Admin Schedule Management Page
                            </h2>
                            <p class="text-sm text-espressoLighter">
                                Manage and schedule all classes for the fitness center
                            </p>
                        </div>
                        <button id="addClassBtn" 
                                class="mt-4 md:mt-0 btn-primary px-6 py-2.5 rounded-lg font-medium transition duration-200 shadow-sm">
                            + Add New Class
                        </button>
                    </div>
                </div>

                <!-- Filter Section -->
                <div class="mb-6 p-4 bg-petal/50 rounded-lg border border-blush">
                    <h3 class="font-medium mb-3 text-espresso">Filter Classes</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <!-- Status Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Status</label>
                            <select id="filterStatus" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                <option value="">All Status</option>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>

                        <!-- Date Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Date</label>
                            <input type="date" id="filterDate" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                        </div>

                        <!-- Class Type Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Class Type</label>
                            <select id="filterType" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                <option value="">All Types</option>
                                <option value="mat pilates">Mat Pilates</option>
                                <option value="reformer">Reformer</option>
                            </select>
                        </div>

                        <!-- Class Level Filter -->
                        <div>
                            <label class="block text-sm font-medium mb-1 text-espresso">Class Level</label>
                            <select id="filterLevel" class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                <option value="">All Levels</option>
                                <option value="beginner">Beginner</option>
                                <option value="intermediate">Intermediate</option>
                                <option value="advanced">Advanced</option>
                            </select>
                        </div>
                    </div>
                    <div class="flex justify-end mt-4">
                        <button id="applyFilterBtn" class="btn-accent px-5 py-2 rounded-lg font-medium mr-2 shadow-sm">
                            Apply Filters
                        </button>
                        <button id="resetFilterBtn" class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                            Reset
                        </button>
                    </div>
                </div>

                <!-- Classes Table -->
                <div class="flex-1 flex flex-col">
                    <div class="overflow-x-auto scrollbar-thin">
                        <table class="min-w-full divide-y divide-blush/50">
                            <thead>
                                <tr class="bg-petal/80">
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Class Name</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Date & Time</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Type & Level</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Instructor</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">QR Code</th>
                                    <th class="px-6 py-3 text-left text-xs font-semibold text-espresso uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="classesTableBody" class="bg-whitePure divide-y divide-blush/30">
                                <!-- Classes will be loaded here by JavaScript -->
                            </tbody>
                        </table>
                    </div>

                    <!-- No Classes Message -->
                    <div id="noClassesMessage" class="hidden flex-1 flex items-center justify-center p-8">
                        <div class="text-center">
                            <div class="text-espresso/40 mb-2">
                                <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                            </div>
                            <p class="text-espressoLighter">No classes found. Click "Add New Class" to create one.</p>
                        </div>
                    </div>

                    <!-- Pagination -->
                    <div id="pagination" class="mt-6 flex items-center justify-between border-t border-blush/50 pt-4">
                        <div class="text-sm text-espressoLighter">
                            Showing <span id="startRow">1</span> to <span id="endRow">10</span> of <span id="totalRows">0</span> classes
                        </div>
                        <div class="flex space-x-2">
                            <button id="prevPage" class="px-3 py-1 border border-blush rounded text-espressoLighter hover:bg-blush/30 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                Previous
                            </button>
                            <div id="pageNumbers" class="flex space-x-1">
                                <!-- Page numbers will be inserted here -->
                            </div>
                            <button id="nextPage" class="px-3 py-1 border border-blush rounded text-espressoLighter hover:bg-blush/30 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                                Next
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <!-- Add Class Modal -->
        <div id="addClassModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col">
                    <!-- Modal Header -->
                    <div class="px-6 py-4 border-b border-blush bg-petal/30">
                        <h3 class="text-lg font-semibold text-espresso">Add New Class</h3>
                    </div>

                    <!-- Modal Body -->
                    <div class="flex-1 overflow-y-auto p-6">
                        <form id="addClassForm" class="space-y-4">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Class Name -->
                                <div>
                                    <label for="addClassName" class="block text-sm font-medium mb-1 text-espresso">Class Name *</label>
                                    <input type="text" id="addClassName" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Class Type -->
                                <div>
                                    <label for="addClassType" class="block text-sm font-medium mb-1 text-espresso">Class Type *</label>
                                    <select id="addClassType" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Type</option>
                                        <option value="mat pilates">Mat Pilates</option>
                                        <option value="reformer">Reformer</option>
                                    </select>
                                </div>

                                <!-- Class Level -->
                                <div>
                                    <label for="addClassLevel" class="block text-sm font-medium mb-1 text-espresso">Class Level *</label>
                                    <select id="addClassLevel" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Level</option>
                                        <option value="beginner">Beginner</option>
                                        <option value="intermediate">Intermediate</option>
                                        <option value="advanced">Advanced</option>
                                    </select>
                                </div>

                                <!-- Class Date -->
                                <div>
                                    <label for="addClassDate" class="block text-sm font-medium mb-1 text-espresso">Class Date *</label>
                                    <input type="date" id="addClassDate" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Start Time -->
                                <div>
                                    <label for="addClassStartTime" class="block text-sm font-medium mb-1 text-espresso">Start Time *</label>
                                    <input type="time" id="addClassStartTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- End Time -->
                                <div>
                                    <label for="addClassEndTime" class="block text-sm font-medium mb-1 text-espresso">End Time *</label>
                                    <input type="time" id="addClassEndTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Number of Participants -->
                                <div>
                                    <label for="addNoOfParticipant" class="block text-sm font-medium mb-1 text-espresso">No. of Participants *</label>
                                    <input type="number" id="addNoOfParticipant" min="1" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Location -->
                                <div>
                                    <label for="addLocation" class="block text-sm font-medium mb-1 text-espresso">Location *</label>
                                    <input type="text" id="addLocation" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>
                            </div>

                            <!-- Description -->
                            <div>
                                <label for="addDescription" class="block text-sm font-medium mb-1 text-espresso">Description *</label>
                                <textarea id="addDescription" rows="3" required 
                                          class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty"></textarea>
                            </div>
                        </form>
                    </div>

                    <!-- Modal Footer -->
                    <div class="px-6 py-4 border-t border-blush bg-cloud">
                        <div class="flex justify-end space-x-3">
                            <button type="button" id="cancelAddBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="submit" form="addClassForm" 
                                    class="btn-primary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Submit Class & Generate QR
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit Class Modal -->
        <div id="editClassModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col">
                    <!-- Modal Header -->
                    <div class="px-6 py-4 border-b border-blush bg-petal/30">
                        <h3 class="text-lg font-semibold text-espresso">Edit Class</h3>
                    </div>

                    <!-- Modal Body -->
                    <div class="flex-1 overflow-y-auto p-6">
                        <form id="editClassForm" class="space-y-4">
                            <input type="hidden" id="editClassId">

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Class Name -->
                                <div>
                                    <label for="editClassName" class="block text-sm font-medium mb-1 text-espresso">Class Name *</label>
                                    <input type="text" id="editClassName" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Class Type -->
                                <div>
                                    <label for="editClassType" class="block text-sm font-medium mb-1 text-espresso">Class Type *</label>
                                    <select id="editClassType" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Type</option>
                                        <option value="mat pilates">Mat Pilates</option>
                                        <option value="reformer">Reformer</option>
                                    </select>
                                </div>

                                <!-- Class Level -->
                                <div>
                                    <label for="editClassLevel" class="block text-sm font-medium mb-1 text-espresso">Class Level *</label>
                                    <select id="editClassLevel" required 
                                            class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                        <option value="">Select Level</option>
                                        <option value="beginner">Beginner</option>
                                        <option value="intermediate">Intermediate</option>
                                        <option value="advanced">Advanced</option>
                                    </select>
                                </div>

                                <!-- Class Date -->
                                <div>
                                    <label for="editClassDate" class="block text-sm font-medium mb-1 text-espresso">Class Date *</label>
                                    <input type="date" id="editClassDate" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Start Time -->
                                <div>
                                    <label for="editClassStartTime" class="block text-sm font-medium mb-1 text-espresso">Start Time *</label>
                                    <input type="time" id="editClassStartTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- End Time -->
                                <div>
                                    <label for="editClassEndTime" class="block text-sm font-medium mb-1 text-espresso">End Time *</label>
                                    <input type="time" id="editClassEndTime" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Number of Participants -->
                                <div>
                                    <label for="editNoOfParticipant" class="block text-sm font-medium mb-1 text-espresso">No. of Participants *</label>
                                    <input type="number" id="editNoOfParticipant" min="1" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>

                                <!-- Location -->
                                <div>
                                    <label for="editLocation" class="block text-sm font-medium mb-1 text-espresso">Location *</label>
                                    <input type="text" id="editLocation" required 
                                           class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty">
                                </div>
                            </div>

                            <!-- Description -->
                            <div>
                                <label for="editDescription" class="block text-sm font-medium mb-1 text-espresso">Description *</label>
                                <textarea id="editDescription" rows="3" required 
                                          class="w-full px-3 py-2 border border-blush rounded-lg bg-whitePure focus:outline-none focus:ring-2 focus:ring-dusty/50 focus:border-dusty"></textarea>
                            </div>

                            <!-- Generate New QR Code -->
                            <div class="border-t border-blush/50 pt-4">
                                <div class="flex items-center space-x-2">
                                    <input type="checkbox" id="generateNewQR" class="w-4 h-4 text-dusty focus:ring-dusty/50 border-blush rounded">
                                    <label for="generateNewQR" class="text-sm text-espresso">
                                        Generate new QR code for this class
                                    </label>
                                </div>
                                <p class="text-xs text-espressoLighter mt-1 ml-6">
                                    If checked, a new QR code will be generated when saving changes
                                </p>
                            </div>
                        </form>
                    </div>

                    <!-- Modal Footer -->
                    <div class="px-6 py-4 border-t border-blush bg-cloud">
                        <div class="flex justify-end space-x-3">
                            <button type="button" id="cancelEditBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="submit" form="editClassForm" 
                                    class="btn-primary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Save & Update Class
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- QR Code Modal -->
        <div id="qrModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-md">
                    <div class="p-6">
                        <div class="text-center">
                            <h3 class="text-lg font-semibold mb-4 text-espresso">Class QR Code</h3>
                            <div class="mb-4 flex justify-center">
                                <img id="qrModalImage" src="" alt="QR Code" class="w-64 h-64 border-4 border-blush rounded-lg">
                            </div>
                            <p class="text-sm text-espressoLighter mb-6">
                                Scan this QR code for class information
                            </p>
                            <div class="flex justify-center space-x-3">
                                <a id="qrFeedbackLink" href="#" 
                                   class="btn-accent px-5 py-2 rounded-lg font-medium shadow-sm">
                                    Go to Feedback Page
                                </a>
                                <button type="button" id="closeQRBtn" 
                                        class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                    Close
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div id="deleteModal" class="fixed inset-0 z-50 hidden">
            <div class="modal-backdrop fixed inset-0"></div>
            <div class="fixed inset-0 flex items-center justify-center p-4">
                <div class="bg-whitePure rounded-xl shadow-2xl w-full max-w-md">
                    <div class="p-6">
                        <div class="text-center">
                            <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-dangerBg">
                                <svg class="h-6 w-6 text-dangerText" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                </svg>
                            </div>
                            <h3 class="mt-4 text-lg font-medium text-espresso">Delete Class</h3>
                            <p class="mt-2 text-sm text-espressoLighter">
                                Are you sure you want to delete this class? This action cannot be undone.
                            </p>
                        </div>
                        <div class="mt-6 flex justify-center space-x-3">
                            <button type="button" id="cancelDeleteBtn" 
                                    class="btn-secondary px-5 py-2 rounded-lg font-medium shadow-sm">
                                Cancel
                            </button>
                            <button type="button" id="confirmDeleteBtn" 
                                    class="bg-dangerBg text-dangerText hover:bg-dangerBg/90 px-5 py-2 rounded-lg font-medium shadow-sm">
                                Delete
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
            // Dummy data for classes
            var classesData = [
                {
                    classID: 1,
                    className: "Morning Pilates",
                    classType: "mat pilates",
                    classLevel: "beginner",
                    classDate: "2024-01-15",
                    classStartTime: "08:00",
                    classEndTime: "09:00",
                    noOfParticipant: 15,
                    location: "Studio A",
                    description: "Gentle morning pilates session for beginners",
                    classStatus: "active",
                    qrcode: "../qr_codes/dummy.png",
                    adminID: 1,
                    confirmedInstructor: "Sarah Johnson",
                    pendingInstructor: "Mike Chen"
                },
                {
                    classID: 2,
                    className: "Advanced Reformer",
                    classType: "reformer",
                    classLevel: "advanced",
                    classDate: "2024-01-16",
                    classStartTime: "18:00",
                    classEndTime: "19:30",
                    noOfParticipant: 8,
                    location: "Studio B",
                    description: "Challenging reformer workout for advanced practitioners",
                    classStatus: "active",
                    qrcode: "../qr_codes/dummy.png",
                    adminID: 1,
                    confirmedInstructor: "David Lee",
                    pendingInstructor: ""
                },
                {
                    classID: 3,
                    className: "Evening Relaxation",
                    classType: "mat pilates",
                    classLevel: "intermediate",
                    classDate: "2024-01-17",
                    classStartTime: "19:00",
                    classEndTime: "20:00",
                    noOfParticipant: 20,
                    location: "Studio C",
                    description: "Evening session to relax and stretch",
                    classStatus: "inactive",
                    qrcode: "../qr_codes/dummy.png",
                    adminID: 1,
                    confirmedInstructor: "N/A",
                    pendingInstructor: ""
                },
                {
                    classID: 4,
                    className: "Power Pilates",
                    classType: "mat pilates",
                    classLevel: "intermediate",
                    classDate: "2024-01-18",
                    classStartTime: "17:00",
                    classEndTime: "18:00",
                    noOfParticipant: 12,
                    location: "Studio A",
                    description: "High-intensity pilates workout",
                    classStatus: "active",
                    qrcode: "../qr_codes/dummy.png",
                    adminID: 1,
                    confirmedInstructor: "Emma Wilson",
                    pendingInstructor: "James Brown"
                },
                {
                    classID: 5,
                    className: "Beginner Reformer",
                    classType: "reformer",
                    classLevel: "beginner",
                    classDate: "2024-01-19",
                    classStartTime: "10:00",
                    classEndTime: "11:00",
                    noOfParticipant: 6,
                    location: "Studio B",
                    description: "Introduction to reformer machine",
                    classStatus: "active",
                    qrcode: "../qr_codes/dummy.png",
                    adminID: 1,
                    confirmedInstructor: "N/A",
                    pendingInstructor: "Lisa Wong"
                }
            ];

            // Add more dummy data
            for (var i = 6; i <= 25; i++) {
                var types = ["mat pilates", "reformer"];
                var levels = ["beginner", "intermediate", "advanced"];
                var statuses = ["active", "inactive"];
                var instructors = ["Sarah Johnson", "Mike Chen", "David Lee", "Lisa Wong", "Emma Wilson", "James Brown"];
                var confirmedInstructor = Math.random() > 0.3 ? instructors[Math.floor(Math.random() * instructors.length)] : "N/A";
                var pendingInstructor = confirmedInstructor !== "N/A" && Math.random() > 0.5 ? instructors[Math.floor(Math.random() * instructors.length)] : "";

                var classObj = {
                    classID: i,
                    className: "Class " + i,
                    classType: types[Math.floor(Math.random() * types.length)],
                    classLevel: levels[Math.floor(Math.random() * levels.length)],
                    classDate: "2024-01-" + (15 + Math.floor(Math.random() * 10)),
                    classStartTime: (8 + Math.floor(Math.random() * 12)) + ":00",
                    classEndTime: (9 + Math.floor(Math.random() * 12)) + ":30",
                    noOfParticipant: 5 + Math.floor(Math.random() * 20),
                    location: "Studio " + String.fromCharCode(65 + Math.floor(Math.random() * 3)),
                    description: "Sample class description for class " + i,
                    classStatus: statuses[Math.floor(Math.random() * statuses.length)],
                    qrcode: "../qr_codes/dummy.png",
                    adminID: 1,
                    confirmedInstructor: confirmedInstructor,
                    pendingInstructor: pendingInstructor
                };

                classesData.push(classObj);
            }

            // Current page and items per page
            var currentPage = 1;
            var itemsPerPage = 10;
            var filteredData = [];

            // DOM elements
            var classesTableBody = document.getElementById('classesTableBody');
            var noClassesMessage = document.getElementById('noClassesMessage');
            var pagination = document.getElementById('pagination');
            var pageNumbers = document.getElementById('pageNumbers');
            var prevPageBtn = document.getElementById('prevPage');
            var nextPageBtn = document.getElementById('nextPage');
            var startRowSpan = document.getElementById('startRow');
            var endRowSpan = document.getElementById('endRow');
            var totalRowsSpan = document.getElementById('totalRows');

            // Modal elements
            var addClassModal = document.getElementById('addClassModal');
            var editClassModal = document.getElementById('editClassModal');
            var qrModal = document.getElementById('qrModal');
            var deleteModal = document.getElementById('deleteModal');
            var addClassBtn = document.getElementById('addClassBtn');
            var cancelAddBtn = document.getElementById('cancelAddBtn');
            var cancelEditBtn = document.getElementById('cancelEditBtn');
            var closeQRBtn = document.getElementById('closeQRBtn');
            var cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
            var addClassForm = document.getElementById('addClassForm');
            var editClassForm = document.getElementById('editClassForm');
            var qrModalImage = document.getElementById('qrModalImage');
            var qrFeedbackLink = document.getElementById('qrFeedbackLink');

            // Filter elements
            var filterStatus = document.getElementById('filterStatus');
            var filterDate = document.getElementById('filterDate');
            var filterType = document.getElementById('filterType');
            var filterLevel = document.getElementById('filterLevel');
            var applyFilterBtn = document.getElementById('applyFilterBtn');
            var resetFilterBtn = document.getElementById('resetFilterBtn');

            // Class to be deleted
            var classToDelete = null;

            // Initialize
            function init() {
                filteredData = classesData.slice();
                renderTable();
                setupEventListeners();
            }

            // Setup event listeners
            function setupEventListeners() {
                // Add class button
                addClassBtn.addEventListener('click', function () {
                    addClassModal.classList.remove('hidden');
                });

                // Cancel buttons
                cancelAddBtn.addEventListener('click', function () {
                    addClassModal.classList.add('hidden');
                });

                cancelEditBtn.addEventListener('click', function () {
                    editClassModal.classList.add('hidden');
                });

                closeQRBtn.addEventListener('click', function () {
                    qrModal.classList.add('hidden');
                });

                // Form submissions
                addClassForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    saveNewClass();
                });

                editClassForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    updateClass();
                });

                // Filter buttons
                applyFilterBtn.addEventListener('click', applyFilters);
                resetFilterBtn.addEventListener('click', resetFilters);

                // Pagination buttons
                prevPageBtn.addEventListener('click', function () {
                    if (currentPage > 1) {
                        currentPage--;
                        renderTable();
                    }
                });

                nextPageBtn.addEventListener('click', function () {
                    var totalPages = Math.ceil(filteredData.length / itemsPerPage);
                    if (currentPage < totalPages) {
                        currentPage++;
                        renderTable();
                    }
                });

                // Delete buttons
                cancelDeleteBtn.addEventListener('click', function () {
                    deleteModal.classList.add('hidden');
                });

                document.getElementById('confirmDeleteBtn').addEventListener('click', function () {
                    if (classToDelete) {
                        deleteClass(classToDelete);
                        deleteModal.classList.add('hidden');
                        classToDelete = null;
                    }
                });
            }

            // Render classes table
            function renderTable() {
                var startIndex = (currentPage - 1) * itemsPerPage;
                var endIndex = Math.min(startIndex + itemsPerPage, filteredData.length);
                var pageData = filteredData.slice(startIndex, endIndex);

                // Clear table
                classesTableBody.innerHTML = '';

                if (pageData.length === 0) {
                    noClassesMessage.classList.remove('hidden');
                    classesTableBody.parentElement.classList.add('hidden');
                    pagination.classList.add('hidden');
                    return;
                }

                noClassesMessage.classList.add('hidden');
                classesTableBody.parentElement.classList.remove('hidden');
                pagination.classList.remove('hidden');

                // Add rows
                for (var i = 0; i < pageData.length; i++) {
                    var classItem = pageData[i];
                    var row = document.createElement('tr');

                    // Format date and time
                    var formattedDate = new Date(classItem.classDate + 'T' + classItem.classStartTime).toLocaleDateString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric'
                    });
                    var timeRange = classItem.classStartTime + ' - ' + classItem.classEndTime;

                    // Status badge
                    var statusBadge = '';
                    if (classItem.classStatus === 'active') {
                        statusBadge = '<span class="px-2 py-1 text-xs rounded-full bg-activeBg text-activeText font-medium">Active</span>';
                    } else {
                        statusBadge = '<span class="px-2 py-1 text-xs rounded-full bg-inactiveBg text-inactiveText font-medium">Inactive</span>';
                    }

                    // Instructor info
                    var instructorInfo = '<div class="space-y-1">';
                    instructorInfo += '<div class="text-sm font-medium text-espresso">' + classItem.confirmedInstructor + '</div>';
                    if (classItem.pendingInstructor && classItem.confirmedInstructor !== "N/A") {
                        instructorInfo += '<div class="text-xs text-warningText bg-warningBg/30 px-2 py-1 rounded">Pending: ' + classItem.pendingInstructor + '</div>';
                    }
                    instructorInfo += '</div>';

                    // Type and level chips
                    var typeChipColor = classItem.classType === 'mat pilates' ? 'bg-chipSand' : 'bg-chipTeal';
                    var levelChipColor = '';
                    if (classItem.classLevel === 'beginner') {
                        levelChipColor = 'bg-successBg text-successText';
                    } else if (classItem.classLevel === 'intermediate') {
                        levelChipColor = 'bg-warningBg text-warningText';
                    } else {
                        levelChipColor = 'bg-dangerBg text-dangerText';
                    }

                    row.innerHTML =
                            '<td class="px-6 py-4">' +
                            '<div class="text-sm font-semibold text-espresso">' + classItem.className + '</div>' +
                            '<div class="text-sm text-espressoLighter mt-1">' + classItem.location + '</div>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<div class="text-sm font-medium text-espresso">' + formattedDate + '</div>' +
                            '<div class="text-sm text-espressoLighter">' + timeRange + '</div>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<div class="space-y-1">' +
                            '<span class="inline-block px-2 py-1 text-xs rounded-full ' + typeChipColor + '">' + classItem.classType + '</span>' +
                            '<span class="inline-block px-2 py-1 text-xs rounded-full ' + levelChipColor + ' ml-1">' + classItem.classLevel + '</span>' +
                            '</div>' +
                            '<div class="text-sm text-espressoLighter mt-1">' + classItem.noOfParticipant + ' participants</div>' +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            instructorInfo +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            statusBadge +
                            '</td>' +
                            '<td class="px-6 py-4">' +
                            '<button onclick="viewQRCode(' + classItem.classID + ')" class="inline-block hover:opacity-80 transition-opacity">' +
                            '<img src="' + classItem.qrcode + '" alt="QR Code" class="w-16 h-16 border-2 border-blush rounded-lg shadow-sm">' +
                            '</button>' +
                            '</td>' +
                            '<td class="px-6 py-4 text-sm font-medium">' +
                            '<div class="flex items-center space-x-2">' +
                            '<button onclick="editClass(' + classItem.classID + ')" class="text-teal hover:text-tealHover font-medium">Edit</button>' +
                            '<span class="text-blush">|</span>' +
                            '<button onclick="confirmDelete(' + classItem.classID + ')" class="text-dangerText hover:text-dangerText/80 font-medium">Delete</button>' +
                            '</div>' +
                            '</td>';

                    classesTableBody.appendChild(row);
                }

                // Update pagination info
                updatePaginationInfo();
            }

            // Update pagination information
            function updatePaginationInfo() {
                var totalItems = filteredData.length;
                var totalPages = Math.ceil(totalItems / itemsPerPage);
                var startIndex = (currentPage - 1) * itemsPerPage + 1;
                var endIndex = Math.min(currentPage * itemsPerPage, totalItems);

                startRowSpan.textContent = startIndex;
                endRowSpan.textContent = endIndex;
                totalRowsSpan.textContent = totalItems;

                // Update button states
                prevPageBtn.disabled = currentPage === 1;
                nextPageBtn.disabled = currentPage === totalPages;

                // Generate page numbers
                pageNumbers.innerHTML = '';
                var maxVisiblePages = 5;
                var startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
                var endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

                if (endPage - startPage + 1 < maxVisiblePages) {
                    startPage = Math.max(1, endPage - maxVisiblePages + 1);
                }

                for (var i = startPage; i <= endPage; i++) {
                    var pageBtn = document.createElement('button');
                    pageBtn.textContent = i;
                    pageBtn.className = 'px-3 py-1 rounded text-sm min-w-[40px] transition-colors ' +
                            (i === currentPage ? 'bg-dusty text-whitePure' : 'border border-blush text-espressoLighter hover:bg-blush/30');
                    pageBtn.addEventListener('click', (function (page) {
                        return function () {
                            currentPage = page;
                            renderTable();
                        };
                    })(i));
                    pageNumbers.appendChild(pageBtn);
                }
            }

            // Apply filters
            function applyFilters() {
                filteredData = classesData.filter(function (classItem) {
                    var statusMatch = !filterStatus.value || classItem.classStatus === filterStatus.value;
                    var dateMatch = !filterDate.value || classItem.classDate === filterDate.value;
                    var typeMatch = !filterType.value || classItem.classType === filterType.value;
                    var levelMatch = !filterLevel.value || classItem.classLevel === filterLevel.value;

                    return statusMatch && dateMatch && typeMatch && levelMatch;
                });

                currentPage = 1;
                renderTable();
            }

            // Reset filters
            function resetFilters() {
                filterStatus.value = '';
                filterDate.value = '';
                filterType.value = '';
                filterLevel.value = '';

                filteredData = classesData.slice();
                currentPage = 1;
                renderTable();
            }

            // Save new class
            function saveNewClass() {
                var className = document.getElementById('addClassName').value;
                var classType = document.getElementById('addClassType').value;
                var classLevel = document.getElementById('addClassLevel').value;
                var classDate = document.getElementById('addClassDate').value;
                var classStartTime = document.getElementById('addClassStartTime').value;
                var classEndTime = document.getElementById('addClassEndTime').value;
                var noOfParticipant = document.getElementById('addNoOfParticipant').value;
                var location = document.getElementById('addLocation').value;
                var description = document.getElementById('addDescription').value;

                // Add new class
                var newClassId = classesData.length > 0 ? Math.max.apply(null, classesData.map(function (item) {
                    return item.classID;
                })) + 1 : 1;

                // Generate QR code path (dummy implementation)
                var qrPath = '../qr_codes/class_' + newClassId + '.png';

                var newClass = {
                    classID: newClassId,
                    className: className,
                    classType: classType,
                    classLevel: classLevel,
                    classDate: classDate,
                    classStartTime: classStartTime,
                    classEndTime: classEndTime,
                    noOfParticipant: parseInt(noOfParticipant),
                    location: location,
                    description: description,
                    classStatus: "active",
                    qrcode: qrPath,
                    adminID: 1,
                    confirmedInstructor: "N/A",
                    pendingInstructor: ""
                };

                classesData.push(newClass);

                // Reapply filters and render
                applyFilters();
                addClassModal.classList.add('hidden');

                // Reset form
                addClassForm.reset();

                // Show success message
                alert('Class added successfully! QR code has been generated.');
            }

            // Edit class
            window.editClass = function (classId) {
                var classItem = classesData.find(function (item) {
                    return item.classID === classId;
                });

                if (classItem) {
                    document.getElementById('editClassId').value = classItem.classID;
                    document.getElementById('editClassName').value = classItem.className;
                    document.getElementById('editClassType').value = classItem.classType;
                    document.getElementById('editClassLevel').value = classItem.classLevel;
                    document.getElementById('editClassDate').value = classItem.classDate;
                    document.getElementById('editClassStartTime').value = classItem.classStartTime;
                    document.getElementById('editClassEndTime').value = classItem.classEndTime;
                    document.getElementById('editNoOfParticipant').value = classItem.noOfParticipant;
                    document.getElementById('editLocation').value = classItem.location;
                    document.getElementById('editDescription').value = classItem.description;
                    document.getElementById('generateNewQR').checked = false;

                    editClassModal.classList.remove('hidden');
                }
            };

            // Update class
            function updateClass() {
                var classId = parseInt(document.getElementById('editClassId').value);
                var className = document.getElementById('editClassName').value;
                var classType = document.getElementById('editClassType').value;
                var classLevel = document.getElementById('editClassLevel').value;
                var classDate = document.getElementById('editClassDate').value;
                var classStartTime = document.getElementById('editClassStartTime').value;
                var classEndTime = document.getElementById('editClassEndTime').value;
                var noOfParticipant = document.getElementById('editNoOfParticipant').value;
                var location = document.getElementById('editLocation').value;
                var description = document.getElementById('editDescription').value;
                var generateNewQR = document.getElementById('generateNewQR').checked;

                // Find and update class
                var index = classesData.findIndex(function (item) {
                    return item.classID === classId;
                });

                if (index !== -1) {
                    classesData[index].className = className;
                    classesData[index].classType = classType;
                    classesData[index].classLevel = classLevel;
                    classesData[index].classDate = classDate;
                    classesData[index].classStartTime = classStartTime;
                    classesData[index].classEndTime = classEndTime;
                    classesData[index].noOfParticipant = parseInt(noOfParticipant);
                    classesData[index].location = location;
                    classesData[index].description = description;

                    // Generate new QR code if requested
                    if (generateNewQR) {
                        classesData[index].qrcode = '../qr_codes/class_' + classId + '_updated.png';
                    }
                }

                // Reapply filters and render
                applyFilters();
                editClassModal.classList.add('hidden');

                // Show success message
                alert('Class updated successfully!' + (generateNewQR ? ' New QR code has been generated.' : ''));
            }
            ;

            // Confirm delete
            window.confirmDelete = function (classId) {
                classToDelete = classId;
                deleteModal.classList.remove('hidden');
            };

            // Delete class
            function deleteClass(classId) {
                var index = classesData.findIndex(function (item) {
                    return item.classID === classId;
                });

                if (index !== -1) {
                    classesData.splice(index, 1);
                    applyFilters();
                    alert('Class deleted successfully!');
                }
            }
            ;

            // View QR code in modal
            window.viewQRCode = function (classId) {
                var classItem = classesData.find(function (item) {
                    return item.classID === classId;
                });

                if (classItem) {
                    qrModalImage.src = classItem.qrcode;
                    qrFeedbackLink.href = '../instructor/feedback.jsp?classId=' + classId;
                    qrModal.classList.remove('hidden');
                }
            };

            // Initialize when DOM is loaded
            document.addEventListener('DOMContentLoaded', init);
        </script>

    </body>
</html>