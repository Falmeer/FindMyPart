@extends('admin.layouts.app')
@section('title', 'Reports & Complaints')

@section('content')
<div class="space-y-4">

    <div class="bg-white rounded-xl border border-gray-200 p-4">
        <form method="GET" action="{{ route('admin.reports.index') }}" class="flex flex-wrap gap-3">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search reason or reporter…"
                   class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <select name="status" class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="">All statuses</option>
                @foreach(['pending','reviewed','resolved','dismissed'] as $s)
                <option value="{{ $s }}" {{ request('status') === $s ? 'selected' : '' }}>{{ ucfirst($s) }}</option>
                @endforeach
            </select>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Filter</button>
            <a href="{{ route('admin.reports.index') }}" class="px-4 py-2 border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50">Reset</a>
        </form>
    </div>

    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">{{ $reports->total() }} report{{ $reports->total() !== 1 ? 's' : '' }}</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        <th class="px-5 py-3">Report</th>
                        <th class="px-5 py-3">Type</th>
                        <th class="px-5 py-3">Reporter</th>
                        <th class="px-5 py-3">Status</th>
                        <th class="px-5 py-3">Date</th>
                        <th class="px-5 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @php $statusClasses = ['pending'=>'bg-yellow-100 text-yellow-700','reviewed'=>'bg-blue-100 text-blue-700','resolved'=>'bg-green-100 text-green-700','dismissed'=>'bg-gray-100 text-gray-600']; @endphp
                    @forelse($reports as $report)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3">
                            <p class="font-medium text-gray-900">{{ Str::limit($report->reason, 50) }}</p>
                            @if($report->description)
                            <p class="text-xs text-gray-400 mt-0.5">{{ Str::limit($report->description, 60) }}</p>
                            @endif
                        </td>
                        <td class="px-5 py-3 text-gray-600 text-xs">{{ class_basename($report->reportable_type ?? '—') }}</td>
                        <td class="px-5 py-3 text-gray-600 text-xs">{{ $report->reporter->name ?? '—' }}</td>
                        <td class="px-5 py-3">
                            <span class="px-2 py-0.5 text-xs rounded-full font-medium {{ $statusClasses[$report->status] ?? 'bg-gray-100 text-gray-600' }}">
                                {{ ucfirst($report->status) }}
                            </span>
                        </td>
                        <td class="px-5 py-3 text-gray-400 text-xs">{{ $report->created_at->format('d M Y') }}</td>
                        <td class="px-5 py-3 text-right">
                            <a href="{{ route('admin.reports.show', $report) }}"
                               class="px-3 py-1.5 text-xs border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700">Review</a>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="px-5 py-10 text-center text-gray-400">No reports found.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($reports->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $reports->links() }}</div>
        @endif
    </div>
</div>
@endsection
