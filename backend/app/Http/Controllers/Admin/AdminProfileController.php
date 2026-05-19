<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminProfileController extends Controller
{
    public function edit()
    {
        return view('admin.profile.edit', ['admin' => auth()->user()]);
    }

    public function update(Request $request)
    {
        $admin = auth()->user();

        $request->validate([
            'name'  => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $admin->id,
        ]);

        $admin->update($request->only('name', 'email'));

        AdminActivityLog::record('update_profile', 'Admin updated their profile.');

        return back()->with('success', 'Profile updated successfully.');
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'password'         => 'required|string|min:8|confirmed',
        ]);

        $admin = auth()->user();

        if (!Hash::check($request->input('current_password'), $admin->password)) {
            return back()->withErrors(['current_password' => 'Current password is incorrect.']);
        }

        $admin->update(['password' => Hash::make($request->input('password'))]);

        AdminActivityLog::record('change_password', 'Admin changed their password.');

        return back()->with('success', 'Password changed successfully.');
    }
}
