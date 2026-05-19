@extends('admin.layouts.app')
@section('title', 'Manage Scrapyards')

@section('content')
<div class="space-y-4">
    <div class="flex items-center justify-between">
        <div></div>
        <a href="{{ route('admin.scrapyards.create') }}"
           class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 flex items-center gap-2">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Add Scrapyard
        </a>
    </div>

    <div class="bg-white rounded-xl border border-gray-200 p-4">
        <form method="GET" action="{{ route('admin.scrapyards.index') }}" class="flex flex-wrap gap-3">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search name, address…"
                   class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <select name="status" class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="">All statuses</option>
                @foreach(['pending','approved','rejected','suspended'] as $s)
                <option value="{{ $s }}" {{ request('status') === $s ? 'selected' : '' }}>{{ ucfirst($s) }}</option>
                @endforeach
            </select>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Filter</button>
            <a href="{{ route('admin.scrapyards.index') }}" class="px-4 py-2 border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50">Reset</a>
        </form>
    </div>

    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">{{ $scrapyards->total() }} scrapyard{{ $scrapyards->total() !== 1 ? 's' : '' }}</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        <th class="px-5 py-3">Scrapyard</th>
                        <th class="px-5 py-3">Owner</th>
                        <th class="px-5 py-3">Phone</th>
                        <th class="px-5 py-3">Rating</th>
                        <th class="px-5 py-3">Status</th>
                        <th class="px-5 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($scrapyards as $yard)
                    @php $statusClasses = ['approved'=>'bg-green-100 text-green-700','pending'=>'bg-yellow-100 text-yellow-700','rejected'=>'bg-red-100 text-red-700','suspended'=>'bg-orange-100 text-orange-700']; @endphp
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3">
                            <p class="font-medium text-gray-900">{{ $yard->name }}</p>
                            <p class="text-xs text-gray-400 truncate max-w-xs">{{ $yard->address ?? '—' }}</p>
                        </td>
                        <td class="px-5 py-3 text-gray-600 text-xs">{{ $yard->user->name ?? '—' }}</td>
                        <td class="px-5 py-3 text-gray-600">{{ $yard->phone ?? '—' }}</td>
                        <td class="px-5 py-3 text-yellow-600 font-medium">★ {{ number_format($yard->rating, 1) }}</td>
                        <td class="px-5 py-3">
                            <span class="px-2 py-0.5 text-xs rounded-full font-medium {{ $statusClasses[$yard->status ?? 'approved'] ?? 'bg-gray-100 text-gray-600' }}">
                                {{ ucfirst($yard->status ?? 'approved') }}
                            </span>
                        </td>
                        <td class="px-5 py-3 text-right">
                            <div class="flex items-center justify-end gap-2">
                                <a href="{{ route('admin.scrapyards.show', $yard) }}" class="px-3 py-1.5 text-xs border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700">View</a>
                                <a href="{{ route('admin.scrapyards.edit', $yard) }}" class="px-3 py-1.5 text-xs bg-blue-600 text-white rounded-lg hover:bg-blue-700">Edit</a>
                                <form method="POST" action="{{ route('admin.scrapyards.destroy', $yard) }}" onsubmit="return confirm('Delete this scrapyard?')">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="px-3 py-1.5 text-xs bg-red-600 text-white rounded-lg hover:bg-red-700">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="px-5 py-10 text-center text-gray-400">No scrapyards found.</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($scrapyards->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $scrapyards->links() }}</div>
        @endif
    </div>
</div>
@endsection
