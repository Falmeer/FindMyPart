<?php

namespace App\Http\Controllers\API\V1;

use App\Events\VehicleListed;
use App\Http\Controllers\Controller;
use App\Http\Requests\Vehicle\StoreVehicleRequest;
use App\Http\Resources\Vehicle\VehicleResource;
use App\Http\Resources\Vehicle\VehicleCollection;
use App\Models\SalvagedVehicle;
use App\Models\VehicleImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class VehicleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $vehicles = SalvagedVehicle::with(['images', 'user'])
            ->where('is_active', true)
            ->filter($request->all())
            ->latest()
            ->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'message' => 'Vehicles fetched successfully',
            'data' => VehicleResource::collection($vehicles->items()),
            'pagination' => [
                'current_page' => $vehicles->currentPage(),
                'last_page' => $vehicles->lastPage(),
                'per_page' => $vehicles->perPage(),
                'total' => $vehicles->total(),
            ],
        ]);
    }

    public function show(SalvagedVehicle $vehicle): JsonResponse
    {
        $vehicle->load(['images', 'user']);

        return response()->json([
            'success' => true,
            'data' => new VehicleResource($vehicle),
        ]);
    }

    public function store(StoreVehicleRequest $request): JsonResponse
    {
        $this->authorize('create', SalvagedVehicle::class);

        $vehicle = SalvagedVehicle::create([
            ...$request->validated(),
            'user_id' => $request->user()->id,
        ]);

        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('vehicles', 'public');
                VehicleImage::create([
                    'salvaged_vehicle_id' => $vehicle->id,
                    'path' => $path,
                    'url' => url('api/v1/files/' . $path),
                    'is_primary' => $index === 0,
                ]);
            }
        }

        $vehicle->load(['images', 'user']);

        VehicleListed::dispatch($vehicle->id);

        return response()->json([
            'success' => true,
            'message' => 'Vehicle listed successfully',
            'data' => new VehicleResource($vehicle),
        ], 201);
    }

    public function update(StoreVehicleRequest $request, SalvagedVehicle $vehicle): JsonResponse
    {
        $this->authorize('update', $vehicle);

        $vehicle->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Vehicle updated',
            'data' => new VehicleResource($vehicle->fresh(['images', 'user'])),
        ]);
    }

    public function destroy(SalvagedVehicle $vehicle): JsonResponse
    {
        $this->authorize('delete', $vehicle);
        $vehicle->delete();

        return response()->json(['success' => true, 'message' => 'Vehicle deleted']);
    }
}
