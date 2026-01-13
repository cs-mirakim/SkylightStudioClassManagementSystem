<%-- header.jsp --%>
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

        <a href="inboxMessages_instructor.jsp" 
           class="relative p-2 rounded-xl hover:bg-petal/50 transition-all text-espresso/60 hover:text-dusty"
           aria-label="Inbox">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"></path>
            </svg>
            <span class="absolute top-2 right-2 bg-dusty text-whitePure text-[8px] font-bold rounded-full h-3.5 w-3.5 flex items-center justify-center ring-2 ring-whitePure">
                3
            </span>
        </a>

        <a href="profile.jsp"
           class="flex items-center gap-3 pl-3 pr-1 py-1 rounded-xl border border-petal hover:border-dusty/30 hover:bg-cloud transition-all group">
            <div class="flex flex-col items-end leading-tight hidden sm:flex text-right">
                <span class="text-[9px] font-bold text-espresso/40 uppercase tracking-tighter">Instructor</span>
                <span class="text-sm font-bold text-espresso group-hover:text-dusty transition-colors">Hi, Amir</span>
            </div>
            <div class="w-9 h-9 bg-blush text-dusty rounded-lg flex items-center justify-center text-sm font-black shadow-sm ring-1 ring-dusty/10 transition-colors group-hover:bg-dusty group-hover:text-whitePure">
                A
            </div>
        </a>
    </div>
</header>