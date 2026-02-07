// sidebar.js - ES5 Compatible Version with Dynamic Badge
var menus = {
    instructor: [
        {label: 'Profile', href: '../general/profile.jsp'},
        {label: 'Dashboard', href: '../instructor/dashboard_instructor.jsp'},
        {label: 'Schedule (Class List)', href: '../instructor/schedule_instructor.jsp'},
        {label: 'Inbox Messages', href: '../instructor/inboxMessages_instructor.jsp', badgeId: 'inbox'},
        {label: 'Privacy Policy', href: '../general/privacy_policy.jsp'}
    ],
    admin: [
        {label: 'Profile', href: '../general/profile.jsp'},
        {label: 'Dashboard', href: '../admin/dashboard_admin.jsp'},
        {label: 'Class List', href: '../admin/schedule_admin.jsp'},
        {label: 'Monitor Instructor', href: '../admin/monitor_instructor.jsp'},
        {label: 'Review Registration', href: '../admin/review_registration.jsp'},
        {label: 'Inbox Messages', href: '../admin/inboxMessages_admin.jsp', badgeId: 'inbox'},
        {label: 'Privacy Policy', href: '../general/privacy_policy.jsp'}
    ]
};

function initSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebar-overlay');
    var menuContainer = document.getElementById('sidebar-menu');
    var closeBtn = document.getElementById('sidebarClose');

    if (!sidebar || !overlay || !menuContainer)
        return;

    // Get inbox count from sidebar data attribute
    function getInboxCount() {
        var count = sidebar.getAttribute('data-inbox-count');
        return count ? parseInt(count, 10) : 0;
    }

    // Get user role from checked radio button
    function getCurrentUserRole() {
        var adminRadio = document.querySelector('input[name="sidebar_role"][value="admin"]');
        var instructorRadio = document.querySelector('input[name="sidebar_role"][value="instructor"]');

        if (adminRadio && adminRadio.checked)
            return 'admin';
        if (instructorRadio && instructorRadio.checked)
            return 'instructor';
        return 'admin'; // default fallback
    }

    function renderMenu(role) {
        menuContainer.innerHTML = '';
        var items = menus[role] || [];
        var inboxCount = getInboxCount();

        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            var container = document.createElement('div');
            container.className = "flex flex-col";

            var el;
            if (item.href) {
                el = document.createElement('a');
                el.href = item.href;
            } else {
                el = document.createElement('button');
                el.type = 'button';
            }

            el.className = 'w-full flex items-center justify-between px-4 py-4 hover:bg-cloud transition-colors group';

            // Determine badge count
            var badgeCount = 0;
            if (item.badgeId === 'inbox') {
                badgeCount = inboxCount;
            }

            var badgeHtml = (badgeCount > 0)
                    ? '<span class="ml-2 px-2 py-0.5 text-[10px] font-bold bg-dusty text-whitePure rounded-full shadow-sm group-hover:bg-espresso transition-colors">' + badgeCount + '</span>'
                    : '';

            el.innerHTML = '<div class="flex items-center">' +
                    '<span class="text-sm font-semibold text-espresso/90 group-hover:text-dusty">' + item.label + '</span>' +
                    badgeHtml +
                    '</div>' +
                    '<svg class="w-4 h-4 text-dusty/40 group-hover:text-dusty transition-all transform group-hover:translate-x-1" fill="none" stroke="currentColor" stroke-width="3" viewBox="0 0 24 24">' +
                    '<path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"></path>' +
                    '</svg>';

            container.appendChild(el);

            var hr = document.createElement('div');
            hr.className = 'border-t border-espresso/10 w-full';
            container.appendChild(hr);

            menuContainer.appendChild(container);
        }
    }

    function openSidebar() {
        sidebar.classList.remove('-translate-x-full');
        overlay.classList.remove('hidden');
        sidebar.setAttribute('aria-hidden', 'false');
    }

    function closeSidebar() {
        sidebar.classList.add('-translate-x-full');
        overlay.classList.add('hidden');
        sidebar.setAttribute('aria-hidden', 'true');
    }

    var sidebarBtn = document.getElementById('sidebarBtn');
    if (sidebarBtn) {
        sidebarBtn.addEventListener('click', openSidebar);
    }
    if (closeBtn) {
        closeBtn.addEventListener('click', closeSidebar);
    }
    overlay.addEventListener('click', closeSidebar);

    // Initial render
    var initialRole = getCurrentUserRole();
    renderMenu(initialRole);

    // Listen for role changes (radios are disabled, just safety)
    var roleRadios = document.querySelectorAll('input[name="sidebar_role"]');
    for (var i = 0; i < roleRadios.length; i++) {
        roleRadios[i].addEventListener('change', function (e) {
            if (!this.disabled) {
                renderMenu(e.target.value);
            }
        });
    }
}

document.addEventListener('DOMContentLoaded', initSidebar);