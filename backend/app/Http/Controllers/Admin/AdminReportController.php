<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\Report;
use Illuminate\Http\Request;

class AdminReportController extends Controller
{
    public function index(Request $request)
    {
        $query = Report::with(['reporter', 'reviewer']);

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($search = $request->input('search')) {
            $query->whereHas('reporter', fn($q) => $q->where('name', 'like', "%{$search}%"))
                  ->orWhere('reason', 'like', "%{$search}%");
        }

        $reports = $query->latest()->paginate(20)->withQueryString();

        return view('admin.reports.index', compact('reports'));
    }

    public function show(Report $report)
    {
        $report->load(['reporter', 'reviewer', 'reportable']);
        return view('admin.reports.show', compact('report'));
    }

    public function resolve(Request $request, Report $report)
    {
        $request->validate([
            'admin_notes' => 'nullable|string|max:1000',
        ]);

        $report->update([
            'status'      => 'resolved',
            'reviewed_by' => auth()->id(),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        AdminActivityLog::record(
            'resolve_report',
            "Resolved report #{$report->id}: {$report->reason}",
            Report::class,
            $report->id
        );

        return back()->with('success', 'Report marked as resolved.');
    }

    public function dismiss(Request $request, Report $report)
    {
        $request->validate([
            'admin_notes' => 'nullable|string|max:1000',
        ]);

        $report->update([
            'status'      => 'dismissed',
            'reviewed_by' => auth()->id(),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        AdminActivityLog::record(
            'dismiss_report',
            "Dismissed report #{$report->id}: {$report->reason}",
            Report::class,
            $report->id
        );

        return back()->with('success', 'Report dismissed.');
    }
}
