@extends('admin.layouts.app')
@section('title', 'Activity Logs')

@section('content')
<div class="space-y-4">

    <div class="bg-white rounded-xl border border-gray-200 p-4">
        <form method="GET" action="{{ route('admin.logs.index') }}" class="flex flex-wrap gap-3">
            <input type="text" name="action" value="{{ request('action') }}" placeholder="Filter by action…"
                   class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <input type="date" name="date_from" value="{{ request('date_from') }}"
                   class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <input type="date" name="date_to" value="{{ request('date_to') }}"
                   class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Filter</button>
            <a href="{{ route('admin.logs.index') }}" class="px-4 py-2 border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50">Reset</a>
        </form>
    </div>

    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">{{ $logs->total() }} log entries</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        <th class="px-5 py-3">Action</th>
                        <th class="px-5 py-3">Description</th>
                        <th class="px-5 py-3">Admin</th>
                        <th class="px-5 py-3">IP</th>
                        <th class="px-5 py-3">Time</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($logs as $log)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3">
                            <code class="text-xs bg-gray-100 px-2 py-0.5 rounded text-gray-700">{{ $log->action }}</code>
                        </td>
                        <td class="px-5 py-3 text-gray-700 max-w-md">{{ $log->description }}</td>
                        <td class="px-5 py-3 text-gray-600 text-xs">{{ $log->admin->name ?? '—' }}</td>
                        <td class="px-5 py-3 text-gray-400 text-xs font-mono">{{ $log->ip_address ?? '—' }}</td>
                        <td class="px-5 py-3 text-gray-400 text-xs" title="{{ $log->created_at->format('d M Y H:i:s') }}">
                            {{ $log->created_at->diffForHumans() }}
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="5" class="px-5 py-10 text-center text-gray-400">No activity yet.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($logs->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $logs->links() }}</div>
        @endif
    </div>
</div>
@endsection
