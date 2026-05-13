<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Scrapyard\ScrapyardResource;
use App\Models\Scrapyard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScrapyardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Scrapyard::with(['user'])->where('is_active', true);

        if ($request->filled('lat') && $request->filled('lng')) {
            $query->nearby(
                (float) $request->lat,
                (float) $request->lng,
                (float) ($request->radius ?? 10)
            );
        }

        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        $scrapyards = $query->paginate($request->per_page ?? 15);

        return response()->json([
            'success'    => true,
            'message'    => 'Scrapyards fetched successfully',
            'data'       => ScrapyardResource::collection($scrapyards->items()),
            'pagination' => [
                'current_page' => $scrapyards->currentPage(),
                'last_page'    => $scrapyards->lastPage(),
                'per_page'     => $scrapyards->perPage(),
                'total'        => $scrapyards->total(),
            ],
        ]);
    }

    public function show(Scrapyard $scrapyard): JsonResponse
    {
        $scrapyard->load(['user', 'reviews.user']);

        return response()->json([
            'success' => true,
            'data'    => new ScrapyardResource($scrapyard),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'          => 'required|string|max:255',
            'description'   => 'nullable|string',
            'phone'         => 'nullable|string|max:20',
            'address'       => 'nullable|string',
            'latitude'      => 'nullable|numeric',
            'longitude'     => 'nullable|numeric',
            'services'      => 'nullable|array',
            'working_hours' => 'nullable|string',
        ]);

        $scrapyard = Scrapyard::create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Scrapyard profile created',
            'data'    => new ScrapyardResource($scrapyard),
        ], 201);
    }
}
