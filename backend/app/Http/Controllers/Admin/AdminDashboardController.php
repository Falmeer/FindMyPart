<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\Garage;
use App\Models\Report;
use App\Models\Scrapyard;
use App\Models\SparePart;
use App\Models\SalvagedVehicle;
use App\Models\User;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'total_users'       => User::where('role', '!=', 'admin')->count(),
            'total_garages'     => Garage::count(),
            'total_scrapyards'  => Scrapyard::count(),
            'total_spare_parts' => SparePart::count(),
            'total_vehicles'    => SalvagedVehicle::count(),
            'pending_reports'   => Report::where('status', 'pending')->count(),
            'banned_users'      => User::where('is_banned', true)->count(),
            'pending_garages'   => Garage::where('status', 'pending')->count(),
            'pending_scrapyards'=> Scrapyard::where('status', 'pending')->count(),
        ];

        $recentUsers = User::where('role', '!=', 'admin')
            ->latest()
            ->limit(5)
            ->get();

        $recentLogs = AdminActivityLog::with('admin')
            ->latest()
            ->limit(10)
            ->get();

        $recentReports = Report::with('reporter')
            ->where('status', 'pending')
            ->latest()
            ->limit(5)
            ->get();

        // Monthly user registrations for chart (last 6 months)
        $userGrowth = User::selectRaw("strftime('%Y-%m', created_at) as month, COUNT(*) as count")
            ->where('role', '!=', 'admin')
            ->where('created_at', '>=', now()->subMonths(6))
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        return view('admin.dashboard', compact(
            'stats', 'recentUsers', 'recentLogs', 'recentReports', 'userGrowth'
        ));
    }
}
