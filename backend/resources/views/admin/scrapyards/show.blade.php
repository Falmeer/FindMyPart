@extends('admin.layouts.app')
@section('title', $scrapyard->name)
@section('breadcrumb', 'Scrapyards / ' . $scrapyard->name)

@section('content')
<div class="space-y-6" x-data="{ statusModal: false }">

    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex flex-wrap items-start gap-4">
            <div class="flex-1 min-w-0">
                <div class="flex flex-wrap items-center gap-3 mb-1">
                    <h2 class="text-xl font-bold text-gray-900">{{ $scrapyard->name }}</h2>
                    @php $sc = ['approved'=>'bg-green-100 text-green-700','pending'=>'bg-yellow-100 text-yellow-700','rejected'=>'bg-red-100 text-red-700','suspended'=>'bg-orange-100 text-orange-700']; @endphp
                    <span class="px-2 py-0.5 text-xs rounded-full font-medium {{ $sc[$scrapyard->status ?? 'approved'] ?? '' }}">
                        {{ ucfirst($scrapyard->status ?? 'approved') }}
                    </span>
                    @if($scrapyard->is_verified)
                        <span class="px-2 py-0.5 text-xs bg-blue-100 text-blue-700 rounded-full font-medium">✓ Verified</span>
                    @endif
                </div>
                <p class="text-sm text-gray-500">{{ $scrapyard->address ?? 'No address' }}</p>
                @if($scrapyard->phone) <p class="text-sm text-gray-500">{{ $scrapyard->phone }}</p> @endif
                <p class="text-sm text-gray-500 mt-1">Owner: <strong>{{ $scrapyard->user->name ?? '—' }}</strong> ({{ $scrapyard->user->email ?? '—' }})</p>
            </div>
            <div class="flex gap-2 flex-wrap">
                <a href="{{ route('admin.scrapyards.index') }}" class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">← Back</a>
                <a href="{{ route('admin.scrapyards.edit', $scrapyard) }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Edit</a>
                <button @click="statusModal = true" class="px-4 py-2 bg-yellow-500 text-white rounded-lg text-sm font-medium hover:bg-yellow-600">Update Status</button>
                <form method="POST" action="{{ route('admin.scrapyards.destroy', $scrapyard) }}" onsubmit="return confirm('Delete this scrapyard?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">Delete</button>
                </form>
            </div>
        </div>
        @if($scrapyard->admin_notes)
        <div class="mt-4 bg-yellow-50 border border-yellow-200 rounded-lg px-4 py-3 text-sm text-yellow-800">
            <strong>Admin notes:</strong> {{ $scrapyard->admin_notes }}
        </div>
        @endif
        @if($scrapyard->description) <p class="mt-4 text-sm text-gray-600">{{ $scrapyard->description }}</p> @endif
    </div>

    <div class="grid grid-cols-2 gap-4">
        <div class="bg-white rounded-xl border border-gray-200 p-5 text-center">
            <p class="text-3xl font-bold text-yellow-500">★ {{ number_format($scrapyard->rating, 1) }}</p>
            <p class="text-xs text-gray-500 mt-1">Average Rating</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-5 text-center">
            <p class="text-3xl font-bold text-gray-900">{{ $scrapyard->review_count }}</p>
            <p class="text-xs text-gray-500 mt-1">Total Reviews</p>
        </div>
    </div>

    @if($scrapyard->reviews->isNotEmpty())
    <div class="bg-white rounded-xl border border-gray-200">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">Reviews ({{ $scrapyard->reviews->count() }})</h3>
        </div>
        <div class="divide-y divide-gray-50">
            @foreach($scrapyard->reviews->take(10) as $review)
            <div class="px-5 py-4">
                <div class="flex items-start gap-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 text-xs font-bold flex-shrink-0">
                        {{ strtoupper(substr($review->user->name ?? '?', 0, 1)) }}
                    </div>
                    <div>
                        <div class="flex items-center gap-2">
                            <p class="text-sm font-medium text-gray-900">{{ $review->user->name ?? 'Deleted' }}</p>
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

    <div x-show="statusModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
        <div @click.stop class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Update Status</h3>
            <form method="POST" action="{{ route('admin.scrapyards.status', $scrapyard) }}">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Status</label>
                        <select name="status" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                            @foreach(['pending','approved','rejected','suspended'] as $s)
                            <option value="{{ $s }}" {{ ($scrapyard->status ?? 'approved') === $s ? 'selected' : '' }}>{{ ucfirst($s) }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Admin Notes</label>
                        <textarea name="admin_notes" rows="3"
                                  class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">{{ $scrapyard->admin_notes }}</textarea>
                    </div>
                </div>
                <div class="flex gap-3 mt-4">
                    <button type="button" @click="statusModal=false" class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm">Cancel</button>
                    <button type="submit" class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
