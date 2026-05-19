@extends('admin.layouts.app')
@section('title', 'Create Scrapyard')
@section('breadcrumb', 'Scrapyards / Create')

@section('content')
<div class="max-w-2xl">
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h3 class="font-semibold text-gray-900 mb-6">New Scrapyard Account</h3>

        @if($errors->any())
        <div class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            <ul class="list-disc list-inside space-y-1">
                @foreach($errors->all() as $e) <li>{{ $e }}</li> @endforeach
            </ul>
        </div>
        @endif

        <form method="POST" action="{{ route('admin.scrapyards.store') }}" class="space-y-6">
            @csrf

            <fieldset class="border border-gray-200 rounded-lg p-4 space-y-4">
                <legend class="text-sm font-semibold text-gray-700 px-2">Owner Account</legend>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Full Name *</label>
                        <input type="text" name="owner_name" value="{{ old('owner_name') }}" required
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Email *</label>
                        <input type="email" name="owner_email" value="{{ old('owner_email') }}" required
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    @include('admin.partials.phone_input', ['name' => 'owner_phone', 'codeName' => 'owner_phone_code', 'label' => 'Phone'])
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Password *</label>
                        <input type="password" name="owner_password" required
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
            </fieldset>

            <fieldset class="border border-gray-200 rounded-lg p-4 space-y-4">
                <legend class="text-sm font-semibold text-gray-700 px-2">Scrapyard Details</legend>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Scrapyard Name *</label>
                    <input type="text" name="name" value="{{ old('name') }}" required
                           class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">Description</label>
                    <textarea name="description" rows="3"
                              class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">{{ old('description') }}</textarea>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    @include('admin.partials.phone_input', ['name' => 'phone', 'codeName' => 'phone_code', 'label' => 'Business Phone'])
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Working Hours</label>
                        <input type="text" name="working_hours" value="{{ old('working_hours') }}"
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="sm:col-span-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Address</label>
                        <input type="text" name="address" value="{{ old('address') }}"
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="sm:col-span-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Google Maps Link</label>
                        <input type="url" name="maps_link" value="{{ old('maps_link') }}"
                               placeholder="https://maps.google.com/maps/place/.../@26.217,50.597,17z/"
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 @error('maps_link') border-red-400 @enderror">
                        @error('maps_link')
                            <p class="mt-1 text-xs text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-xs text-gray-400">Open Google Maps → find the location → tap <strong>Share</strong> → Copy link. Do <em>not</em> paste a navigation/directions link.</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1.5">Status *</label>
                        <select name="status" required class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="approved" selected>Approved</option>
                            <option value="pending">Pending</option>
                            <option value="rejected">Rejected</option>
                        </select>
                    </div>
                </div>
            </fieldset>

            <div class="flex gap-3">
                <a href="{{ route('admin.scrapyards.index') }}" class="px-5 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50">Cancel</a>
                <button type="submit" class="px-5 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">Create Scrapyard</button>
            </div>
        </form>
    </div>
</div>
@endsection
