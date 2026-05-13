<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Models\VehicleIssue;
use App\Models\GarageOffer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VehicleIssueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $issues = VehicleIssue::with(['user', 'offers.garage'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $issues->items(),
            'pagination' => [
                'current_page' => $issues->currentPage(),
                'last_page' => $issues->lastPage(),
                'total' => $issues->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'brand' => 'required|string|max:100',
            'model' => 'required|string|max:100',
            'year' => 'required|integer|min:1980|max:2025',
            'description' => 'required|string|min:20',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $issue = VehicleIssue::create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Issue posted successfully',
            'data' => $issue,
        ], 201);
    }

    public function show(VehicleIssue $vehicleIssue): JsonResponse
    {
        $vehicleIssue->load(['user', 'offers.garage']);

        return response()->json([
            'success' => true,
            'data' => $vehicleIssue,
        ]);
    }

    public function openIssues(Request $request): JsonResponse
    {
        $garage = $request->user()->garage;

        $issues = VehicleIssue::with(['user', 'offers'])
            ->where('status', 'open')
            ->latest()
            ->paginate(20);

        $items = collect($issues->items())->map(function ($issue) use ($garage) {
            return [
                'id' => $issue->id,
                'brand' => $issue->brand,
                'model' => $issue->model,
                'year' => $issue->year,
                'description' => $issue->description,
                'status' => $issue->status,
                'offer_count' => $issue->offers->count(),
                'my_offer' => $garage ? $issue->offers->where('garage_id', $garage->id)->first() : null,
                'user' => ['name' => $issue->user->name, 'phone' => $issue->user->phone],
                'created_at' => $issue->created_at->toISOString(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $items,
            'pagination' => [
                'current_page' => $issues->currentPage(),
                'last_page' => $issues->lastPage(),
                'total' => $issues->total(),
            ],
        ]);
    }

    public function storeOffer(Request $request, VehicleIssue $vehicleIssue): JsonResponse
    {
        $validated = $request->validate([
            'message' => 'required|string',
            'price' => 'nullable|numeric|min:0',
        ]);

        $garage = $request->user()->garage;
        if (! $garage) {
            return response()->json(['success' => false, 'message' => 'No garage profile found'], 403);
        }

        $existing = GarageOffer::where('vehicle_issue_id', $vehicleIssue->id)
            ->where('garage_id', $garage->id)
            ->first();

        if ($existing) {
            return response()->json(['success' => false, 'message' => 'You already submitted an offer'], 422);
        }

        $offer = GarageOffer::create([
            ...$validated,
            'vehicle_issue_id' => $vehicleIssue->id,
            'garage_id' => $garage->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Offer submitted',
            'data' => $offer,
        ], 201);
    }

    public function updateOffer(Request $request, VehicleIssue $vehicleIssue, GarageOffer $offer): JsonResponse
    {
        if ($vehicleIssue->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate(['status' => 'required|in:accepted,rejected']);
        $offer->update(['status' => $validated['status']]);

        if ($validated['status'] === 'accepted') {
            $vehicleIssue->update(['status' => 'in_progress']);
        }

        return response()->json(['success' => true, 'message' => 'Offer ' . $validated['status']]);
    }
}
