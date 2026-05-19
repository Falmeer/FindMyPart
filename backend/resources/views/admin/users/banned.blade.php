@extends('admin.layouts.app')
@section('title', 'Banned Accounts')

@section('content')
<div class="space-y-4">
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">{{ $users->total() }} banned account{{ $users->total() !== 1 ? 's' : '' }}</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        <th class="px-5 py-3">User</th>
                        <th class="px-5 py-3">Role</th>
                        <th class="px-5 py-3">Ban Reason</th>
                        <th class="px-5 py-3">Banned On</th>
                        <th class="px-5 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($users as $user)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3">
                            <div class="flex items-center gap-3">
                                <div class="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center text-red-700 font-bold text-xs flex-shrink-0">
                                    {{ strtoupper(substr($user->name, 0, 1)) }}
                                </div>
                                <div>
                                    <p class="font-medium text-gray-900">{{ $user->name }}</p>
                                    <p class="text-xs text-gray-400">{{ $user->email }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="px-5 py-3">
                            <span class="px-2 py-0.5 text-xs bg-gray-100 text-gray-600 rounded-full font-medium">
                                {{ ucfirst(str_replace('_', ' ', $user->role)) }}
                            </span>
                        </td>
                        <td class="px-5 py-3 text-gray-600 max-w-xs truncate">{{ $user->banned_reason ?? '—' }}</td>
                        <td class="px-5 py-3 text-gray-400 text-xs">{{ $user->banned_at ? $user->banned_at->format('d M Y') : '—' }}</td>
                        <td class="px-5 py-3 text-right">
                            <div class="flex items-center justify-end gap-2">
                                <a href="{{ route('admin.users.show', $user) }}"
                                   class="px-3 py-1.5 text-xs border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700">View</a>
                                <form method="POST" action="{{ route('admin.users.unban', $user) }}">
                                    @csrf
                                    <button type="submit" class="px-3 py-1.5 text-xs bg-green-600 text-white rounded-lg hover:bg-green-700">Unban</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="5" class="px-5 py-10 text-center text-gray-400">No banned accounts.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($users->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $users->links() }}</div>
        @endif
    </div>
</div>
@endsection
