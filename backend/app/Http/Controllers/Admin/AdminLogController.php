<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use Illuminate\Http\Request;

class AdminLogController extends Controller
{
    public function index(Request $request)
    {
        $query = AdminActivityLog::with('admin');

        if ($action = $request->input('action')) {
            $query->where('action', 'like', "%{$action}%");
        }

        if ($from = $request->input('date_from')) {
            $query->whereDate('created_at', '>=', $from);
        }
        if ($to = $request->input('date_to')) {
            $query->whereDate('created_at', '<=', $to);
        }

        $logs = $query->latest()->paginate(30)->withQueryString();

        return view('admin.logs.index', compact('logs'));
    }
}
