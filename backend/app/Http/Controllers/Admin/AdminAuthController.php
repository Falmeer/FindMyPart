<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;

class AdminAuthController extends Controller
{
    public function showLogin()
    {
        if (Auth::check() && Auth::user()->isAdmin()) {
            return redirect()->route('admin.dashboard');
        }
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $key = 'admin-login:' . $request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            return back()->withErrors([
                'email' => "Too many login attempts. Please try again in {$seconds} seconds.",
            ])->withInput($request->only('email'));
        }

        $credentials = $request->only('email', 'password');

        if (!Auth::attempt($credentials, $request->boolean('remember'))) {
            RateLimiter::hit($key, 300);
            return back()->withErrors([
                'email' => 'These credentials do not match our records.',
            ])->withInput($request->only('email'));
        }

        $user = Auth::user();

        if (!$user->isAdmin()) {
            Auth::logout();
            RateLimiter::hit($key, 300);
            return back()->withErrors([
                'email' => 'You do not have permission to access the admin panel.',
            ])->withInput($request->only('email'));
        }

        if ($user->is_banned) {
            Auth::logout();
            return back()->withErrors(['email' => 'This account has been suspended.']);
        }

        RateLimiter::clear($key);
        $request->session()->regenerate();

        return redirect()->route('admin.dashboard');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login')->with('success', 'You have been logged out.');
    }
}
