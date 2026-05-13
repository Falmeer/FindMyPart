<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Vehicle\VehicleResource;
use App\Http\Resources\SparePart\SparePartResource;
use App\Http\Resources\Garage\GarageResource;
use App\Http\Resources\Scrapyard\ScrapyardResource;
use App\Models\Favorite;
use App\Models\SalvagedVehicle;
use App\Models\SparePart;
use App\Models\Garage;
use App\Models\Scrapyard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    private static array $morphMap = [
        'vehicle'   => SalvagedVehicle::class,
        'part'      => SparePart::class,
        'garage'    => Garage::class,
        'scrapyard' => Scrapyard::class,
    ];

    public function toggle(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type' => 'required|in:vehicle,part,garage',
            'id'   => 'required|integer',
        ]);

        $type   = self::$morphMap[$validated['type']];
        $userId = $request->user()->id;

        $existing = Favorite::where([
            'user_id'          => $userId,
            'favoritable_type' => $type,
            'favoritable_id'   => $validated['id'],
        ])->first();

        if ($existing) {
            $existing->delete();
            return response()->json(['success' => true, 'favorited' => false]);
        }

        Favorite::create([
            'user_id'          => $userId,
            'favoritable_type' => $type,
            'favoritable_id'   => $validated['id'],
        ]);

        return response()->json(['success' => true, 'favorited' => true]);
    }

    public function index(Request $request): JsonResponse
    {
        $type  = $request->query('type');
        $query = Favorite::where('user_id', $request->user()->id)->with('favoritable');

        if ($type && isset(self::$morphMap[$type])) {
            $query->where('favoritable_type', self::$morphMap[$type]);
        }

        $favorites = $query->latest()->get();

        $data = $favorites->map(function ($fav) use ($request) {
            $item = $fav->favoritable;
            if (! $item) return null;

            if ($item instanceof SalvagedVehicle) {
                $item->load(['images', 'user']);
                return (new VehicleResource($item))->toArray($request);
            }
            if ($item instanceof SparePart) {
                $item->load(['images', 'user']);
                return (new SparePartResource($item))->toArray($request);
            }
            if ($item instanceof Garage) {
                return (new GarageResource($item))->toArray($request);
            }
            if ($item instanceof Scrapyard) {
                return (new ScrapyardResource($item))->toArray($request);
            }
            return null;
        })->filter()->values();

        return response()->json(['success' => true, 'data' => $data]);
    }
}
