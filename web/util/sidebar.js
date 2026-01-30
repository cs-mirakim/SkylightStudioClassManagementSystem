// sidebar.js - Versi tanpa logout functions (logout sudah ada dalam sidebar.jsp)

const menus = {
    instructor: [
        {label: 'Profile', href: '../general/profile.jsp'},
        {label: 'Dashboard (My Schedule)', href: '../instructor/dashboard_instructor.jsp'},
        {label: 'Schedule (Class List)', href: '../instructor/schedule_instructor.jsp'},
        {label: 'Inbox Messages', href: '../instructor/inboxMessages_instructor.jsp', badge: 3},
        {label: 'Privacy Policy', href: '../general/privacy_policy.jsp'}
    ],
    admin: [
        {label: 'Profile', href: '../general/profile.jsp'},
        {label: 'Dashboard', href: '../admin/dashboard_admin.jsp'},
        {label: 'Schedule (Class List)', href: '../admin/schedule_admin.jsp'},
        {label: 'Monitor Instructor', href: '../admin/monitor_instructor.jsp'},
        {label: 'Review Registration', href: '../admin/review_registration.jsp'},
        {label: 'Inbox Messages', href: '../admin/inboxMessages_admin.jsp', badge: 12},
        {label: 'Privacy Policy', href: '../general/privacy_policy.jsp'}
    ]
};

function initSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const menuContainer = document.getElementById('sidebar-menu');
    const closeBtn = document.getElementById('sidebarClose');

    if (!sidebar || !overlay || !menuContainer)
        return;

    function renderMenu(role) {
        menuContainer.innerHTML = '';
        const items = menus[role] || [];

        items.forEach((item) => {
            const container = document.createElement('div');
            container.className = "flex flex-col";

            let el;
            if (item.href) {
                el = document.createElement('a');
                el.href = item.href;
            } else {
                el = document.createElement('button');
                el.type = 'button';
            }

            el.className = 'w-full flex items-center justify-between px-4 py-4 hover:bg-cloud transition-colors group';

            const badgeHtml = (item.badge && item.badge > 0)
                    ? `<span class="ml-2 px-2 py-0.5 text-[10px] font-bold bg-dusty text-whitePure rounded-full shadow-sm group-hover:bg-espresso transition-colors">
                    ${item.badge}
                   </span>`
                    : '';

            el.innerHTML = `
                <div class="flex items-center">
                    <span class="text-sm font-semibold text-espresso/90 group-hover:text-dusty">${item.label}</span>
                    ${badgeHtml}
                </div>
                <svg class="w-4 h-4 text-dusty/40 group-hover:text-dusty transition-all transform group-hover:translate-x-1" 
                     fill="none" stroke="currentColor" stroke-width="3" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"></path>
                </svg>
            `;

            container.appendChild(el);
            const hr = document.createElement('div');
            hr.className = 'border-t border-espresso/10 w-full';
            container.appendChild(hr);

            menuContainer.appendChild(container);
        });
    }

    function openSidebar() {
        sidebar.classList.remove('-translate-x-full');
        overlay.classList.remove('hidden');
    }

    function closeSidebar() {
        sidebar.classList.add('-translate-x-full');
        overlay.classList.add('hidden');
    }

    const sidebarBtn = document.getElementById('sidebarBtn');
    if (sidebarBtn)
        sidebarBtn.addEventListener('click', openSidebar);
    if (closeBtn)
        closeBtn.addEventListener('click', closeSidebar);
    overlay.addEventListener('click', closeSidebar);

    document.querySelectorAll('input[name="sidebar_role"]').forEach(radio => {
        radio.addEventListener('change', (e) => renderMenu(e.target.value));
    });

    const initial = document.querySelector('input[name="sidebar_role"]:checked');
    renderMenu(initial ? initial.value : 'admin');
}

document.addEventListener('DOMContentLoaded', initSidebar);