@extends('admin.layouts.app')
@section('title', 'Report #' . $report->id)
@section('breadcrumb', 'Reports / #' . $report->id)

@section('content')
<div class="max-w-2xl space-y-6">

    {{-- Details --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex items-start justify-between gap-4 mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Report #{{ $report->id }}</h2>
            @php $statusClasses = ['pending'=>'bg-yellow-100 text-yellow-700','reviewed'=>'bg-blue-100 text-blue-700','resolved'=>'bg-green-100 text-green-700','dismissed'=>'bg-gray-100 text-gray-600']; @endphp
            <span class="px-3 py-1 text-xs rounded-full font-medium {{ $statusClasses[$report->status] ?? '' }}">
                {{ ucfirst($report->status) }}
            </span>
        </div>

        <dl class="space-y-3 text-sm">
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Reason</dt>
                <dd class="text-gray-900 font-medium">{{ $report->reason }}</dd>
            </div>
            @if($report->description)
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Description</dt>
                <dd class="text-gray-700">{{ $report->description }}</dd>
            </div>
            @endif
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Reporter</dt>
                <dd>
                    @if($report->reporter)
                    <a href="{{ route('admin.users.show', $report->reporter) }}" class="text-blue-600 hover:underline">
                        {{ $report->reporter->name }}
                    </a>
                    @else
                        <span class="text-gray-400">Deleted user</span>
                    @endif
                </dd>
            </div>
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Target type</dt>
                <dd class="text-gray-700">{{ class_basename($report->reportable_type ?? 'Unknown') }}</dd>
            </div>
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Reported on</dt>
                <dd class="text-gray-700">{{ $report->created_at->format('d M Y H:i') }}</dd>
            </div>
            @if($report->reviewer)
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Reviewed by</dt>
                <dd class="text-gray-700">{{ $report->reviewer->name }}</dd>
            </div>
            @endif
            @if($report->admin_notes)
            <div class="flex gap-4">
                <dt class="w-32 flex-shrink-0 text-gray-500">Admin notes</dt>
                <dd class="text-gray-700">{{ $report->admin_notes }}</dd>
            </div>
            @endif
        </dl>
    </div>

    {{-- Actions --}}
    @if(in_array($report->status, ['pending', 'reviewed']))
    <div class="bg-white rounded-xl border border-gray-200 p-6 space-y-5">
        <h3 class="font-semibold text-gray-900">Take Action</h3>

        <form method="POST" action="{{ route('admin.reports.resolve', $report) }}" class="space-y-3">
            @csrf
            <textarea name="admin_notes" rows="2" placeholder="Optional notes…"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
            <button type="submit" class="px-5 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700">
                Mark as Resolved
            </button>
        </form>

        <form method="POST" action="{{ route('admin.reports.dismiss', $report) }}" class="space-y-3">
            @csrf
            <textarea name="admin_notes" rows="2" placeholder="Optional notes…"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
            <button type="submit" class="px-5 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">
                Dismiss Report
            </button>
        </form>
    </div>
    @endif

    <a href="{{ route('admin.reports.index') }}" class="inline-block text-sm text-gray-500 hover:text-gray-700">← Back to reports</a>
</div>
@endsection
