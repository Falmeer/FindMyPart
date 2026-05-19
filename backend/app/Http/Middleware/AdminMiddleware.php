<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!auth()->check() || !auth()->user()->isAdmin()) {
            if ($request->expectsJson()) {
                return response()->json(['message' => 'Unauthorized.'], 403);
            }
            return redirect()->route('admin.login')->with('error', 'Access denied. Admin credentials required.');
        }

        if (auth()->user()->is_banned) {
            auth()->logout();
            return redirect()->route('admin.login')->with('error', 'This account has been suspended.');
        }

        return $next($request);
    }
}
