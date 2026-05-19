<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminUserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query()->where('role', '!=', 'admin');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        if ($role = $request->input('role')) {
            $query->where('role', $role);
        }

        if ($status = $request->input('status')) {
            if ($status === 'banned') {
                $query->where('is_banned', true);
            } elseif ($status === 'inactive') {
                $query->where('is_active', false)->where('is_banned', false);
            } elseif ($status === 'active') {
                $query->where('is_active', true)->where('is_banned', false);
            }
        }

        $users = $query->latest()->paginate(20)->withQueryString();

        return view('admin.users.index', compact('users'));
    }

    public function show(User $user)
    {
        $user->load(['garage', 'scrapyard', 'spareParts.images', 'salvagedVehicles.images']);
        return view('admin.users.show', compact('user'));
    }

    public function ban(Request $request, User $user)
    {
        $request->validate([
            'reason' => 'required|string|max:500',
        ]);

        if ($user->isAdmin()) {
            return back()->with('error', 'Cannot ban an admin account.');
        }

        $user->update([
            'is_banned'     => true,
            'banned_reason' => $request->input('reason'),
            'banned_at'     => now(),
        ]);

        AdminActivityLog::record(
            'ban_user',
            "Banned user: {$user->name} ({$user->email}). Reason: {$request->input('reason')}",
            User::class,
            $user->id,
            ['reason' => $request->input('reason')]
        );

        return back()->with('success', "User \"{$user->name}\" has been banned.");
    }

    public function unban(User $user)
    {
        $user->update([
            'is_banned'     => false,
            'banned_reason' => null,
            'banned_at'     => null,
        ]);

        AdminActivityLog::record(
            'unban_user',
            "Unbanned user: {$user->name} ({$user->email})",
            User::class,
            $user->id
        );

        return back()->with('success', "User \"{$user->name}\" has been unbanned.");
    }

    public function destroy(User $user)
    {
        if ($user->isAdmin()) {
            return back()->with('error', 'Cannot delete an admin account.');
        }

        $name = $user->name;
        $email = $user->email;

        AdminActivityLog::record(
            'delete_user',
            "Deleted user: {$name} ({$email})",
            User::class,
            $user->id,
            ['email' => $email, 'role' => $user->role]
        );

        $user->delete();

        return redirect()->route('admin.users.index')->with('success', "User \"{$name}\" has been deleted.");
    }

    public function bannedAccounts()
    {
        $users = User::where('is_banned', true)->latest('banned_at')->paginate(20);
        return view('admin.users.banned', compact('users'));
    }
}
