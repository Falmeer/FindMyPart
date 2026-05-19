@extends('admin.layouts.app')
@section('title', $garage->name)
@section('breadcrumb', 'Garages / ' . $garage->name)

@section('content')
<div class="space-y-6" x-data="{ statusModal: false }">

    {{-- Header --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex flex-wrap items-start gap-4">
            <div class="flex-1 min-w-0">
                <div class="flex flex-wrap items-center gap-3 mb-1">
                    <h2 class="text-xl font-bold text-gray-900">{{ $garage->name }}</h2>
                    @php
                    $statusClasses = [
                        'approved'  => 'bg-green-100 text-green-700',
                        'pending'   => 'bg-yellow-100 text-yellow-700',
                        'rejected'  => 'bg-red-100 text-red-700',
                        'suspended' => 'bg-orange-100 text-orange-700',
                    ];
                    @endphp
                    <span class="px-2 py-0.5 text-xs rounded-full font-medium {{ $statusClasses[$garage->status ?? 'approved'] ?? '' }}">
                        {{ ucfirst($garage->status ?? 'approved') }}
                    </span>
                    @if($garage->is_verified)
                        <span class="px-2 py-0.5 text-xs bg-blue-100 text-blue-700 rounded-full font-medium">✓ Verified</span>
                    @endif
                </div>
                <p class="text-sm text-gray-500">{{ $garage->address ?? 'No address' }}</p>
                @if($garage->phone)
                    <p class="text-sm text-gray-500">{{ $garage->phone }}</p>
                @endif
                @if($garage->working_hours)
                    <p class="text-sm text-gray-500">{{ $garage->working_hours }}</p>
                @endif
                <p class="text-sm text-gray-500 mt-1">Owner: <strong>{{ $garage->user->name ?? '—' }}</strong> ({{ $garage->user->email ?? '—' }})</p>
            </div>
            <div class="flex gap-2">
                <a href="{{ route('admin.garages.index') }}" class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">← Back</a>
                <a href="{{ route('admin.garages.edit', $garage) }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Edit</a>
                <button @click="statusModal = true" class="px-4 py-2 bg-yellow-500 text-white rounded-lg text-sm font-medium hover:bg-yellow-600">Update Status</button>
                <form method="POST" action="{{ route('admin.garages.destroy', $garage) }}" onsubmit="return confirm('Delete this garage?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">Delete</button>
                </form>
            </div>
        </div>

        @if($garage->admin_notes)
        <div class="mt-4 bg-yellow-50 border border-yellow-200 rounded-lg px-4 py-3 text-sm text-yellow-800">
            <strong>Admin notes:</strong> {{ $garage->admin_notes }}
        </div>
        @endif

        @if($garage->description)
        <p class="mt-4 text-sm text-gray-600">{{ $garage->description }}</p>
        @endif
    </div>

    {{-- Stats --}}
    <div class="grid grid-cols-3 gap-4">
        <div class="bg-white rounded-xl border border-gray-200 p-5 text-center">
            <p class="text-3xl font-bold text-yellow-500">★ {{ number_format($garage->rating, 1) }}</p>
            <p class="text-xs text-gray-500 mt-1">Average Rating</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-5 text-center">
            <p class="text-3xl font-bold text-gray-900">{{ $garage->review_count }}</p>
            <p class="text-xs text-gray-500 mt-1">Total Reviews</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-5 text-center">
            <p class="text-3xl font-bold text-gray-900">{{ $garage->offers->count() ?? 0 }}</p>
            <p class="text-xs text-gray-500 mt-1">Offers Made</p>
        </div>
    </div>

    {{-- Reviews --}}
    @if($garage->reviews->isNotEmpty())
    <div class="bg-white rounded-xl border border-gray-200">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">Reviews ({{ $garage->reviews->count() }})</h3>
        </div>
        <div class="divide-y divide-gray-50">
            @foreach($garage->reviews->take(10) as $review)
            <div class="px-5 py-4">
                <div class="flex items-start gap-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 text-xs font-bold flex-shrink-0">
                        {{ strtoupper(substr($review->user->name ?? '?', 0, 1)) }}
                    </div>
                    <div class="flex-1">
                        <div class="flex items-center gap-2">
                            <p class="text-sm font-medium text-gray-900">{{ $review->user->name ?? 'Deleted User' }}</p>
                            <span class="text-yellow-500 text-xs">★ {{ $review->rating }}</span>
                        </div>
                        <p class="text-sm text-gray-600 mt-0.5">{{ $review->comment ?? '' }}</p>
                        <p class="text-xs text-gray-400 mt-1">{{ $review->created_at->format('d M Y') }}</p>
                    </div>
                </div>
            </div>
            @endforeach
        </div>
    </div>
    @endif

    {{-- Status modal --}}
    <div x-show="statusModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
        <div @click.stop class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Update Garage Status</h3>
            <form method="POST" action="{{ route('admin.garages.status', $garage) }}">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Status</label>
                        <select name="status" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="pending"   {{ ($garage->status ?? '') === 'pending'   ? 'selected' : '' }}>Pending</option>
                            <option value="approved"  {{ ($garage->status ?? 'approved') === 'approved'  ? 'selected' : '' }}>Approved</option>
                            <option value="rejected"  {{ ($garage->status ?? '') === 'rejected'  ? 'selected' : '' }}>Rejected</option>
                            <option value="suspended" {{ ($garage->status ?? '') === 'suspended' ? 'selected' : '' }}>Suspended</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Admin Notes</label>
                        <textarea name="admin_notes" rows="3"
                                  class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                  placeholder="Optional notes…">{{ $garage->admin_notes }}</textarea>
                    </div>
                </div>
                <div class="flex gap-3 mt-4">
                    <button type="button" @click="statusModal=false"
                            class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm">Cancel</button>
                    <button type="submit"
                            class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
