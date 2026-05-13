<?php

namespace Tests\Feature;

use App\Models\Garage;
use App\Models\User;
use Tests\TestCase;

class GarageTest extends TestCase
{
    public function test_anyone_can_list_garages(): void
    {
        Garage::factory()->count(3)->create();

        $response = $this->getJson('/api/v1/garages');

        $response->assertStatus(200)
                 ->assertJsonPath('success', true)
                 ->assertJsonStructure(['data']);
    }

    public function test_anyone_can_view_a_garage(): void
    {
        $garage = Garage::factory()->create();

        $response = $this->getJson("/api/v1/garages/{$garage->id}");

        $response->assertStatus(200)
                 ->assertJsonPath('data.id', $garage->id);
    }

    public function test_unauthenticated_user_cannot_create_garage(): void
    {
        $response = $this->postJson('/api/v1/garages', [
            'name'    => 'My Garage',
            'address' => '123 Main St',
        ]);

        $response->assertStatus(401);
    }

    public function test_garage_user_can_create_garage(): void
    {
        $user = User::factory()->create(['role' => 'garage']);

        $response = $this->actingAs($user)->postJson('/api/v1/garages', [
            'name'        => 'Al-Noor Auto Service',
            'description' => 'Full car maintenance and repair services',
            'phone'       => '+966501234567',
            'address'     => '15 King Fahd Road, Riyadh',
            'latitude'    => 24.7136,
            'longitude'   => 46.6753,
            'services'    => ['oil_change', 'brake_service'],
            'type'        => 'garage',
        ]);

        $response->assertStatus(201)
                 ->assertJsonPath('success', true);

        $this->assertDatabaseHas('garages', [
            'name'    => 'Al-Noor Auto Service',
            'user_id' => $user->id,
        ]);
    }

    public function test_anyone_can_view_garage_reviews(): void
    {
        $garage = Garage::factory()->create();

        $response = $this->getJson("/api/v1/garages/{$garage->id}/reviews");

        $response->assertStatus(200)
                 ->assertJsonPath('success', true);
    }
}
