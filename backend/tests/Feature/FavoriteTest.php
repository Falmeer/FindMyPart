<?php

namespace Tests\Feature;

use App\Models\Favorite;
use App\Models\Garage;
use App\Models\SalvagedVehicle;
use App\Models\User;
use Tests\TestCase;

class FavoriteTest extends TestCase
{
    public function test_authenticated_user_can_favorite_a_vehicle(): void
    {
        $user    = User::factory()->create(['role' => 'customer']);
        $vehicle = SalvagedVehicle::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/favorites/toggle', [
            'type' => 'vehicle',
            'id'   => $vehicle->id,
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('success', true)
                 ->assertJsonPath('favorited', true);

        $this->assertDatabaseHas('favorites', [
            'user_id'        => $user->id,
            'favoritable_id' => $vehicle->id,
        ]);
    }

    public function test_toggling_favorite_twice_removes_it(): void
    {
        $user    = User::factory()->create(['role' => 'customer']);
        $vehicle = SalvagedVehicle::factory()->create();

        $this->actingAs($user)->postJson('/api/v1/favorites/toggle', [
            'type' => 'vehicle',
            'id'   => $vehicle->id,
        ]);

        $response = $this->actingAs($user)->postJson('/api/v1/favorites/toggle', [
            'type' => 'vehicle',
            'id'   => $vehicle->id,
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('favorited', false);

        $this->assertDatabaseMissing('favorites', [
            'user_id'        => $user->id,
            'favoritable_id' => $vehicle->id,
        ]);
    }

    public function test_unauthenticated_user_cannot_favorite(): void
    {
        $vehicle = SalvagedVehicle::factory()->create();

        $response = $this->postJson('/api/v1/favorites/toggle', [
            'type' => 'vehicle',
            'id'   => $vehicle->id,
        ]);

        $response->assertStatus(401);
    }

    public function test_user_can_list_their_favorites(): void
    {
        $user    = User::factory()->create(['role' => 'customer']);
        $vehicle = SalvagedVehicle::factory()->create();

        Favorite::create([
            'user_id'          => $user->id,
            'favoritable_type' => SalvagedVehicle::class,
            'favoritable_id'   => $vehicle->id,
        ]);

        $response = $this->actingAs($user)->getJson('/api/v1/favorites');

        $response->assertStatus(200)
                 ->assertJsonPath('success', true);

        $this->assertCount(1, $response->json('data'));
    }

    public function test_user_can_favorite_a_garage(): void
    {
        $user   = User::factory()->create(['role' => 'customer']);
        $garage = Garage::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/favorites/toggle', [
            'type' => 'garage',
            'id'   => $garage->id,
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('favorited', true);
    }

    public function test_invalid_favorite_type_is_rejected(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/favorites/toggle', [
            'type' => 'unknown',
            'id'   => 1,
        ]);

        $response->assertStatus(422);
    }
}
