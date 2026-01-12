<%-- sidebar.jsp --%>
<div id="sidebar-overlay" class="fixed inset-0 bg-espresso/40 backdrop-blur-sm hidden z-40" aria-hidden="true"></div>

<aside id="sidebar"
       class="fixed left-0 top-0 h-full w-64 bg-whitePure text-espresso transform -translate-x-full transition-transform duration-300 z-50 shadow-2xl flex flex-col border-r border-petal"
       aria-hidden="true" aria-label="Sidebar">

    <div class="p-6 border-b border-petal flex-shrink-0">
        <div class="flex items-center justify-between mb-6">
            <div class="text-xl font-bold tracking-tight text-dusty">Skylight Studio</div>
            <button id="sidebarClose" class="p-2 rounded-full hover:bg-petal transition-colors text-espresso/40 hover:text-espresso">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>

        <fieldset class="bg-cloud p-3 rounded-xl border border-petal">
            <legend class="px-2 text-[10px] font-bold uppercase tracking-widest text-espresso/40">User Type</legend>
            <div class="flex gap-4 mt-1 px-1">
                <label class="inline-flex items-center gap-2 cursor-pointer text-xs font-bold text-espresso/70">
                    <input type="radio" name="sidebar_role" value="admin" checked class="w-4 h-4 accent-dusty"/>
                    <span>ADMIN</span>
                </label>
                <label class="inline-flex items-center gap-2 cursor-pointer text-xs font-bold text-espresso/70">
                    <input type="radio" name="sidebar_role" value="instructor" class="w-4 h-4 accent-dusty"/>
                    <span>INSTRUCTOR</span>
                </label>
            </div>
        </fieldset>
    </div>

    <nav id="sidebar-menu" class="flex-1 overflow-y-auto custom-scrollbar" aria-label="Sidebar navigation">
    </nav>

    <div class="p-4 border-t border-petal flex-shrink-0 bg-cloud/50">
        <a id="sidebar-logout"
           href="logout.jsp"
           class="w-full inline-flex items-center justify-center px-4 py-3 rounded-xl bg-dusty text-whitePure font-bold hover:bg-dustyHover transition-all shadow-lg shadow-dusty/20 active:scale-[0.98]"
           title="Logout">
            Logout
        </a>
    </div>
</aside>

<style>
    .custom-scrollbar::-webkit-scrollbar { width: 4px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #EFE1E1;
        border-radius: 10px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #B36D6D; }
</style>