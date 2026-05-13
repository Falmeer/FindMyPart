<?php

namespace Tests\Feature;

use App\Models\SalvagedVehicle;
use App\Models\User;
use Tests\TestCase;

class VehicleTest extends TestCase
{
    public function test_anyone_can_list_vehicles(): void
    {
        SalvagedVehicle::factory()->count(3)->create();

        $response = $this->getJson('/api/v1/vehicles');

        $response->assertStatus(200)
                 ->assertJsonPath('success', true)
                 ->assertJsonStructure(['data']);
    }

    public function test_anyone_can_view_a_vehicle(): void
    {
        $vehicle = SalvagedVehicle::factory()->create();

        $response = $this->getJson("/api/v1/vehicles/{$vehicle->id}");

        $response->assertStatus(200)
                 ->assertJsonPath('success', true)
                 ->assertJsonPath('data.id', $vehicle->id);
    }

    public function test_yard_owner_can_create_vehicle(): void
    {
        $user = User::factory()->create(['role' => 'yard_owner']);

        $response = $this->actingAs($user)->postJson('/api/v1/vehicles', [
            'brand'       => 'Toyota',
            'model'       => 'Camry',
            'year'        => 2018,
            'condition'   => 'Used',
            'description' => 'Good condition vehicle with minor scratches',
            'price'       => 15000,
        ]);

        $response->assertStatus(201)
                 ->assertJsonPath('success', true);

        $this->assertDatabaseHas('salvaged_vehicles', [
            'brand'   => 'Toyota',
            'user_id' => $user->id,
        ]);
    }

    public function test_customer_cannot_create_vehicle(): void
    {
        $user = User::factory()->create(['role' => 'customer']);

        $response = $this->actingAs($user)->postJson('/api/v1/vehicles', [
            'brand'       => 'Toyota',
            'model'       => 'Camry',
            'year'        => 2018,
            'condition'   => 'Used',
            'description' => 'Good condition vehicle with minor scratches',
        ]);

        $response->assertStatus(403);
    }

    public function test_unauthenticated_user_cannot_create_vehicle(): void
    {
        $response = $this->postJson('/api/v1/vehicles', [
            'brand' => 'Toyota',
            'model' => 'Camry',
            'year'  => 2018,
        ]);

        $response->assertStatus(401);
    }

    public function test_owner_can_delete_vehicle(): void
    {
        $user    = User::factory()->create(['role' => 'yard_owner']);
        $vehicle = SalvagedVehicle::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user)->deleteJson("/api/v1/vehicles/{$vehicle->id}");

        $response->assertStatus(200);
        $this->assertSoftDeleted('salvaged_vehicles', ['id' => $vehicle->id]);
    }

    public function test_non_owner_cannot_delete_vehicle(): void
    {
        $owner   = User::factory()->create(['role' => 'yard_owner']);
        $other   = User::factory()->create(['role' => 'yard_owner']);
        $vehicle = SalvagedVehicle::factory()->create(['user_id' => $owner->id]);

        $response = $this->actingAs($other)->deleteJson("/api/v1/vehicles/{$vehicle->id}");

        $response->assertStatus(403);
    }

    public function test_vehicle_search_returns_matching_results(): void
    {
        SalvagedVehicle::factory()->create(['brand' => 'Toyota']);
        SalvagedVehicle::factory()->create(['brand' => 'Honda']);

        $response = $this->getJson('/api/v1/vehicles?search=Toyota');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertTrue(collect($data)->every(fn($v) => str_contains($v['brand'], 'Toyota')));
    }
}
