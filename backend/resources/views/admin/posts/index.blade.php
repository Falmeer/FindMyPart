@extends('admin.layouts.app')
@section('title', 'Manage Posts')

@section('content')
<div class="space-y-4">

    {{-- Type tabs --}}
    <div class="flex gap-1 bg-gray-100 rounded-xl p-1 w-fit">
        <a href="{{ route('admin.posts.index', array_merge(request()->except('type','page'), ['type'=>'spare_parts'])) }}"
           class="px-5 py-2 text-sm font-medium rounded-lg transition-all {{ $type === 'spare_parts' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700' }}">
            Spare Parts
        </a>
        <a href="{{ route('admin.posts.index', array_merge(request()->except('type','page'), ['type'=>'vehicles'])) }}"
           class="px-5 py-2 text-sm font-medium rounded-lg transition-all {{ $type === 'vehicles' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700' }}">
            Vehicles
        </a>
    </div>

    {{-- Filters --}}
    <div class="bg-white rounded-xl border border-gray-200 p-4">
        <form method="GET" action="{{ route('admin.posts.index') }}" class="flex flex-wrap gap-3">
            <input type="hidden" name="type" value="{{ $type }}">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search posts or users…"
                   class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <input type="date" name="date_from" value="{{ request('date_from') }}"
                   class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <input type="date" name="date_to" value="{{ request('date_to') }}"
                   class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Filter</button>
            <a href="{{ route('admin.posts.index', ['type' => $type]) }}" class="px-4 py-2 border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50">Reset</a>
        </form>
    </div>

    {{-- Table --}}
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">{{ $posts->total() }} post{{ $posts->total() !== 1 ? 's' : '' }}</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        @if($type === 'spare_parts')
                            <th class="px-5 py-3">Part Name</th>
                            <th class="px-5 py-3">Category</th>
                            <th class="px-5 py-3">Price</th>
                        @else
                            <th class="px-5 py-3">Vehicle</th>
                            <th class="px-5 py-3">Year</th>
                            <th class="px-5 py-3">Price</th>
                        @endif
                        <th class="px-5 py-3">Seller</th>
                        <th class="px-5 py-3">Visibility</th>
                        <th class="px-5 py-3">Posted</th>
                        <th class="px-5 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($posts as $post)
                    <tr class="hover:bg-gray-50">
                        @if($type === 'spare_parts')
                            <td class="px-5 py-3">
                                <div class="flex items-center gap-3">
                                    @if($post->images->isNotEmpty())
                                    <img src="{{ $post->images->first()->url }}" alt="" class="w-8 h-8 rounded object-cover flex-shrink-0">
                                    @endif
                                    <p class="font-medium text-gray-900">{{ $post->name }}</p>
                                </div>
                            </td>
                            <td class="px-5 py-3 text-gray-600">{{ $post->category->name ?? '—' }}</td>
                            <td class="px-5 py-3 text-gray-600">SAR {{ number_format($post->price, 2) }}</td>
                        @else
                            <td class="px-5 py-3">
                                <div class="flex items-center gap-3">
                                    @if($post->images->isNotEmpty())
                                    <img src="{{ $post->images->first()->url }}" alt="" class="w-8 h-8 rounded object-cover flex-shrink-0">
                                    @endif
                                    <p class="font-medium text-gray-900">{{ $post->brand }} {{ $post->model }}</p>
                                </div>
                            </td>
                            <td class="px-5 py-3 text-gray-600">{{ $post->year }}</td>
                            <td class="px-5 py-3 text-gray-600">SAR {{ number_format($post->price, 2) }}</td>
                        @endif
                        <td class="px-5 py-3 text-gray-600 text-xs">{{ $post->user->name ?? '—' }}</td>
                        <td class="px-5 py-3">
                            @if($post->is_active)
                                <span class="px-2 py-0.5 text-xs bg-green-100 text-green-700 rounded-full font-medium">Visible</span>
                            @else
                                <span class="px-2 py-0.5 text-xs bg-gray-100 text-gray-600 rounded-full font-medium">Hidden</span>
                            @endif
                        </td>
                        <td class="px-5 py-3 text-gray-400 text-xs">{{ $post->created_at->format('d M Y') }}</td>
                        <td class="px-5 py-3 text-right">
                            <div class="flex items-center justify-end gap-2">
                                @if($type === 'spare_parts')
                                    <form method="POST" action="{{ route('admin.posts.spare-parts.toggle', $post) }}">
                                        @csrf
                                        <button type="submit" class="px-3 py-1.5 text-xs border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700">
                                            {{ $post->is_active ? 'Hide' : 'Show' }}
                                        </button>
                                    </form>
                                    <form method="POST" action="{{ route('admin.posts.spare-parts.destroy', $post) }}" onsubmit="return confirm('Delete this post?')">
                                        @csrf @method('DELETE')
                                        <button type="submit" class="px-3 py-1.5 text-xs bg-red-600 text-white rounded-lg hover:bg-red-700">Delete</button>
                                    </form>
                                @else
                                    <form method="POST" action="{{ route('admin.posts.vehicles.toggle', $post) }}">
                                        @csrf
                                        <button type="submit" class="px-3 py-1.5 text-xs border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700">
                                            {{ $post->is_active ? 'Hide' : 'Show' }}
                                        </button>
                                    </form>
                                    <form method="POST" action="{{ route('admin.posts.vehicles.destroy', $post) }}" onsubmit="return confirm('Delete this listing?')">
                                        @csrf @method('DELETE')
                                        <button type="submit" class="px-3 py-1.5 text-xs bg-red-600 text-white rounded-lg hover:bg-red-700">Delete</button>
                                    </form>
                                @endif
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="px-5 py-10 text-center text-gray-400">No posts found.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($posts->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $posts->links() }}</div>
        @endif
    </div>
</div>
@endsection
