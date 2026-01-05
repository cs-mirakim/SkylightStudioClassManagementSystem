<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Admin Inbox Messages Page</title>

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
                            espressoLight: '#5C4F4F',
                            espressoLighter: '#7A6A6A',
                            successText: '#1E3A1E',
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',
                            successBg: '#D4EDDA',
                            successBorder: '#C3E6CB',
                            successTextDark: '#155724',
                            warningBg: '#FFF3CD',
                            warningBorder: '#FFEEBA',
                            warningText: '#856404',
                            dangerBg: '#F8D7DA',
                            dangerBorder: '#F5C6CB',
                            dangerText: '#721C24',
                            infoBg: '#D1ECF1',
                            infoBorder: '#BEE5EB',
                            infoText: '#0C5460',
                            urgentRed: '#DC2626',
                            urgentBg: '#FEE2E2',
                            highPriority: '#F59E0B',
                            highBg: '#FEF3C7',
                            normalPriority: '#6D9B9B',
                            normalBg: '#E0F2F1',
                            softGray: '#F8F9FA',
                            borderGray: '#E9ECEF'
                        }
                    }
                }
            }
        </script>

        <style>
            .scrollbar-thin::-webkit-scrollbar {
                width: 6px;
                height: 6px;
            }
            .scrollbar-thin::-webkit-scrollbar-track {
                background: #F8F9FA;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb {
                background: #CED4DA;
                border-radius: 3px;
            }
            .scrollbar-thin::-webkit-scrollbar-thumb:hover {
                background: #B36D6D;
            }
            .notification-item {
                transition: all 0.2s ease;
                border-bottom: 1px solid #E9ECEF;
            }
            .notification-item:last-child {
                border-bottom: none;
            }
            .notification-item:hover {
                background-color: #F8F9FA;
            }
            .notification-item.unread {
                background-color: #F8FAFC;
                position: relative;
            }
            .notification-item.unread::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 3px;
                background-color: #6D9B9B;
            }
            .notification-item.urgent {
                background-color: #FFF5F5;
            }
            .notification-item.urgent::before {
                background-color: #DC2626;
            }
            .notification-type-icon {
                width: 36px;
                height: 36px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-right: 12px;
            }
            .notification-type-register {
                background-color: #E0F2F1;
                color: #0D9488;
            }
            .notification-type-cancel {
                background-color: #FEE2E2;
                color: #DC2626;
            }
            .urgency-badge {
                display: inline-flex;
                align-items: center;
                padding: 3px 8px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .urgency-high {
                background-color: #FEF3C7;
                color: #92400E;
                border: 1px solid #FDE68A;
            }
            .urgency-normal {
                background-color: #E0F2F1;
                color: #0D9488;
                border: 1px solid #99F6E4;
            }
            .status-chip {
                display: inline-flex;
                align-items: center;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: 500;
            }
            .status-pending {
                background-color: #FEF3C7;
                color: #92400E;
            }
            .status-approved {
                background-color: #D1FAE5;
                color: #065F46;
            }
            .status-rejected {
                background-color: #FEE2E2;
                color: #991B1B;
            }
            .status-action-required {
                background-color: #FEF3C7;
                color: #92400E;
            }
            .status-resolved {
                background-color: #D1FAE5;
                color: #065F46;
            }
            .action-btn {
                padding: 6px 14px;
                border-radius: 6px;
                font-size: 13px;
                font-weight: 500;
                transition: all 0.2s;
                border: 1px solid;
            }
            .action-btn-mark {
                background-color: #6D9B9B;
                color: white;
                border-color: #557878;
            }
            .action-btn-mark:hover {
                background-color: #557878;
            }
            .action-btn-read {
                background-color: #F8F9FA;
                color: #6C757D;
                border-color: #E9ECEF;
            }
            .action-btn-read:hover {
                background-color: #E9ECEF;
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
                        <div class="mb-4 md:mb-0">
                            <h1 class="text-2xl font-semibold text-espresso mb-2">
                                Admin Inbox Messages
                            </h1>
                            <p class="text-sm text-espressoLighter">
                                Instructor registrations and class cancellation alerts
                            </p>
                        </div>
                        <div class="flex items-center space-x-3">
                            <button id="refreshBtn" 
                                    class="flex items-center px-4 py-2.5 bg-whitePure border border-borderGray rounded-lg text-espresso hover:bg-softGray transition-colors">
                                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                </svg>
                                Refresh
                            </button>
                            <div id="unreadBadge" class="flex items-center px-3 py-1.5 bg-dangerBg border border-dangerBorder rounded-full">
                                <svg class="w-4 h-4 text-dangerText mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
                                </svg>
                                <span id="unreadCount" class="text-dangerText font-medium">0</span>
                                <span class="text-dangerText ml-1">unread</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Inbox Container -->
                <div class="flex-1 flex flex-col">
                    <!-- No Notifications Message -->
                    <div id="noNotifications" class="hidden flex-1 flex flex-col items-center justify-center p-12 text-center">
                        <div class="w-20 h-20 bg-blush/20 rounded-full flex items-center justify-center mb-6">
                            <svg class="w-10 h-10 text-espresso/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-espresso mb-2">No notifications</h3>
                        <p class="text-espressoLighter max-w-sm">You're all caught up! Check back later for new notifications.</p>
                    </div>

                    <!-- Notifications List -->
                    <div id="notificationsList" class="bg-whitePure rounded-lg border border-borderGray overflow-hidden">
                        <!-- Notifications will be loaded here by JavaScript -->
                    </div>

                    <!-- Pagination -->
                    <div id="pagination" class="mt-6 flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
                        <div class="text-sm text-espressoLighter">
                            Showing <span id="startRow">1</span> to <span id="endRow">10</span> of <span id="totalRows">0</span> notifications
                        </div>
                        <div class="flex items-center space-x-2">
                            <button id="prevPage" class="px-3 py-2 border border-borderGray rounded text-espressoLighter hover:bg-softGray disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex items-center">
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                                </svg>
                                Previous
                            </button>
                            <div id="pageNumbers" class="flex space-x-1">
                                <!-- Page numbers will be inserted here -->
                            </div>
                            <button id="nextPage" class="px-3 py-2 border border-borderGray rounded text-espressoLighter hover:bg-softGray disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex items-center">
                                Next
                                <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </main>

        <jsp:include page="../util/footer.jsp" />

        <jsp:include page="../util/sidebar.jsp" />

        <script src="../util/sidebar.js"></script>

        <script>
            // Dummy data for notifications
            function generateNotifications() {
                var notifications = [];
                var instructors = ['Sarah Johnson', 'Mike Chen', 'David Lee', 'Lisa Wong', 'Emma Wilson', 'James Brown', 'Alex Taylor', 'Maria Garcia'];
                var classes = ['Morning Pilates', 'Advanced Reformer', 'Evening Relaxation', 'Power Pilates', 'Beginner Reformer', 'Yoga Flow', 'HIIT Class', 'Zumba Dance'];
                var reasons = ['Sick leave', 'Personal emergency', 'Schedule conflict', 'Family matter', 'Transportation issue', 'Weather conditions'];

                var today = new Date();

                // Generate registration notifications (no urgency - always normal)
                for (var i = 0; i < 20; i++) {
                    var date = new Date(today);
                    date.setDate(date.getDate() - Math.floor(Math.random() * 30));
                    var isRead = Math.random() > 0.4;
                    var instructor = instructors[Math.floor(Math.random() * instructors.length)];
                    var email = instructor.toLowerCase().replace(' ', '.') + '@example.com';
                    var status = Math.random() > 0.7 ? 'approved' : (Math.random() > 0.5 ? 'rejected' : 'pending');

                    notifications.push({
                        id: i + 1,
                        type: 'register',
                        title: 'New Instructor Registration',
                        instructorName: instructor,
                        instructorEmail: email,
                        registerDate: date.toISOString().split('T')[0],
                        status: status,
                        isRead: isRead,
                        urgency: 'normal', // Registration always normal urgency
                        date: date.toISOString(),
                        displayDate: formatDate(date)
                    });
                }

                // Generate cancellation notifications (with urgency levels)
                for (var i = 20; i < 45; i++) {
                    var date = new Date(today);
                    date.setDate(date.getDate() - Math.floor(Math.random() * 30));
                    var isRead = Math.random() > 0.4;
                    var instructor = instructors[Math.floor(Math.random() * instructors.length)];
                    var className = classes[Math.floor(Math.random() * classes.length)];
                    var classDate = new Date(date);
                    classDate.setDate(classDate.getDate() + Math.floor(Math.random() * 7));
                    var reason = reasons[Math.floor(Math.random() * reasons.length)];

                    // Determine urgency based on how close the class date is
                    var daysUntilClass = Math.floor((classDate - today) / (1000 * 60 * 60 * 24));
                    var urgency = daysUntilClass <= 2 ? 'high' : 'normal';
                    var status = urgency === 'high' ? 'action required' : 'resolved';

                    notifications.push({
                        id: i + 1,
                        type: 'cancel',
                        title: 'Class Cancellation',
                        instructorName: instructor,
                        className: className,
                        classDate: classDate.toISOString().split('T')[0],
                        reason: reason,
                        status: status,
                        isRead: isRead,
                        urgency: urgency,
                        date: date.toISOString(),
                        displayDate: formatDate(date)
                    });
                }

                // Sort by urgency (high first), then by date (newest first)
                notifications.sort(function (a, b) {
                    var urgencyOrder = {'high': 0, 'normal': 1};
                    if (urgencyOrder[a.urgency] !== urgencyOrder[b.urgency]) {
                        return urgencyOrder[a.urgency] - urgencyOrder[b.urgency];
                    }
                    return new Date(b.date) - new Date(a.date);
                });

                return notifications;
            }

            function formatDate(date) {
                var now = new Date();
                var diffTime = Math.abs(now - date);
                var diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

                if (diffDays === 0) {
                    var hours = date.getHours();
                    var minutes = date.getMinutes();
                    var ampm = hours >= 12 ? 'PM' : 'AM';
                    hours = hours % 12;
                    hours = hours ? hours : 12;
                    minutes = minutes < 10 ? '0' + minutes : minutes;
                    return 'Today, ' + hours + ':' + minutes + ' ' + ampm;
                } else if (diffDays === 1) {
                    return 'Yesterday';
                } else if (diffDays < 7) {
                    return diffDays + ' days ago';
                } else {
                    return date.toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric'
                    });
                }
            }

            var notificationsData = generateNotifications();
            var currentPage = 1;
            var itemsPerPage = 10;

            // DOM elements
            var notificationsList = document.getElementById('notificationsList');
            var noNotifications = document.getElementById('noNotifications');
            var pagination = document.getElementById('pagination');
            var pageNumbers = document.getElementById('pageNumbers');
            var prevPageBtn = document.getElementById('prevPage');
            var nextPageBtn = document.getElementById('nextPage');
            var startRowSpan = document.getElementById('startRow');
            var endRowSpan = document.getElementById('endRow');
            var totalRowsSpan = document.getElementById('totalRows');
            var refreshBtn = document.getElementById('refreshBtn');
            var unreadBadge = document.getElementById('unreadBadge');
            var unreadCountSpan = document.getElementById('unreadCount');

            function init() {
                renderNotifications();
                updateUnreadCount();
                setupEventListeners();
            }

            function setupEventListeners() {
                refreshBtn.addEventListener('click', function () {
                    notificationsData = generateNotifications();
                    renderNotifications();
                    updateUnreadCount();

                    var originalText = refreshBtn.innerHTML;
                    refreshBtn.innerHTML = '<svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg> Refreshed';
                    refreshBtn.disabled = true;

                    setTimeout(function () {
                        refreshBtn.innerHTML = originalText;
                        refreshBtn.disabled = false;
                    }, 1500);
                });

                prevPageBtn.addEventListener('click', function () {
                    if (currentPage > 1) {
                        currentPage--;
                        renderNotifications();
                    }
                });

                nextPageBtn.addEventListener('click', function () {
                    var totalPages = Math.ceil(notificationsData.length / itemsPerPage);
                    if (currentPage < totalPages) {
                        currentPage++;
                        renderNotifications();
                    }
                });
            }

            function updateUnreadCount() {
                var unreadCount = notificationsData.filter(function (notification) {
                    return !notification.isRead;
                }).length;

                if (unreadCount > 0) {
                    unreadCountSpan.textContent = unreadCount;
                    unreadBadge.classList.remove('hidden');
                } else {
                    unreadBadge.classList.add('hidden');
                }
            }

            function markAsRead(notificationId) {
                var notification = notificationsData.find(function (item) {
                    return item.id === notificationId;
                });

                if (notification && !notification.isRead) {
                    notification.isRead = true;
                    renderNotifications();
                    updateUnreadCount();

                    var item = document.querySelector('.notification-item[data-id="' + notificationId + '"]');
                    if (item) {
                        item.classList.add('bg-successBg', 'bg-opacity-20');
                        setTimeout(function () {
                            item.classList.remove('bg-successBg', 'bg-opacity-20');
                        }, 800);
                    }
                }
            }

            function renderNotifications() {
                var startIndex = (currentPage - 1) * itemsPerPage;
                var endIndex = Math.min(startIndex + itemsPerPage, notificationsData.length);
                var pageData = notificationsData.slice(startIndex, endIndex);

                notificationsList.innerHTML = '';

                if (pageData.length === 0) {
                    noNotifications.classList.remove('hidden');
                    notificationsList.classList.add('hidden');
                    pagination.classList.add('hidden');
                    return;
                }

                noNotifications.classList.add('hidden');
                notificationsList.classList.remove('hidden');
                pagination.classList.remove('hidden');

                for (var i = 0; i < pageData.length; i++) {
                    var notification = pageData[i];
                    var item = document.createElement('div');

                    var itemClass = 'notification-item p-4 ' +
                            (!notification.isRead ? 'unread ' : '') +
                            (notification.urgency === 'high' ? 'urgent' : '');
                    item.className = itemClass;
                    item.setAttribute('data-id', notification.id);

                    // Icon based on type
                    var icon = '';
                    if (notification.type === 'register') {
                        icon = '<div class="notification-type-icon notification-type-register">' +
                                '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>' +
                                '</svg></div>';
                    } else {
                        icon = '<div class="notification-type-icon notification-type-cancel">' +
                                '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
                                '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
                                '</svg></div>';
                    }

                    // Urgency badge (only for cancellations with high urgency)
                    var urgencyBadge = '';
                    if (notification.type === 'cancel' && notification.urgency === 'high') {
                        urgencyBadge = '<span class="urgency-badge urgency-high ml-2">High Priority</span>';
                    } else if (notification.type === 'register') {
                        urgencyBadge = '<span class="urgency-badge urgency-normal ml-2">Registration</span>';
                    } else {
                        urgencyBadge = '<span class="urgency-badge urgency-normal ml-2">Normal</span>';
                    }

                    // Status chip
                    var statusChip = '';
                    var statusClass = '';

                    if (notification.type === 'register') {
                        if (notification.status === 'pending') {
                            statusClass = 'status-chip status-pending';
                        } else if (notification.status === 'approved') {
                            statusClass = 'status-chip status-approved';
                        } else {
                            statusClass = 'status-chip status-rejected';
                        }
                    } else {
                        if (notification.status === 'action required') {
                            statusClass = 'status-chip status-action-required';
                        } else {
                            statusClass = 'status-chip status-resolved';
                        }
                    }

                    statusChip = '<span class="' + statusClass + '">' + notification.status + '</span>';

                    // Content based on type
                    var content = '';
                    if (notification.type === 'register') {
                        content =
                                '<div class="flex-1 min-w-0">' +
                                '<div class="flex items-center mb-1">' +
                                '<h3 class="font-semibold text-espresso truncate">' + notification.instructorName + '</h3>' +
                                urgencyBadge +
                                '</div>' +
                                '<p class="text-sm text-espressoLighter mb-2">' + notification.instructorEmail + ' • Registered on ' + notification.registerDate + '</p>' +
                                '<div class="flex items-center space-x-3">' +
                                statusChip +
                                '<span class="text-xs text-espressoLighter">' + notification.displayDate + '</span>' +
                                '</div>' +
                                '</div>';
                    } else {
                        content =
                                '<div class="flex-1 min-w-0">' +
                                '<div class="flex items-center mb-1">' +
                                '<h3 class="font-semibold text-espresso truncate">' + notification.className + ' cancelled</h3>' +
                                urgencyBadge +
                                '</div>' +
                                '<p class="text-sm text-espressoLighter mb-2">Instructor: ' + notification.instructorName + ' • Reason: ' + notification.reason + '</p>' +
                                '<div class="flex items-center space-x-3">' +
                                statusChip +
                                '<span class="text-xs text-espressoLighter">Class date: ' + notification.classDate + '</span>' +
                                '<span class="text-xs text-espressoLighter">' + notification.displayDate + '</span>' +
                                '</div>' +
                                '</div>';
                    }

                    // Action button
                    var actionButton = '';
                    if (!notification.isRead) {
                        actionButton =
                                '<button onclick="markAsRead(' + notification.id + '); event.stopPropagation();" ' +
                                'class="action-btn action-btn-mark">' +
                                'Mark as Read' +
                                '</button>';
                    } else {
                        actionButton =
                                '<span class="action-btn action-btn-read">Read</span>';
                    }

                    item.innerHTML =
                            '<div class="flex items-start justify-between">' +
                            '<div class="flex items-start flex-1 min-w-0">' +
                            icon +
                            '<div onclick="markAsRead(' + notification.id + ')" class="flex-1 min-w-0 cursor-pointer">' +
                            content +
                            '</div>' +
                            '</div>' +
                            '<div class="ml-4 flex-shrink-0">' +
                            actionButton +
                            '</div>' +
                            '</div>';

                    notificationsList.appendChild(item);
                }

                updatePaginationInfo();
            }

            function updatePaginationInfo() {
                var totalItems = notificationsData.length;
                var totalPages = Math.ceil(totalItems / itemsPerPage);
                var startIndex = (currentPage - 1) * itemsPerPage + 1;
                var endIndex = Math.min(currentPage * itemsPerPage, totalItems);

                startRowSpan.textContent = startIndex;
                endRowSpan.textContent = endIndex;
                totalRowsSpan.textContent = totalItems;

                prevPageBtn.disabled = currentPage === 1;
                nextPageBtn.disabled = currentPage === totalPages;

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
                    pageBtn.className = 'px-3 py-1.5 rounded text-sm min-w-[36px] transition-colors ' +
                            (i === currentPage ? 'bg-dusty text-whitePure' : 'border border-borderGray text-espressoLighter hover:bg-softGray');
                    pageBtn.addEventListener('click', (function (page) {
                        return function () {
                            currentPage = page;
                            renderNotifications();
                        };
                    })(i));
                    pageNumbers.appendChild(pageBtn);
                }
            }

            window.markAsRead = markAsRead;

            document.addEventListener('DOMContentLoaded', init);
        </script>

    </body>
</html>