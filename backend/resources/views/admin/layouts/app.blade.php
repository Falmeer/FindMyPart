<!DOCTYPE html>
<html lang="en" class="h-full bg-gray-50">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard') — FindMyPart Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: { DEFAULT: '#2563EB', light: '#DBEAFE', dark: '#1D4ED8' },
                    }
                }
            }
        }
    </script>
    <style>
        [x-cloak] { display: none !important; }
    </style>
</head>
<body class="h-full" x-data="{ sidebarOpen: false }">

{{-- Mobile overlay --}}
<div x-show="sidebarOpen" x-cloak @click="sidebarOpen = false"
     class="fixed inset-0 z-20 bg-black/50 lg:hidden"></div>

<div class="flex h-full">

    {{-- ── Sidebar ──────────────────────────────────────────── --}}
    <aside :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full'"
           class="fixed inset-y-0 left-0 z-30 w-64 bg-slate-900 flex flex-col transition-transform duration-300 lg:translate-x-0 lg:static lg:flex">

        {{-- Logo --}}
        <div class="flex items-center gap-3 px-6 py-5 border-b border-slate-700">
            <div class="w-9 h-9 bg-blue-600 rounded-xl flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
            </div>
            <div>
                <p class="text-white font-bold text-sm leading-tight">FindMyPart</p>
                <p class="text-slate-400 text-xs">Admin Panel</p>
            </div>
        </div>

        {{-- Nav --}}
        <nav class="flex-1 overflow-y-auto px-3 py-4 space-y-1">
            <p class="text-slate-500 text-xs font-semibold uppercase tracking-wider px-4 mb-2">Overview</p>

            <a href="{{ route('admin.dashboard') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.dashboard') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
                </svg>
                Dashboard
            </a>

            <p class="text-slate-500 text-xs font-semibold uppercase tracking-wider px-4 mt-4 mb-2">Management</p>

            <a href="{{ route('admin.users.index') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.users.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                Users
            </a>

            <a href="{{ route('admin.garages.index') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.garages.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                </svg>
                Garages
            </a>

            <a href="{{ route('admin.scrapyards.index') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.scrapyards.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/>
                </svg>
                Scrapyards
            </a>

            <a href="{{ route('admin.posts.index') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.posts.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                </svg>
                Posts
            </a>

            <p class="text-slate-500 text-xs font-semibold uppercase tracking-wider px-4 mt-4 mb-2">Moderation</p>

            <a href="{{ route('admin.reports.index') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.reports.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
                Reports
                @php $pendingReports = \App\Models\Report::where('status','pending')->count() @endphp
                @if($pendingReports > 0)
                    <span class="ml-auto bg-red-500 text-white text-xs font-bold px-1.5 py-0.5 rounded-full">{{ $pendingReports }}</span>
                @endif
            </a>

            <a href="{{ route('admin.users.banned') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.users.banned') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
                </svg>
                Banned Accounts
            </a>

            <p class="text-slate-500 text-xs font-semibold uppercase tracking-wider px-4 mt-4 mb-2">System</p>

            <a href="{{ route('admin.logs.index') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.logs.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                </svg>
                Activity Logs
            </a>

            <a href="{{ route('admin.profile.edit') }}"
               class="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-white transition-all {{ request()->routeIs('admin.profile.*') ? 'bg-blue-600' : 'hover:bg-slate-700' }}">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
                My Profile
            </a>
        </nav>

        {{-- Admin info + logout --}}
        <div class="border-t border-slate-700 p-4">
            <div class="flex items-center gap-3 mb-3">
                <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                    {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
                </div>
                <div class="min-w-0">
                    <p class="text-white text-sm font-medium truncate">{{ auth()->user()->name }}</p>
                    <p class="text-slate-400 text-xs truncate">{{ auth()->user()->email }}</p>
                </div>
            </div>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit"
                        class="w-full flex items-center gap-2 px-3 py-2 text-sm text-slate-400 hover:text-white hover:bg-slate-700 rounded-lg transition-all">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                    </svg>
                    Sign out
                </button>
            </form>
        </div>
    </aside>

    {{-- ── Main area ───────────────────────────────────────── --}}
    <div class="flex-1 flex flex-col min-w-0 overflow-hidden">

        {{-- Topbar --}}
        <header class="bg-white border-b border-gray-200 flex items-center justify-between px-4 lg:px-6 py-3 flex-shrink-0">
            <div class="flex items-center gap-3">
                <button @click="sidebarOpen = !sidebarOpen" class="lg:hidden p-2 rounded-lg hover:bg-gray-100">
                    <svg class="w-5 h-5 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
                <div>
                    <h1 class="text-lg font-semibold text-gray-900">@yield('title', 'Dashboard')</h1>
                    @hasSection('breadcrumb')
                        <p class="text-xs text-gray-500 mt-0.5">@yield('breadcrumb')</p>
                    @endif
                </div>
            </div>
            <div class="flex items-center gap-3">
                <span class="hidden sm:inline-flex items-center gap-1.5 text-xs text-gray-500">
                    <span class="w-2 h-2 bg-green-500 rounded-full inline-block"></span>
                    Online
                </span>
            </div>
        </header>

        {{-- Flash messages --}}
        <div class="px-4 lg:px-6 pt-4 space-y-2">
            @if(session('success'))
                <div x-data="{ show: true }" x-show="show" x-init="setTimeout(() => show = false, 4000)"
                     class="flex items-center gap-3 bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-lg text-sm">
                    <svg class="w-5 h-5 flex-shrink-0 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    </svg>
                    {{ session('success') }}
                    <button @click="show = false" class="ml-auto text-green-600 hover:text-green-800">✕</button>
                </div>
            @endif
            @if(session('error'))
                <div x-data="{ show: true }" x-show="show" x-init="setTimeout(() => show = false, 5000)"
                     class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg text-sm">
                    <svg class="w-5 h-5 flex-shrink-0 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                    {{ session('error') }}
                    <button @click="show = false" class="ml-auto text-red-600 hover:text-red-800">✕</button>
                </div>
            @endif
        </div>

        {{-- Page content --}}
        <main class="flex-1 overflow-y-auto px-4 lg:px-6 py-4">
            @yield('content')
        </main>
    </div>
</div>

@stack('scripts')
</body>
</html>
