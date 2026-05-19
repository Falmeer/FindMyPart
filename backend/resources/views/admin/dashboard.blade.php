@extends('admin.layouts.app')
@section('title', 'Dashboard')

@section('content')
<div class="space-y-6">

    {{-- Stats grid --}}
    <div class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-5 gap-4">
        @php
        $cards = [
            ['label'=>'Total Users',      'value'=>$stats['total_users'],       'color'=>'blue',   'icon'=>'users'],
            ['label'=>'Garages',          'value'=>$stats['total_garages'],     'color'=>'indigo', 'icon'=>'garage'],
            ['label'=>'Scrapyards',       'value'=>$stats['total_scrapyards'],  'color'=>'violet', 'icon'=>'yard'],
            ['label'=>'Spare Parts',      'value'=>$stats['total_spare_parts'], 'color'=>'sky',    'icon'=>'parts'],
            ['label'=>'Vehicles Listed',  'value'=>$stats['total_vehicles'],    'color'=>'cyan',   'icon'=>'car'],
        ];
        $colorMap = [
            'blue'   => 'bg-blue-50 text-blue-600',
            'indigo' => 'bg-indigo-50 text-indigo-600',
            'violet' => 'bg-violet-50 text-violet-600',
            'sky'    => 'bg-sky-50 text-sky-600',
            'cyan'   => 'bg-cyan-50 text-cyan-600',
        ];
        @endphp

        @foreach($cards as $card)
        <div class="bg-white rounded-xl border border-gray-200 p-5 flex items-center gap-4">
            <div class="w-10 h-10 rounded-lg {{ $colorMap[$card['color']] }} flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
            </div>
            <div>
                <p class="text-2xl font-bold text-gray-900">{{ number_format($card['value']) }}</p>
                <p class="text-xs text-gray-500 mt-0.5">{{ $card['label'] }}</p>
            </div>
        </div>
        @endforeach
    </div>

    {{-- Alert cards --}}
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <a href="{{ route('admin.reports.index', ['status' => 'pending']) }}"
           class="bg-red-50 border border-red-200 rounded-xl p-4 flex items-center gap-4 hover:bg-red-100 transition-colors">
            <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
            </div>
            <div>
                <p class="text-2xl font-bold text-red-700">{{ $stats['pending_reports'] }}</p>
                <p class="text-xs text-red-600">Pending Reports</p>
            </div>
        </a>

        <a href="{{ route('admin.users.banned') }}"
           class="bg-orange-50 border border-orange-200 rounded-xl p-4 flex items-center gap-4 hover:bg-orange-100 transition-colors">
            <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-orange-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/>
                </svg>
            </div>
            <div>
                <p class="text-2xl font-bold text-orange-700">{{ $stats['banned_users'] }}</p>
                <p class="text-xs text-orange-600">Banned Accounts</p>
            </div>
        </a>

        <a href="{{ route('admin.garages.index', ['status' => 'pending']) }}"
           class="bg-yellow-50 border border-yellow-200 rounded-xl p-4 flex items-center gap-4 hover:bg-yellow-100 transition-colors">
            <div class="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
            </div>
            <div>
                <p class="text-2xl font-bold text-yellow-700">{{ $stats['pending_garages'] + $stats['pending_scrapyards'] }}</p>
                <p class="text-xs text-yellow-600">Pending Approvals</p>
            </div>
        </a>
    </div>

    {{-- Two column layout --}}
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {{-- Recent users --}}
        <div class="bg-white rounded-xl border border-gray-200">
            <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100">
                <h3 class="font-semibold text-gray-900 text-sm">Recent Users</h3>
                <a href="{{ route('admin.users.index') }}" class="text-xs text-blue-600 hover:underline">View all</a>
            </div>
            <div class="divide-y divide-gray-50">
                @forelse($recentUsers as $user)
                <div class="flex items-center gap-3 px-5 py-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 text-sm font-bold flex-shrink-0">
                        {{ strtoupper(substr($user->name, 0, 1)) }}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">{{ $user->name }}</p>
                        <p class="text-xs text-gray-400 truncate">{{ $user->email }}</p>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="text-xs px-2 py-0.5 rounded-full font-medium
                            {{ $user->role === 'garage' ? 'bg-indigo-100 text-indigo-700' :
                               ($user->role === 'yard_owner' ? 'bg-violet-100 text-violet-700' :
                               'bg-gray-100 text-gray-600') }}">
                            {{ ucfirst(str_replace('_',' ',$user->role)) }}
                        </span>
                        @if($user->is_banned)
                            <span class="text-xs px-2 py-0.5 bg-red-100 text-red-700 rounded-full font-medium">Banned</span>
                        @endif
                    </div>
                </div>
                @empty
                <div class="px-5 py-8 text-center text-gray-400 text-sm">No users yet.</div>
                @endforelse
            </div>
        </div>

        {{-- Recent activity logs --}}
        <div class="bg-white rounded-xl border border-gray-200">
            <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100">
                <h3 class="font-semibold text-gray-900 text-sm">Recent Activity</h3>
                <a href="{{ route('admin.logs.index') }}" class="text-xs text-blue-600 hover:underline">View all</a>
            </div>
            <div class="divide-y divide-gray-50">
                @forelse($recentLogs as $log)
                <div class="flex items-start gap-3 px-5 py-3">
                    <div class="w-1.5 h-1.5 bg-blue-400 rounded-full mt-2 flex-shrink-0"></div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm text-gray-700 truncate">{{ $log->description }}</p>
                        <p class="text-xs text-gray-400 mt-0.5">{{ $log->created_at->diffForHumans() }}</p>
                    </div>
                </div>
                @empty
                <div class="px-5 py-8 text-center text-gray-400 text-sm">No activity yet.</div>
                @endforelse
            </div>
        </div>
    </div>

    {{-- Pending reports --}}
    @if($recentReports->isNotEmpty())
    <div class="bg-white rounded-xl border border-gray-200">
        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">Pending Reports</h3>
            <a href="{{ route('admin.reports.index') }}" class="text-xs text-blue-600 hover:underline">View all</a>
        </div>
        <div class="divide-y divide-gray-50">
            @foreach($recentReports as $report)
            <div class="flex items-center gap-4 px-5 py-3">
                <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900">{{ $report->reason }}</p>
                    <p class="text-xs text-gray-400">by {{ $report->reporter->name ?? 'Unknown' }} &bull; {{ $report->created_at->diffForHumans() }}</p>
                </div>
                <a href="{{ route('admin.reports.show', $report) }}"
                   class="text-xs text-blue-600 hover:underline font-medium flex-shrink-0">Review</a>
            </div>
            @endforeach
        </div>
    </div>
    @endif

</div>
@endsection
