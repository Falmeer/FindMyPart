<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\Garage;
use App\Models\User;
use App\Services\LocationParser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminGarageController extends Controller
{
    public function index(Request $request)
    {
        $query = Garage::with('user');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('address', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        $garages = $query->latest()->paginate(20)->withQueryString();

        return view('admin.garages.index', compact('garages'));
    }

    public function show(Garage $garage)
    {
        $garage->load(['user', 'reviews.user']);
        return view('admin.garages.show', compact('garage'));
    }

    public function create()
    {
        return view('admin.garages.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'owner_name'    => 'required|string|max:255',
            'owner_email'   => 'required|email|unique:users,email',
            'owner_phone'   => 'nullable|string|max:20',
            'owner_password'=> 'required|string|min:8',
            'name'          => 'required|string|max:255',
            'description'   => 'nullable|string',
            'phone'         => 'nullable|string|max:20',
            'address'       => 'nullable|string|max:500',
            'maps_link'     => 'nullable|string|max:1000',
            'working_hours' => 'nullable|string|max:255',
            'status'        => 'required|in:pending,approved,rejected,suspended',
        ]);

        [$lat, $lng] = self::parseLocation($request->input('maps_link'));
        if ($request->filled('maps_link') && $lat === null) {
            return back()->withErrors(['maps_link' => 'Could not extract coordinates from this link. Try copying the full URL from Google Maps instead.'])->withInput();
        }

        $ownerPhone   = $data['owner_phone'] ?? null;
        $businessPhone = $data['phone'] ?? null;
        if ($ownerPhone)   $ownerPhone   = $request->input('owner_phone_code', '+973') . $ownerPhone;
        if ($businessPhone) $businessPhone = $request->input('phone_code', '+973') . $businessPhone;

        $user = User::create([
            'name'                 => $data['owner_name'],
            'email'                => $data['owner_email'],
            'phone'                => $ownerPhone,
            'password'             => Hash::make($data['owner_password']),
            'role'                 => 'garage',
            'is_active'            => true,
            'must_change_password' => true,
        ]);

        $garage = Garage::create([
            'user_id'       => $user->id,
            'name'          => $data['name'],
            'description'   => $data['description'] ?? null,
            'phone'         => $businessPhone,
            'address'       => $data['address'] ?? null,
            'latitude'      => $lat,
            'longitude'     => $lng,
            'working_hours' => $data['working_hours'] ?? null,
            'status'        => $data['status'],
            'is_active'     => true,
        ]);

        AdminActivityLog::record(
            'create_garage',
            "Created garage: {$garage->name} (owner: {$user->email})",
            Garage::class,
            $garage->id
        );

        return redirect()->route('admin.garages.show', $garage)->with('success', 'Garage created successfully.');
    }

    public function edit(Garage $garage)
    {
        $garage->load('user');
        return view('admin.garages.edit', compact('garage'));
    }

    public function update(Request $request, Garage $garage)
    {
        $data = $request->validate([
            'name'          => 'required|string|max:255',
            'description'   => 'nullable|string',
            'phone'         => 'nullable|string|max:20',
            'address'       => 'nullable|string|max:500',
            'maps_link'     => 'nullable|string|max:1000',
            'working_hours' => 'nullable|string|max:255',
            'status'        => 'required|in:pending,approved,rejected,suspended',
            'admin_notes'   => 'nullable|string|max:1000',
            'is_verified'   => 'boolean',
            'is_active'     => 'boolean',
        ]);

        if ($request->filled('maps_link')) {
            [$lat, $lng] = self::parseLocation($request->input('maps_link'));
            if ($lat === null) {
                return back()->withErrors(['maps_link' => 'Could not extract coordinates from this link. Try copying the full URL from Google Maps instead.'])->withInput();
            }
            $data['latitude']  = $lat;
            $data['longitude'] = $lng;
        }

        unset($data['maps_link']);
        $garage->update($data);

        AdminActivityLog::record(
            'update_garage',
            "Updated garage: {$garage->name}",
            Garage::class,
            $garage->id,
            ['status' => $data['status']]
        );

        return redirect()->route('admin.garages.show', $garage)->with('success', 'Garage updated successfully.');
    }

    public function updateStatus(Request $request, Garage $garage)
    {
        $request->validate([
            'status'      => 'required|in:pending,approved,rejected,suspended',
            'admin_notes' => 'nullable|string|max:1000',
        ]);

        $garage->update([
            'status'      => $request->input('status'),
            'admin_notes' => $request->input('admin_notes'),
        ]);

        AdminActivityLog::record(
            'update_garage_status',
            "Changed garage \"{$garage->name}\" status to: {$request->input('status')}",
            Garage::class,
            $garage->id,
            ['status' => $request->input('status')]
        );

        return back()->with('success', "Garage status updated to \"{$request->input('status')}\".");
    }

    public function destroy(Garage $garage)
    {
        $name = $garage->name;

        AdminActivityLog::record(
            'delete_garage',
            "Deleted garage: {$name}",
            Garage::class,
            $garage->id
        );

        $garage->delete();

        return redirect()->route('admin.garages.index')->with('success', "Garage \"{$name}\" has been deleted.");
    }

    private static function parseLocation(?string $mapsLink): array
    {
        if (! $mapsLink) {
            return [null, null];
        }
        $coords = \App\Services\LocationParser::fromMapsUrl($mapsLink);
        return $coords ? [$coords[0], $coords[1]] : [null, null];
    }
}
