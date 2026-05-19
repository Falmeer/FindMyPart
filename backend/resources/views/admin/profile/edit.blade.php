@extends('admin.layouts.app')
@section('title', 'My Profile')

@section('content')
<div class="max-w-2xl space-y-6">

    {{-- Profile details --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h3 class="font-semibold text-gray-900 mb-5">Profile Information</h3>

        @if($errors->any() && !$errors->has('current_password') && !$errors->has('password'))
        <div class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            <ul class="list-disc list-inside space-y-1">
                @foreach($errors->all() as $e) <li>{{ $e }}</li> @endforeach
            </ul>
        </div>
        @endif

        <form method="POST" action="{{ route('admin.profile.update') }}" class="space-y-4">
            @csrf @method('PUT')
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Full Name</label>
                <input type="text" name="name" value="{{ old('name', $admin->name) }}" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Email</label>
                <input type="email" name="email" value="{{ old('email', $admin->email) }}" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <button type="submit" class="px-5 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">
                Save Changes
            </button>
        </form>
    </div>

    {{-- Change password --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h3 class="font-semibold text-gray-900 mb-5">Change Password</h3>

        @if($errors->has('current_password') || $errors->has('password'))
        <div class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            <ul class="list-disc list-inside space-y-1">
                @foreach(['current_password','password'] as $field)
                @error($field) <li>{{ $message }}</li> @enderror
                @endforeach
            </ul>
        </div>
        @endif

        <form method="POST" action="{{ route('admin.profile.password') }}" class="space-y-4">
            @csrf @method('PUT')
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Current Password</label>
                <input type="password" name="current_password" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">New Password</label>
                <input type="password" name="password" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Confirm New Password</label>
                <input type="password" name="password_confirmation" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <button type="submit" class="px-5 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700">
                Update Password
            </button>
        </form>
    </div>

    {{-- Info card --}}
    <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h3 class="font-semibold text-gray-900 mb-3 text-sm">Account Info</h3>
        <dl class="space-y-2 text-sm">
            <div class="flex gap-4">
                <dt class="w-32 text-gray-500">Role</dt>
                <dd class="font-medium text-blue-600">Administrator</dd>
            </div>
            <div class="flex gap-4">
                <dt class="w-32 text-gray-500">Member since</dt>
                <dd class="text-gray-700">{{ $admin->created_at->format('d F Y') }}</dd>
            </div>
            <div class="flex gap-4">
                <dt class="w-32 text-gray-500">Last login</dt>
                <dd class="text-gray-700">Now</dd>
            </div>
        </dl>
    </div>
</div>
@endsection
