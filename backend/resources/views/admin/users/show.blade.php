@extends('admin.layouts.app')
@section('title', $user->name)
@section('breadcrumb', 'Users / ' . $user->name)

@section('content')
<div class="space-y-6" x-data="{ banModal: false }">

    {{-- Header card --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex flex-wrap items-start gap-4">
            <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 text-2xl font-bold flex-shrink-0">
                {{ strtoupper(substr($user->name, 0, 1)) }}
            </div>
            <div class="flex-1 min-w-0">
                <div class="flex flex-wrap items-center gap-3 mb-1">
                    <h2 class="text-xl font-bold text-gray-900">{{ $user->name }}</h2>
                    <span class="px-2 py-0.5 text-xs rounded-full font-medium
                        {{ $user->role === 'garage' ? 'bg-indigo-100 text-indigo-700' :
                           ($user->role === 'yard_owner' ? 'bg-violet-100 text-violet-700' : 'bg-gray-100 text-gray-600') }}">
                        {{ ucfirst(str_replace('_', ' ', $user->role)) }}
                    </span>
                    @if($user->is_banned)
                        <span class="px-2 py-0.5 text-xs bg-red-100 text-red-700 rounded-full font-medium">Banned</span>
                    @elseif(!$user->is_active)
                        <span class="px-2 py-0.5 text-xs bg-gray-100 text-gray-500 rounded-full font-medium">Inactive</span>
                    @else
                        <span class="px-2 py-0.5 text-xs bg-green-100 text-green-700 rounded-full font-medium">Active</span>
                    @endif
                </div>
                <p class="text-sm text-gray-500">{{ $user->email }}</p>
                @if($user->phone)
                    <p class="text-sm text-gray-500">{{ $user->phone }}</p>
                @endif
                <p class="text-xs text-gray-400 mt-1">Member since {{ $user->created_at->format('d F Y') }}</p>
            </div>
            <div class="flex gap-2 flex-wrap">
                <a href="{{ route('admin.users.index') }}"
                   class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">← Back</a>

                @if($user->is_banned)
                    <form method="POST" action="{{ route('admin.users.unban', $user) }}">
                        @csrf
                        <button type="submit" class="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700">
                            Unban User
                        </button>
                    </form>
                @else
                    <button @click="banModal = true"
                            class="px-4 py-2 bg-orange-500 text-white rounded-lg text-sm font-medium hover:bg-orange-600">
                        Ban User
                    </button>
                @endif

                <form method="POST" action="{{ route('admin.users.destroy', $user) }}"
                      onsubmit="return confirm('Permanently delete {{ addslashes($user->name) }}?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">
                        Delete
                    </button>
                </form>
            </div>
        </div>

        @if($user->is_banned && $user->banned_reason)
        <div class="mt-4 bg-red-50 border border-red-200 rounded-lg px-4 py-3 text-sm text-red-700">
            <strong>Ban reason:</strong> {{ $user->banned_reason }}
            @if($user->banned_at)
                &mdash; banned on {{ $user->banned_at->format('d M Y H:i') }}
            @endif
        </div>
        @endif
    </div>

    {{-- Stats --}}
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        @php
        $counts = [
            ['label' => 'Spare Parts',   'value' => $user->spareParts->count()],
            ['label' => 'Vehicles',      'value' => $user->salvagedVehicles->count()],
            ['label' => 'Garage',        'value' => $user->garage ? 1 : 0],
            ['label' => 'Scrapyard',     'value' => $user->scrapyard ? 1 : 0],
        ];
        @endphp
        @foreach($counts as $c)
        <div class="bg-white rounded-xl border border-gray-200 p-4 text-center">
            <p class="text-2xl font-bold text-gray-900">{{ $c['value'] }}</p>
            <p class="text-xs text-gray-500 mt-0.5">{{ $c['label'] }}</p>
        </div>
        @endforeach
    </div>

    {{-- Spare parts --}}
    @if($user->spareParts->isNotEmpty())
    <div class="bg-white rounded-xl border border-gray-200">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">Spare Parts ({{ $user->spareParts->count() }})</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead><tr class="bg-gray-50 text-xs font-semibold text-gray-500 uppercase tracking-wider text-left">
                    <th class="px-5 py-3">Name</th>
                    <th class="px-5 py-3">Price</th>
                    <th class="px-5 py-3">Condition</th>
                    <th class="px-5 py-3">Posted</th>
                    <th class="px-5 py-3 text-right">Action</th>
                </tr></thead>
                <tbody class="divide-y divide-gray-50">
                @foreach($user->spareParts as $part)
                <tr class="hover:bg-gray-50">
                    <td class="px-5 py-3 font-medium text-gray-900">{{ $part->name }}</td>
                    <td class="px-5 py-3 text-gray-600">SAR {{ number_format($part->price, 2) }}</td>
                    <td class="px-5 py-3 text-gray-600">{{ $part->condition }}</td>
                    <td class="px-5 py-3 text-gray-400 text-xs">{{ $part->created_at->format('d M Y') }}</td>
                    <td class="px-5 py-3 text-right">
                        <form method="POST" action="{{ route('admin.posts.spare-parts.destroy', $part) }}"
                              onsubmit="return confirm('Delete this part?')">
                            @csrf @method('DELETE')
                            <button type="submit" class="text-xs text-red-600 hover:underline">Delete</button>
                        </form>
                    </td>
                </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @endif

    {{-- Vehicles --}}
    @if($user->salvagedVehicles->isNotEmpty())
    <div class="bg-white rounded-xl border border-gray-200">
        <div class="px-5 py-4 border-b border-gray-100">
            <h3 class="font-semibold text-gray-900 text-sm">Salvaged Vehicles ({{ $user->salvagedVehicles->count() }})</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead><tr class="bg-gray-50 text-xs font-semibold text-gray-500 uppercase tracking-wider text-left">
                    <th class="px-5 py-3">Vehicle</th>
                    <th class="px-5 py-3">Price</th>
                    <th class="px-5 py-3">Condition</th>
                    <th class="px-5 py-3">Posted</th>
                    <th class="px-5 py-3 text-right">Action</th>
                </tr></thead>
                <tbody class="divide-y divide-gray-50">
                @foreach($user->salvagedVehicles as $vehicle)
                <tr class="hover:bg-gray-50">
                    <td class="px-5 py-3 font-medium text-gray-900">{{ $vehicle->brand }} {{ $vehicle->model }} ({{ $vehicle->year }})</td>
                    <td class="px-5 py-3 text-gray-600">SAR {{ number_format($vehicle->price, 2) }}</td>
                    <td class="px-5 py-3 text-gray-600">{{ $vehicle->condition }}</td>
                    <td class="px-5 py-3 text-gray-400 text-xs">{{ $vehicle->created_at->format('d M Y') }}</td>
                    <td class="px-5 py-3 text-right">
                        <form method="POST" action="{{ route('admin.posts.vehicles.destroy', $vehicle) }}"
                              onsubmit="return confirm('Delete this vehicle listing?')">
                            @csrf @method('DELETE')
                            <button type="submit" class="text-xs text-red-600 hover:underline">Delete</button>
                        </form>
                    </td>
                </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    </div>
    @endif

    {{-- Ban modal --}}
    <div x-show="banModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
        <div @click.stop class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Ban {{ $user->name }}</h3>
            <form method="POST" action="{{ route('admin.users.ban', $user) }}">
                @csrf
                <textarea name="reason" rows="3" required
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="Enter ban reason…"></textarea>
                <div class="flex gap-3 mt-4">
                    <button type="button" @click="banModal=false"
                            class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm">Cancel</button>
                    <button type="submit"
                            class="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700">Confirm Ban</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
