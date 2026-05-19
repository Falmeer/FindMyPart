<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\SparePart;
use App\Models\SalvagedVehicle;
use Illuminate\Http\Request;

class AdminPostController extends Controller
{
    public function index(Request $request)
    {
        $type   = $request->input('type', 'spare_parts');
        $search = $request->input('search');
        $from   = $request->input('date_from');
        $to     = $request->input('date_to');

        if ($type === 'vehicles') {
            $query = SalvagedVehicle::with(['user', 'images']);

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('brand', 'like', "%{$search}%")
                      ->orWhere('model', 'like', "%{$search}%")
                      ->orWhereHas('user', fn($u) => $u->where('name', 'like', "%{$search}%"));
                });
            }
        } else {
            $query = SparePart::with(['user', 'category', 'images']);

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhereHas('user', fn($u) => $u->where('name', 'like', "%{$search}%"));
                });
            }
        }

        if ($from) {
            $query->whereDate('created_at', '>=', $from);
        }
        if ($to) {
            $query->whereDate('created_at', '<=', $to);
        }

        $posts = $query->latest()->paginate(20)->withQueryString();

        return view('admin.posts.index', compact('posts', 'type'));
    }

    public function destroySparePart(SparePart $sparePart)
    {
        $name = $sparePart->name;

        AdminActivityLog::record(
            'delete_spare_part',
            "Deleted spare part: {$name} (ID: {$sparePart->id})",
            SparePart::class,
            $sparePart->id
        );

        $sparePart->delete();

        return redirect()->route('admin.posts.index', ['type' => 'spare_parts'])
            ->with('success', "Spare part \"{$name}\" has been deleted.");
    }

    public function destroyVehicle(SalvagedVehicle $vehicle)
    {
        $name = "{$vehicle->brand} {$vehicle->model} ({$vehicle->year})";

        AdminActivityLog::record(
            'delete_vehicle',
            "Deleted vehicle listing: {$name} (ID: {$vehicle->id})",
            SalvagedVehicle::class,
            $vehicle->id
        );

        $vehicle->delete();

        return redirect()->route('admin.posts.index', ['type' => 'vehicles'])
            ->with('success', "Vehicle \"{$name}\" has been deleted.");
    }

    public function toggleSparePartActive(SparePart $sparePart)
    {
        $sparePart->update(['is_active' => !$sparePart->is_active]);
        $state = $sparePart->is_active ? 'shown' : 'hidden';

        AdminActivityLog::record(
            'toggle_spare_part',
            "Spare part \"{$sparePart->name}\" {$state}",
            SparePart::class,
            $sparePart->id
        );

        return back()->with('success', "Spare part is now {$state}.");
    }

    public function toggleVehicleActive(SalvagedVehicle $vehicle)
    {
        $vehicle->update(['is_active' => !$vehicle->is_active]);
        $state = $vehicle->is_active ? 'shown' : 'hidden';
        $name = "{$vehicle->brand} {$vehicle->model}";

        AdminActivityLog::record(
            'toggle_vehicle',
            "Vehicle listing \"{$name}\" {$state}",
            SalvagedVehicle::class,
            $vehicle->id
        );

        return back()->with('success', "Vehicle listing is now {$state}.");
    }
}
