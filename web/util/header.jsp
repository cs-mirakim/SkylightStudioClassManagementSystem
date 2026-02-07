<%@ page import="com.skylightstudio.classmanagement.util.SessionUtil" %>
<%@ page import="com.skylightstudio.classmanagement.model.Admin" %>
<%@ page import="com.skylightstudio.classmanagement.model.Instructor" %>
<%@ page import="com.skylightstudio.classmanagement.dao.RegistrationDAO" %>
<%@ page import="com.skylightstudio.classmanagement.dao.ClassConfirmationDAO" %>
<%@ page import="com.skylightstudio.classmanagement.dao.ClassDAO" %>
<%@ page import="java.sql.SQLException" %>

<%
    // Check if user is logged in
    if (!SessionUtil.isLoggedIn(session)) {
        response.sendRedirect("../general/login.jsp");
        return;
    }

    // Get user info from session
    String userRole = SessionUtil.getUserRole(session);
    Integer userId = SessionUtil.getUserId(session);
    String userEmail = SessionUtil.getUserEmail(session);

    // Initialize username and name
    String userName = "";
    String username = "";

    // Get user object based on role
    Admin admin = null;
    Instructor instructor = null;

    if ("admin".equals(userRole)) {
        admin = SessionUtil.getAdminObject(session);
        if (admin != null) {
            userName = admin.getName();
            username = admin.getUsername();
        }
    } else if ("instructor".equals(userRole)) {
        instructor = SessionUtil.getInstructorObject(session);
        if (instructor != null) {
            userName = instructor.getName();
            username = instructor.getUsername();
        }
    }

    // Get profile image path
    String profileImagePath = null;
    String avatarLetter = "U";

    if (admin != null && admin.getProfileImageFilePath() != null) {
        profileImagePath = "../" + admin.getProfileImageFilePath();
    } else if (instructor != null && instructor.getProfileImageFilePath() != null) {
        profileImagePath = "../" + instructor.getProfileImageFilePath();
    }

    // Determine avatar letter from username
    if (username != null && !username.isEmpty()) {
        avatarLetter = username.substring(0, 1).toUpperCase();
    } else if (userName != null && !userName.isEmpty()) {
        avatarLetter = userName.substring(0, 1).toUpperCase();
    }

    // Get REAL notification count from database
    int inboxCount = 0;
    String inboxLink = "#";

    try {
        if ("admin".equals(userRole)) {
            inboxLink = "../admin/inboxMessages_admin.jsp";

            // Count from database using EXISTING methods
            RegistrationDAO registrationDAO = new RegistrationDAO();
            ClassConfirmationDAO classConfirmationDAO = new ClassConfirmationDAO();

            int pendingRegistrations = registrationDAO.countPendingRegistrations(); // Method yang dah ada
            int cancelledClasses = classConfirmationDAO.getCancelledClasses().size(); // Count dari list yang dah ada

            inboxCount = pendingRegistrations + cancelledClasses;

            // Update session
            SessionUtil.updateInboxCountForAdmin(session, inboxCount);

        } else if ("instructor".equals(userRole)) {
            inboxLink = "../instructor/inboxMessages_instructor.jsp";

            // Count from database
            ClassDAO classDAO = new ClassDAO();
            inboxCount = classDAO.getNotificationsForInstructor(userId).size(); // Count dari list

            // Update session
            SessionUtil.updateInboxCountForInstructor(session, inboxCount);
        }
    } catch (SQLException e) {
        System.err.println("[Header] Error counting notifications: " + e.getMessage());
        inboxCount = 0;
    }

    // Determine display role text
    String displayRole = "User";
    if ("admin".equals(userRole)) {
        displayRole = "Admin";
    } else if ("instructor".equals(userRole)) {
        displayRole = "Instructor";
    }
%>

<header class="bg-whitePure/80 backdrop-blur-md text-espresso flex items-center justify-between px-6 py-4 shadow-sm border-b border-petal w-full sticky top-0 z-30 font-sans">

    <div class="flex items-center justify-start w-1/4">
        <button id="sidebarBtn" 
                class="group p-2 rounded-xl hover:bg-petal/50 transition-all duration-200 active:scale-95"
                aria-label="Toggle sidebar">
            <svg class="w-6 h-6 text-espresso/70 group-hover:text-dusty transition-colors" fill="none" stroke="currentColor" stroke-width="2"
                 viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
        </button>
    </div>

    <div class="flex-1 flex flex-col items-center">
        <h1 class="text-2xl font-extrabold tracking-wider text-dusty leading-none">
            Skylight Studio
        </h1>
        <span class="hidden md:block text-[9px] font-bold text-espresso uppercase tracking-[0.3em] mt-1.5">
            Class Management System
        </span>
    </div>

    <div class="flex items-center justify-end gap-4 w-1/4">

        <% if (inboxCount > 0) {%>
        <a href="<%= inboxLink%>" 
           class="relative p-2 rounded-xl hover:bg-petal/50 transition-all text-espresso/60 hover:text-dusty"
           aria-label="Inbox">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"></path>
            </svg>
            <span id="header-inbox-badge" class="absolute top-2 right-2 bg-dusty text-whitePure text-[8px] font-bold rounded-full h-3.5 w-3.5 flex items-center justify-center ring-2 ring-whitePure">
                <%= inboxCount%>
            </span>
        </a>
        <% }%>

        <a href="../general/profile.jsp"
           class="flex items-center gap-3 pl-3 pr-1 py-1 rounded-xl border border-petal hover:border-dusty/30 hover:bg-cloud transition-all group">
            <div class="flex flex-col items-end leading-tight hidden sm:flex text-right">
                <span class="text-[9px] font-bold text-espresso/40 uppercase tracking-tighter">
                    <%= displayRole%>
                </span>
                <span class="text-sm font-bold text-espresso group-hover:text-dusty transition-colors">
                    Hi, <%= username != null ? username : (userName != null ? userName : "User")%>
                </span>
            </div>
            <div class="w-9 h-9 bg-blush text-dusty rounded-lg flex items-center justify-center text-sm font-black shadow-sm ring-1 ring-dusty/10 transition-colors group-hover:bg-dusty group-hover:text-whitePure overflow-hidden">
                <% if (profileImagePath != null) {%>
                <img src="<%= profileImagePath%>" 
                     alt="Profile Picture"
                     class="w-full h-full object-cover rounded-lg"
                     onerror="this.style.display='none'; this.parentElement.textContent='<%= avatarLetter%>';" />
                <% } else {%>
                <%= avatarLetter%>
                <% }%>
            </div>
        </a>
    </div>
</header>

<script>
    // Auto-refresh inbox count every 30 seconds (AJAX polling)
    (function () {
        var refreshInterval = 30000; // 30 seconds

        function refreshInboxCount() {
            var xhr = new XMLHttpRequest();
            var userRole = '<%= userRole%>';
            var url = userRole === 'admin'
                    ? '<%= request.getContextPath()%>/admin/inbox-messages?action=count-unread'
                    : '<%= request.getContextPath()%>/instructor/inboxMessages_instructor?action=count-unread';

            xhr.open('GET', url, true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var count = response.unreadCount || response.totalCount || 0;

                        var badge = document.getElementById('header-inbox-badge');
                        if (badge) {
                            badge.textContent = count;

                            // Show/hide badge parent
                            var badgeParent = badge.closest('a');
                            if (count > 0) {
                                if (badgeParent)
                                    badgeParent.style.display = '';
                            } else {
                                if (badgeParent)
                                    badgeParent.style.display = 'none';
                            }
                        }
                    } catch (e) {
                        console.error('Error parsing inbox count:', e);
                    }
                }
            };
            xhr.send();
        }

        // Refresh every 30 seconds
        setInterval(refreshInboxCount, refreshInterval);
    })();
</script>