@extends('admin.layouts.app')
@section('title', 'Manage Users')

@section('content')
<div class="space-y-4" x-data="{ banModal: false, banUserId: null, banUserName: '' }">

    {{-- Filters --}}
    <div class="bg-white rounded-xl border border-gray-200 p-4">
        <form method="GET" action="{{ route('admin.users.index') }}" class="flex flex-wrap gap-3">
            <input type="text" name="search" value="{{ request('search') }}"
                   placeholder="Search name, email, phone…"
                   class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            <select name="role" class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="">All roles</option>
                <option value="customer"   {{ request('role') === 'customer'   ? 'selected' : '' }}>Customer</option>
                <option value="garage"     {{ request('role') === 'garage'     ? 'selected' : '' }}>Garage</option>
                <option value="yard_owner" {{ request('role') === 'yard_owner' ? 'selected' : '' }}>Yard Owner</option>
            </select>
            <select name="status" class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="">All statuses</option>
                <option value="active"   {{ request('status') === 'active'   ? 'selected' : '' }}>Active</option>
                <option value="banned"   {{ request('status') === 'banned'   ? 'selected' : '' }}>Banned</option>
                <option value="inactive" {{ request('status') === 'inactive' ? 'selected' : '' }}>Inactive</option>
            </select>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Filter</button>
            <a href="{{ route('admin.users.index') }}" class="px-4 py-2 border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50">Reset</a>
        </form>
    </div>

    {{-- Table --}}
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">
                {{ $users->total() }} user{{ $users->total() !== 1 ? 's' : '' }}
            </h3>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                        <th class="px-5 py-3">User</th>
                        <th class="px-5 py-3">Phone</th>
                        <th class="px-5 py-3">Role</th>
                        <th class="px-5 py-3">Status</th>
                        <th class="px-5 py-3">Joined</th>
                        <th class="px-5 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    @forelse($users as $user)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3">
                            <div class="flex items-center gap-3">
                                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 font-bold text-xs flex-shrink-0">
                                    {{ strtoupper(substr($user->name, 0, 1)) }}
                                </div>
                                <div>
                                    <p class="font-medium text-gray-900">{{ $user->name }}</p>
                                    <p class="text-xs text-gray-400">{{ $user->email }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="px-5 py-3 text-gray-600">{{ $user->phone ?? '—' }}</td>
                        <td class="px-5 py-3">
                            <span class="px-2 py-0.5 text-xs rounded-full font-medium
                                {{ $user->role === 'garage' ? 'bg-indigo-100 text-indigo-700' :
                                   ($user->role === 'yard_owner' ? 'bg-violet-100 text-violet-700' :
                                   'bg-gray-100 text-gray-600') }}">
                                {{ ucfirst(str_replace('_', ' ', $user->role)) }}
                            </span>
                        </td>
                        <td class="px-5 py-3">
                            @if($user->is_banned)
                                <span class="px-2 py-0.5 text-xs bg-red-100 text-red-700 rounded-full font-medium">Banned</span>
                            @elseif(!$user->is_active)
                                <span class="px-2 py-0.5 text-xs bg-gray-100 text-gray-600 rounded-full font-medium">Inactive</span>
                            @else
                                <span class="px-2 py-0.5 text-xs bg-green-100 text-green-700 rounded-full font-medium">Active</span>
                            @endif
                        </td>
                        <td class="px-5 py-3 text-gray-500 text-xs">{{ $user->created_at->format('d M Y') }}</td>
                        <td class="px-5 py-3 text-right">
                            <div class="flex items-center justify-end gap-2">
                                <a href="{{ route('admin.users.show', $user) }}"
                                   class="px-3 py-1.5 text-xs border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700">View</a>

                                @if($user->is_banned)
                                    <form method="POST" action="{{ route('admin.users.unban', $user) }}">
                                        @csrf
                                        <button type="submit"
                                                class="px-3 py-1.5 text-xs bg-green-600 text-white rounded-lg hover:bg-green-700">Unban</button>
                                    </form>
                                @else
                                    <button @click="banModal=true; banUserId={{ $user->id }}; banUserName='{{ addslashes($user->name) }}'"
                                            class="px-3 py-1.5 text-xs bg-orange-500 text-white rounded-lg hover:bg-orange-600">Ban</button>
                                @endif

                                <form method="POST" action="{{ route('admin.users.destroy', $user) }}"
                                      onsubmit="return confirm('Delete user {{ addslashes($user->name) }}? This cannot be undone.')">
                                    @csrf @method('DELETE')
                                    <button type="submit"
                                            class="px-3 py-1.5 text-xs bg-red-600 text-white rounded-lg hover:bg-red-700">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="px-5 py-10 text-center text-gray-400">No users found.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">
            {{ $users->links() }}
        </div>
        @endif
    </div>

    {{-- Ban modal --}}
    <div x-show="banModal" x-cloak
         class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
        <div @click.stop class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-1">Ban User</h3>
            <p class="text-sm text-gray-500 mb-4">Provide a reason for banning <strong x-text="banUserName"></strong>.</p>

            <form method="POST" :action="'/admin/users/' + banUserId + '/ban'">
                @csrf
                <textarea name="reason" rows="3" required
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="Enter ban reason…"></textarea>
                <div class="flex gap-3 mt-4">
                    <button type="button" @click="banModal=false"
                            class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">Cancel</button>
                    <button type="submit"
                            class="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">Confirm Ban</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
