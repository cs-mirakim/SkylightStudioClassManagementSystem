<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Instructor Schedule</title>

        <!-- Font Inter + Lora -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        
        <!-- FullCalendar CSS -->
        <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
        
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
        
        <style>
            /* Custom styles for FullCalendar to ensure it stays within container */
            .fc {
                height: 100% !important;
                max-height: 600px;
            }
            
            .fc-view {
                height: 100% !important;
                max-height: 550px;
                overflow-y: auto !important;
            }
            
            .fc-daygrid-month-view .fc-daygrid-body {
                min-height: 0 !important;
            }
            
            .fc-scrollgrid-section-body table {
                height: 100% !important;
            }
            
            /* Ensure calendar stays responsive */
            .fc-toolbar {
                flex-wrap: wrap !important;
                gap: 0.5rem !important;
            }
            
            .fc-toolbar-title {
                font-size: 1.25rem !important;
                margin: 0.5rem 0 !important;
            }
            
            .fc-button-group {
                margin: 0.25rem 0 !important;
            }
            
            .fc-button {
                padding: 0.375rem 0.75rem !important;
                font-size: 0.875rem !important;
            }
            
            /* Custom colors for calendar */
            .fc-header-toolbar {
                margin-bottom: 1rem !important;
            }
            
            .fc-col-header-cell {
                background-color: #F2D1D1 !important;
                color: #3D3434 !important;
                font-weight: 600 !important;
            }
            
            .fc-day-today {
                background-color: #FDF8F8 !important;
            }
            
            .fc-button-primary {
                background-color: #6D9B9B !important;
                border-color: #557878 !important;
            }
            
            .fc-button-primary:hover {
                background-color: #557878 !important;
                border-color: #557878 !important;
            }
            
            .fc-button-primary:disabled {
                background-color: #A3C1D6 !important;
                border-color: #A3C1D6 !important;
            }
            
            .fc-button-primary.fc-button-active {
                background-color: #B36D6D !important;
                border-color: #965656 !important;
            }
            
            .fc-event {
                border-radius: 4px !important;
                border: none !important;
                padding: 2px 4px !important;
                cursor: pointer !important;
            }
            
            /* Event status colors */
            .fc-event-available {
                background-color: #6D9B9B !important;
                border-color: #557878 !important;
            }
            
            .fc-event-confirmed {
                background-color: #A5D6A7 !important;
                border-color: #1B5E20 !important;
                color: #1B5E20 !important;
            }
            
            .fc-event-pending {
                background-color: #FFCC80 !important;
                border-color: #E65100 !important;
                color: #E65100 !important;
            }
            
            /* Modal styles */
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: rgba(61, 52, 52, 0.7);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 1000;
            }
            
            .modal-content {
                background-color: white;
                border-radius: 12px;
                padding: 2rem;
                max-width: 500px;
                width: 90%;
                max-height: 90vh;
                overflow-y: auto;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                animation: modalSlideIn 0.3s ease-out;
            }
            
            @keyframes modalSlideIn {
                from {
                    opacity: 0;
                    transform: translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            .status-badge {
                display: inline-block;
                padding: 0.25rem 0.75rem;
                border-radius: 9999px;
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            
            .status-available {
                background-color: #E8F5E8;
                color: #1B5E20;
            }
            
            .status-confirmed {
                background-color: #E8F5E8;
                color: #1B5E20;
            }
            
            .status-pending {
                background-color: #FFF3E0;
                color: #E65100;
            }
            
            .instructor-info {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                padding: 0.5rem;
                background-color: #F9FAFB;
                border-radius: 8px;
                margin-top: 0.5rem;
            }
            
            .instructor-avatar {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                background-color: #6D9B9B;
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 600;
                font-size: 14px;
            }
            
            .instructor-details {
                flex: 1;
            }
            
            .instructor-name {
                font-weight: 600;
                color: #3D3434;
            }
            
            .instructor-role {
                font-size: 0.75rem;
                color: #6B7280;
            }
            
            .close-icon {
                position: absolute;
                top: 1rem;
                right: 1rem;
                background: none;
                border: none;
                cursor: pointer;
                color: #6B7280;
                transition: color 0.2s ease;
            }
            
            .close-icon:hover {
                color: #3D3434;
            }
        </style>
    </head>

    <body class="bg-cloud font-sans text-espresso flex flex-col min-h-screen">

        <!-- Header -->
        <jsp:include page="../util/header.jsp" />

        <main class="p-4 md:p-6 flex-1 flex flex-col items-center">
            <div class="w-full bg-whitePure py-6 px-6 md:px-8
                 rounded-xl shadow-sm border border-blush flex-1 flex flex-col"
                 style="max-width:1500px">

                <!-- Header -->
                <div class="mb-6 pb-4 border-b border-espresso/10">
                    <h1 class="text-2xl font-bold text-espresso mb-1">
                        Available Classes
                    </h1>
                    <p class="text-sm text-espresso/60">
                        View available classes and confirm your participation as instructor
                    </p>
                </div>

                <!-- Status Legend -->
                <div class="mb-6 p-4 bg-cloud rounded-lg border border-petal">
                    <h3 class="text-sm font-semibold text-espresso mb-2">Status Legend</h3>
                    <div class="flex flex-wrap gap-4">
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full bg-teal mr-2"></div>
                            <span class="text-sm text-espresso">Available - No instructor assigned</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full bg-successBg mr-2"></div>
                            <span class="text-sm text-espresso">Confirmed - You're teaching</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full bg-warningBg mr-2"></div>
                            <span class="text-sm text-espresso">Pending - You're in queue as relief</span>
                        </div>
                    </div>
                </div>

                <!-- Calendar Container with fixed height -->
                <div class="flex-1 min-h-0">
                    <div id="calendar-container" class="h-full flex flex-col">
                        <div id="calendar" class="flex-1 min-h-0"></div>
                    </div>
                </div>

                <!-- No Classes Message (Hidden by default) -->
                <div id="noClassesMessage" class="hidden flex flex-col items-center justify-center py-12 text-center">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-espresso/30 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <h3 class="text-xl font-semibold text-espresso/70 mb-2">
                        No available classes
                    </h3>
                    <p class="text-espresso/50 max-w-md">
                        There are no classes available for registration at the moment.
                    </p>
                </div>

                <!-- Footer -->
                <div class="mt-6 pt-4 border-t border-petal text-center text-xs text-espresso/30">
                    Click on any class to view details and confirm your participation as instructor.
                </div>

            </div>

        </main>

        <!-- Class Details Modal -->
        <div id="classModal" class="modal-overlay hidden">
            <div class="modal-content relative">
                <!-- Close Icon (X) at top right -->
                <button onclick="closeModal()" class="close-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
                
                <div class="mb-6">
                    <h2 class="text-xl font-bold text-espresso" id="modalClassName"></h2>
                </div>
                
                <!-- Status Badge -->
                <div class="mb-6">
                    <span id="modalStatusBadge" class="status-badge"></span>
                </div>
                
                <!-- Class Details -->
                <div class="space-y-4 mb-6">
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Date & Time</h4>
                        <p id="modalDateTime" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Duration</h4>
                        <p id="modalDuration" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Location</h4>
                        <p id="modalLocation" class="text-espresso"></p>
                    </div>
                    
                    <!-- Main Instructor -->
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Main Instructor</h4>
                        <div id="mainInstructorContainer" class="instructor-info">
                            <!-- Dynamic content will be inserted here -->
                        </div>
                    </div>
                    
                    <!-- Relief Instructor -->
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Relief Instructor</h4>
                        <div id="reliefInstructorContainer" class="instructor-info">
                            <!-- Dynamic content will be inserted here -->
                        </div>
                    </div>
                    
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Description</h4>
                        <p id="modalDescription" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Maximum Capacity</h4>
                        <p id="modalCapacity" class="text-espresso"></p>
                    </div>
                    <div>
                        <h4 class="text-sm font-semibold text-espresso/70 mb-1">Current Students</h4>
                        <p id="modalStudents" class="text-espresso"></p>
                    </div>
                </div>
                
                <!-- Action Buttons -->
                <div id="actionButtons" class="flex flex-col gap-3">
                    <!-- Confirm Button (shown when there's no main instructor) -->
                    <button id="confirmBtn" onclick="confirmClass()" 
                            class="w-full bg-teal hover:bg-tealHover text-whitePure font-medium py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 hidden">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                        </svg>
                        Confirm
                    </button>
                    
                    <!-- Pending Button (shown when there's a main instructor but no relief instructor) -->
                    <button id="pendingBtn" onclick="requestPending()" 
                            class="w-full bg-warningBg hover:bg-warningText/20 text-warningText font-medium py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 hidden">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
                        </svg>
                        Pending (Queue as Relief)
                    </button>
                    
                    <!-- Withdraw Button (shown for pending/confirmed classes) -->
                    <button id="withdrawBtn" onclick="withdrawClass()" 
                            class="w-full bg-dangerBg hover:bg-dangerText/20 text-dangerText font-medium py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 hidden">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                        </svg>
                        <span id="withdrawBtnText"></span>
                    </button>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <jsp:include page="../util/footer.jsp" />
        
        <!-- Sidebar -->
        <jsp:include page="../util/sidebar.jsp" />
        <script src="../util/sidebar.js"></script>

        <!-- FullCalendar JS -->
        <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>

        <script>
            // Initialize calendar when page loads
            document.addEventListener('DOMContentLoaded', function() {
                initializeCalendar();
                
                // Highlight current page in sidebar
                highlightCurrentPage();
                
                // Close modal when clicking outside
                document.getElementById('classModal').addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeModal();
                    }
                });
                
                // Close modal with Escape key
                document.addEventListener('keydown', function(e) {
                    if (e.key === 'Escape') {
                        closeModal();
                    }
                });
            });

            function initializeCalendar() {
                var calendarEl = document.getElementById('calendar');
                
                // Sample data with different statuses
                var sampleEvents = [
                    {
                        id: '1',
                        title: 'Yoga Basics',
                        start: getNextMonday() + 'T10:00:00',
                        end: getNextMonday() + 'T11:30:00',
                        status: 'available', // available, confirmed, pending
                        className: 'fc-event-available',
                        extendedProps: {
                            location: 'Room 101',
                            description: 'Beginner yoga class focusing on basic poses and breathing techniques. Suitable for all fitness levels.',
                            capacity: 20,
                            currentStudents: 15,
                            mainInstructor: null, // null or instructor object
                            reliefInstructor: null, // null or instructor object
                            instructorStatus: null, // null, 'confirmed', 'pending'
                            instructorId: null // will be set when instructor confirms
                        }
                    },
                    {
                        id: '2',
                        title: 'Advanced Pilates',
                        start: getNextWednesday() + 'T14:00:00',
                        end: getNextWednesday() + 'T15:30:00',
                        status: 'available',
                        className: 'fc-event-available',
                        extendedProps: {
                            location: 'Studio A',
                            description: 'Advanced pilates for experienced students. Focus on core strength and flexibility.',
                            capacity: 15,
                            currentStudents: 12,
                            mainInstructor: {
                                id: 'instr_002',
                                name: 'Sarah Johnson',
                                initials: 'SJ'
                            },
                            reliefInstructor: null,
                            instructorStatus: null,
                            instructorId: null
                        }
                    },
                    {
                        id: '3',
                        title: 'Morning Meditation',
                        start: getNextFriday() + 'T08:00:00',
                        end: getNextFriday() + 'T09:00:00',
                        status: 'confirmed',
                        className: 'fc-event-confirmed',
                        extendedProps: {
                            location: 'Zen Room',
                            description: 'Guided meditation session for stress relief and mindfulness.',
                            capacity: 25,
                            currentStudents: 18,
                            mainInstructor: {
                                id: 'instr_001',
                                name: 'You (John Doe)',
                                initials: 'JD'
                            },
                            reliefInstructor: null,
                            instructorStatus: 'confirmed',
                            instructorId: 'instr_001'
                        }
                    },
                    {
                        id: '4',
                        title: 'Zumba Dance',
                        start: getNextThursday() + 'T18:00:00',
                        end: getNextThursday() + 'T19:30:00',
                        status: 'pending',
                        className: 'fc-event-pending',
                        extendedProps: {
                            location: 'Dance Studio',
                            description: 'High-energy dance workout with Latin rhythms.',
                            capacity: 30,
                            currentStudents: 22,
                            mainInstructor: {
                                id: 'instr_003',
                                name: 'Maria Rodriguez',
                                initials: 'MR'
                            },
                            reliefInstructor: {
                                id: 'instr_001',
                                name: 'You (John Doe)',
                                initials: 'JD'
                            },
                            instructorStatus: 'pending',
                            instructorId: 'instr_001'
                        }
                    },
                    {
                        id: '5',
                        title: 'Cardio Kickboxing',
                        start: getNextTuesday() + 'T17:00:00',
                        end: getNextTuesday() + 'T18:30:00',
                        status: 'available',
                        className: 'fc-event-available',
                        extendedProps: {
                            location: 'Studio B',
                            description: 'High-intensity cardio workout with kickboxing moves.',
                            capacity: 25,
                            currentStudents: 20,
                            mainInstructor: {
                                id: 'instr_004',
                                name: 'Alex Chen',
                                initials: 'AC'
                            },
                            reliefInstructor: {
                                id: 'instr_005',
                                name: 'Lisa Wang',
                                initials: 'LW'
                            },
                            instructorStatus: null,
                            instructorId: null
                        }
                    }
                ];

                var calendar = new FullCalendar.Calendar(calendarEl, {
                    initialView: 'dayGridMonth',
                    headerToolbar: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'dayGridMonth,timeGridWeek,timeGridDay'
                    },
                    events: sampleEvents,
                    eventClick: function(info) {
                        showClassDetails(info.event);
                    },
                    eventDisplay: 'block',
                    eventTimeFormat: {
                        hour: '2-digit',
                        minute: '2-digit',
                        hour12: true
                    },
                    height: 'auto',
                    contentHeight: 'auto',
                    aspectRatio: 1.5,
                    handleWindowResize: true,
                    windowResize: function(view) {
                        calendar.updateSize();
                    },
                    editable: false,
                    buttonText: {
                        today: 'Today',
                        month: 'Month',
                        week: 'Week',
                        day: 'Day'
                    },
                    views: {
                        timeGridWeek: {
                            dayHeaderFormat: { weekday: 'short', day: 'numeric' },
                            slotMinTime: '06:00:00',
                            slotMaxTime: '22:00:00',
                            allDaySlot: false,
                            eventTimeFormat: {
                                hour: '2-digit',
                                minute: '2-digit',
                                hour12: true
                            }
                        },
                        timeGridDay: {
                            slotMinTime: '06:00:00',
                            slotMaxTime: '22:00:00',
                            allDaySlot: false,
                            eventTimeFormat: {
                                hour: '2-digit',
                                minute: '2-digit',
                                hour12: true
                            }
                        }
                    },
                    eventDidMount: function(info) {
                        // Add status indicator to event
                        const status = info.event.extendedProps.status;
                        const badge = document.createElement('span');
                        badge.className = 'fc-event-status';
                        badge.style.cssText = `
                            position: absolute;
                            top: 2px;
                            right: 2px;
                            width: 6px;
                            height: 6px;
                            border-radius: 50%;
                        `;
                        
                        if (status === 'confirmed') {
                            badge.style.backgroundColor = '#1B5E20';
                        } else if (status === 'pending') {
                            badge.style.backgroundColor = '#E65100';
                        }
                        
                        info.el.appendChild(badge);
                        
                        // Add tooltip
                        let tooltipText = info.event.title;
                        if (status === 'confirmed') {
                            tooltipText += ' (You are teaching)';
                        } else if (status === 'pending') {
                            tooltipText += ' (You are in relief queue)';
                        }
                        info.el.title = tooltipText;
                    }
                });

                calendar.render();

                // Update calendar size after render
                setTimeout(function() {
                    calendar.updateSize();
                }, 100);

                // Update size on window resize
                window.addEventListener('resize', function() {
                    calendar.updateSize();
                });

                // Show/hide no classes message
                if (sampleEvents.length === 0) {
                    document.getElementById('calendar-container').classList.add('hidden');
                    document.getElementById('noClassesMessage').classList.remove('hidden');
                }
                
                // Store calendar instance globally
                window.calendar = calendar;
            }

            function showClassDetails(event) {
                const modal = document.getElementById('classModal');
                const props = event.extendedProps;
                
                // Set modal content
                document.getElementById('modalClassName').textContent = event.title;
                document.getElementById('modalDateTime').textContent = 
                    event.start.toLocaleDateString() + ' • ' + 
                    event.start.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) + ' - ' +
                    event.end.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                
                // Calculate duration
                const durationMs = event.end - event.start;
                const durationHours = Math.floor(durationMs / (1000 * 60 * 60));
                const durationMinutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60));
                document.getElementById('modalDuration').textContent = 
                    durationHours + 'h ' + durationMinutes + 'min';
                
                document.getElementById('modalLocation').textContent = props.location;
                document.getElementById('modalDescription').textContent = props.description;
                document.getElementById('modalCapacity').textContent = props.capacity + ' students';
                document.getElementById('modalStudents').textContent = props.currentStudents + ' students enrolled';
                
                // Set status badge
                const statusBadge = document.getElementById('modalStatusBadge');
                let statusText = '';
                if (props.status === 'available') {
                    statusText = props.mainInstructor ? 'Available (Has Instructor)' : 'Available (No Instructor)';
                } else if (props.status === 'confirmed') {
                    statusText = 'Confirmed (You\'re Teaching)';
                } else if (props.status === 'pending') {
                    statusText = 'Pending (In Relief Queue)';
                }
                statusBadge.textContent = statusText;
                statusBadge.className = 'status-badge status-' + props.status;
                
                // Display instructor information
                displayInstructorInfo('mainInstructorContainer', props.mainInstructor, 'Main Instructor');
                displayInstructorInfo('reliefInstructorContainer', props.reliefInstructor, 'Relief Instructor');
                
                // Show/hide action buttons based on status
                const confirmBtn = document.getElementById('confirmBtn');
                const pendingBtn = document.getElementById('pendingBtn');
                const withdrawBtn = document.getElementById('withdrawBtn');
                const withdrawBtnText = document.getElementById('withdrawBtnText');
                
                // Reset all buttons
                confirmBtn.classList.add('hidden');
                pendingBtn.classList.add('hidden');
                withdrawBtn.classList.add('hidden');
                
                // Current instructor info (you)
                const currentInstructorId = 'instr_001'; // This should come from session/authentication
                const currentInstructorName = 'You (John Doe)';
                const currentInstructorInitials = 'JD';
                
                // Check if user is already assigned to this class
                const isMainInstructor = props.mainInstructor && props.mainInstructor.id === currentInstructorId;
                const isReliefInstructor = props.reliefInstructor && props.reliefInstructor.id === currentInstructorId;
                const isAssigned = isMainInstructor || isReliefInstructor;
                
                // Determine button visibility based on class status and instructor assignments
                if (props.status === 'available') {
                    if (!isAssigned) {
                        // User is not assigned to this class
                        if (!props.mainInstructor) {
                            // No main instructor - show BOTH Confirm and Pending buttons
                            confirmBtn.classList.remove('hidden');
                            pendingBtn.classList.remove('hidden');
                        } else if (props.mainInstructor && !props.reliefInstructor) {
                            // Has main instructor but no relief - show Pending button
                            pendingBtn.classList.remove('hidden');
                        }
                        // If both instructors are assigned, no buttons are shown
                    } else {
                        // User is already assigned to this class - show Withdraw button
                        withdrawBtn.classList.remove('hidden');
                        if (isMainInstructor) {
                            withdrawBtnText.textContent = 'Withdraw as Main Instructor';
                        } else if (isReliefInstructor) {
                            withdrawBtnText.textContent = 'Withdraw as Relief Instructor';
                        }
                    }
                } else if (props.status === 'confirmed') {
                    // You are the main instructor (confirmed status means you're teaching)
                    if (isMainInstructor) {
                        withdrawBtn.classList.remove('hidden');
                        withdrawBtnText.textContent = 'Withdraw as Instructor';
                    }
                } else if (props.status === 'pending') {
                    // You are in the relief queue
                    if (isReliefInstructor) {
                        withdrawBtn.classList.remove('hidden');
                        withdrawBtnText.textContent = 'Cancel Relief Request';
                    }
                }
                
                // Store current event ID for actions
                modal.setAttribute('data-event-id', event.id);
                
                // Show modal
                modal.classList.remove('hidden');
                document.body.style.overflow = 'hidden';
            }

            function displayInstructorInfo(containerId, instructor, role) {
                const container = document.getElementById(containerId);
                container.innerHTML = '';
                
                if (!instructor) {
                    container.innerHTML = `
                        <div class="text-center text-espresso/60 py-2">
                            <i class="fas fa-user-slash mr-2"></i>
                            No ${role.toLowerCase()} assigned
                        </div>
                    `;
                } else {
                    const isYou = instructor.id === 'instr_001'; // Check if this is the current user
                    container.innerHTML = `
                        <div class="instructor-avatar">${instructor.initials}</div>
                        <div class="instructor-details">
                            <div class="instructor-name">${instructor.name}</div>
                            <div class="instructor-role">${role} ${isYou ? '(You)' : ''}</div>
                        </div>
                    `;
                }
            }

            function closeModal() {
                document.getElementById('classModal').classList.add('hidden');
                document.body.style.overflow = 'auto';
            }

            function confirmClass() {
                const modal = document.getElementById('classModal');
                const eventId = modal.getAttribute('data-event-id');
                const event = window.calendar.getEventById(eventId);
                
                if (event && confirm('Are you sure you want to confirm as the main instructor for this class?')) {
                    // In production, send AJAX request to server
                    simulateApiCall('confirm', eventId).then(success => {
                        if (success) {
                            // Update event status and instructor info
                            const currentInstructor = {
                                id: 'instr_001',
                                name: 'You (John Doe)',
                                initials: 'JD'
                            };
                            
                            event.setProp('status', 'confirmed');
                            event.setProp('className', 'fc-event-confirmed');
                            event.setExtendedProp('mainInstructor', currentInstructor);
                            event.setExtendedProp('instructorStatus', 'confirmed');
                            event.setExtendedProp('instructorId', 'instr_001');
                            
                            // Show success message
                            alert('Successfully confirmed as main instructor for ' + event.title);
                            closeModal();
                            
                            // Refresh calendar to show updated status
                            window.calendar.render();
                        }
                    });
                }
            }

            function requestPending() {
                const modal = document.getElementById('classModal');
                const eventId = modal.getAttribute('data-event-id');
                const event = window.calendar.getEventById(eventId);
                
                if (event && confirm('Request to be added as relief instructor for this class?')) {
                    // In production, send AJAX request to server
                    simulateApiCall('pending', eventId).then(success => {
                        if (success) {
                            // Update event status and relief instructor info
                            const currentInstructor = {
                                id: 'instr_001',
                                name: 'You (John Doe)',
                                initials: 'JD'
                            };
                            
                            // Check if user is already main instructor (shouldn't happen but just in case)
                            if (event.extendedProps.mainInstructor && 
                                event.extendedProps.mainInstructor.id === 'instr_001') {
                                alert('You are already the main instructor for this class!');
                                return;
                            }
                            
                            event.setProp('status', 'pending');
                            event.setProp('className', 'fc-event-pending');
                            event.setExtendedProp('reliefInstructor', currentInstructor);
                            event.setExtendedProp('instructorStatus', 'pending');
                            event.setExtendedProp('instructorId', 'instr_001');
                            
                            // Show success message
                            alert('Successfully added to relief queue for ' + event.title);
                            closeModal();
                            
                            // Refresh calendar
                            window.calendar.render();
                        }
                    });
                }
            }

            function withdrawClass() {
                const modal = document.getElementById('classModal');
                const eventId = modal.getAttribute('data-event-id');
                const event = window.calendar.getEventById(eventId);
                const props = event.extendedProps;
                const isMainInstructor = props.mainInstructor && 
                                       props.mainInstructor.id === 'instr_001';
                const isReliefInstructor = props.reliefInstructor && 
                                         props.reliefInstructor.id === 'instr_001';
                
                let message = '';
                let actionType = '';
                
                if (isMainInstructor) {
                    message = 'Are you sure you want to withdraw as the main instructor for this class?';
                    actionType = 'withdraw_main';
                } else if (isReliefInstructor) {
                    message = 'Are you sure you want to cancel your relief request for this class?';
                    actionType = 'withdraw_relief';
                }
                
                if (event && message && confirm(message)) {
                    // In production, send AJAX request to server
                    simulateApiCall(actionType, eventId).then(success => {
                        if (success) {
                            // Update event status based on withdrawal type
                            if (actionType === 'withdraw_main') {
                                // Withdrawing as main instructor - class becomes available
                                event.setProp('status', 'available');
                                event.setProp('className', 'fc-event-available');
                                event.setExtendedProp('mainInstructor', null);
                                event.setExtendedProp('instructorStatus', null);
                                event.setExtendedProp('instructorId', null);
                                
                                alert('Successfully withdrawn as main instructor from ' + event.title);
                            } else if (actionType === 'withdraw_relief') {
                                // Withdrawing as relief instructor - remove from relief queue
                                if (props.status === 'pending') {
                                    event.setProp('status', 'available');
                                    event.setProp('className', 'fc-event-available');
                                }
                                event.setExtendedProp('reliefInstructor', null);
                                event.setExtendedProp('instructorStatus', null);
                                event.setExtendedProp('instructorId', null);
                                
                                alert('Successfully cancelled relief request for ' + event.title);
                            }
                            
                            closeModal();
                            
                            // Refresh calendar
                            window.calendar.render();
                        }
                    });
                }
            }

            // Simulate API call (replace with actual AJAX call)
            function simulateApiCall(action, eventId) {
                return new Promise(resolve => {
                    setTimeout(() => {
                        console.log(`${action} action for event ${eventId}`);
                        // Simulate successful API response
                        resolve(true);
                        
                        // In production, handle errors:
                        // if (error) {
                        //     alert('Error: ' + error.message);
                        //     resolve(false);
                        // }
                    }, 500);
                });
            }
            
            function highlightCurrentPage() {
                const currentPage = 'schedule_instructor.jsp';
                const sidebarLinks = document.querySelectorAll('#sidebar a');
                
                sidebarLinks.forEach(link => {
                    const href = link.getAttribute('href');
                    if (href && href.includes(currentPage)) {
                        link.classList.add('bg-blush/30', 'text-dusty', 'font-medium');
                        link.classList.remove('hover:bg-blush/20', 'text-espresso');
                    }
                });
            }

            // Helper functions for sample dates
            function getNextMonday() {
                var date = new Date();
                date.setDate(date.getDate() + (1 + 7 - date.getDay()) % 7);
                return date.toISOString().split('T')[0];
            }

            function getNextTuesday() {
                var date = new Date();
                date.setDate(date.getDate() + (2 + 7 - date.getDay()) % 7);
                return date.toISOString().split('T')[0];
            }

            function getNextWednesday() {
                var date = new Date();
                date.setDate(date.getDate() + (3 + 7 - date.getDay()) % 7);
                return date.toISOString().split('T')[0];
            }

            function getNextThursday() {
                var date = new Date();
                date.setDate(date.getDate() + (4 + 7 - date.getDay()) % 7);
                return date.toISOString().split('T')[0];
            }

            function getNextFriday() {
                var date = new Date();
                date.setDate(date.getDate() + (5 + 7 - date.getDay()) % 7);
                return date.toISOString().split('T')[0];
            }
        </script>

    </body>
</html>