@extends('admin.layouts.app')
@section('title', 'Edit Garage')
@section('breadcrumb', 'Garages / Edit')

@section('content')
<div class="max-w-2xl">
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h3 class="font-semibold text-gray-900 mb-6">Edit: {{ $garage->name }}</h3>

        @if($errors->any())
        <div class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            <ul class="list-disc list-inside space-y-1">
                @foreach($errors->all() as $e) <li>{{ $e }}</li> @endforeach
            </ul>
        </div>
        @endif

        <form method="POST" action="{{ route('admin.garages.update', $garage) }}" class="space-y-5">
            @csrf @method('PUT')

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Garage Name *</label>
                <input type="text" name="name" value="{{ old('name', $garage->name) }}" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Description</label>
                <textarea name="description" rows="3"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('description', $garage->description) }}</textarea>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Phone</label>
                    <input type="text" name="phone" value="{{ old('phone', $garage->phone) }}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Working Hours</label>
                    <input type="text" name="working_hours" value="{{ old('working_hours', $garage->working_hours) }}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Address</label>
                    <input type="text" name="address" value="{{ old('address', $garage->address) }}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Google Maps Link</label>
                    <input type="url" name="maps_link" value="{{ old('maps_link') }}"
                           placeholder="Paste a new link to update location"
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 @error('maps_link') border-red-400 @enderror">
                    @error('maps_link')
                        <p class="mt-1 text-xs text-red-600">{{ $message }}</p>
                    @enderror
                    @if($garage->latitude && $garage->longitude)
                        <p class="mt-1 text-xs text-gray-500">
                            Current: {{ $garage->latitude }}, {{ $garage->longitude }} —
                            <a href="https://maps.google.com/?q={{ $garage->latitude }},{{ $garage->longitude }}"
                               target="_blank" class="text-blue-500 hover:underline">View on Maps</a>
                        </p>
                    @else
                        <p class="mt-1 text-xs text-gray-400">No location set. Open Google Maps → tap <strong>Share</strong> → Copy link (not a directions link).</p>
                    @endif
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Status *</label>
                    <select name="status" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                        @foreach(['approved','pending','rejected','suspended'] as $s)
                        <option value="{{ $s }}" {{ old('status', $garage->status ?? 'approved') === $s ? 'selected' : '' }}>{{ ucfirst($s) }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="flex items-center gap-4 pt-6">
                    <label class="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
                        <input type="checkbox" name="is_verified" value="1" {{ old('is_verified', $garage->is_verified) ? 'checked' : '' }}
                               class="rounded text-blue-600">
                        Verified
                    </label>
                    <label class="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
                        <input type="checkbox" name="is_active" value="1" {{ old('is_active', $garage->is_active) ? 'checked' : '' }}
                               class="rounded text-blue-600">
                        Active
                    </label>
                </div>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Admin Notes</label>
                <textarea name="admin_notes" rows="2"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('admin_notes', $garage->admin_notes) }}</textarea>
            </div>

            <div class="flex gap-3">
                <a href="{{ route('admin.garages.show', $garage) }}" class="px-5 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">Cancel</a>
                <button type="submit" class="px-5 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Save Changes</button>
            </div>
        </form>
    </div>
</div>
@endsection
