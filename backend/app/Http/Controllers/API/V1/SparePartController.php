<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\SparePart\StoreSparePartRequest;
use App\Http\Resources\SparePart\SparePartResource;
use App\Models\SparePart;
use App\Models\SparePartImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SparePartController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $parts = SparePart::with(['images', 'user', 'category'])
            ->where('is_active', true)
            ->filter($request->all())
            ->latest()
            ->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'message' => 'Spare parts fetched successfully',
            'data' => SparePartResource::collection($parts->items()),
            'pagination' => [
                'current_page' => $parts->currentPage(),
                'last_page' => $parts->lastPage(),
                'per_page' => $parts->perPage(),
                'total' => $parts->total(),
            ],
        ]);
    }

    public function show(SparePart $sparePart): JsonResponse
    {
        $sparePart->load(['images', 'user', 'category']);

        return response()->json([
            'success' => true,
            'data' => new SparePartResource($sparePart),
        ]);
    }

    public function store(StoreSparePartRequest $request): JsonResponse
    {
        $part = SparePart::create([
            ...$request->validated(),
            'user_id' => $request->user()->id,
        ]);

        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('spare-parts', 'public');
                SparePartImage::create([
                    'spare_part_id' => $part->id,
                    'path' => $path,
                    'url' => Storage::url($path),
                    'is_primary' => $index === 0,
                ]);
            }
        }

        $part->load(['images', 'user', 'category']);

        return response()->json([
            'success' => true,
            'message' => 'Spare part listed successfully',
            'data' => new SparePartResource($part),
        ], 201);
    }

    public function update(StoreSparePartRequest $request, SparePart $sparePart): JsonResponse
    {
        $this->authorize('update', $sparePart);
        $sparePart->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Spare part updated',
            'data' => new SparePartResource($sparePart->fresh(['images', 'user', 'category'])),
        ]);
    }

    public function destroy(SparePart $sparePart): JsonResponse
    {
        $this->authorize('delete', $sparePart);
        $sparePart->delete();

        return response()->json(['success' => true, 'message' => 'Spare part deleted']);
    }
}
