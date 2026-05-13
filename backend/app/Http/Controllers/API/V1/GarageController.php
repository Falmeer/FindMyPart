<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Garage\GarageResource;
use App\Models\Garage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GarageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Garage::with(['user'])
            ->where('is_active', true);

        if ($request->filled('lat') && $request->filled('lng')) {
            $query->nearby(
                (float) $request->lat,
                (float) $request->lng,
                (float) ($request->radius ?? 10)
            );
        }

        if ($request->filled('search')) {
            $query->where('name', 'like', '%'.$request->search.'%');
        }

        $garages = $query->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'message' => 'Garages fetched successfully',
            'data' => GarageResource::collection($garages->items()),
            'pagination' => [
                'current_page' => $garages->currentPage(),
                'last_page' => $garages->lastPage(),
                'per_page' => $garages->perPage(),
                'total' => $garages->total(),
            ],
        ]);
    }

    public function show(Garage $garage): JsonResponse
    {
        $garage->load(['user', 'reviews.user']);

        return response()->json([
            'success' => true,
            'data' => new GarageResource($garage),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'services' => 'nullable|array',
            'working_hours' => 'nullable|string',
        ]);

        $garage = Garage::create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Garage profile created',
            'data' => new GarageResource($garage),
        ], 201);
    }
}
