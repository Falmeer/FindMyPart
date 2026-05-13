<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\SparePart;
use App\Models\User;
use Tests\TestCase;

class SparePartTest extends TestCase
{
    public function test_anyone_can_list_spare_parts(): void
    {
        SparePart::factory()->count(3)->create();

        $response = $this->getJson('/api/v1/spare-parts');

        $response->assertStatus(200)
                 ->assertJsonPath('success', true)
                 ->assertJsonStructure(['data']);
    }

    public function test_anyone_can_view_a_spare_part(): void
    {
        $part = SparePart::factory()->create();

        $response = $this->getJson("/api/v1/spare-parts/{$part->id}");

        $response->assertStatus(200)
                 ->assertJsonPath('data.id', $part->id);
    }

    public function test_yard_owner_can_create_spare_part(): void
    {
        $user     = User::factory()->create(['role' => 'yard_owner']);
        $category = Category::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/spare-parts', [
            'category_id' => $category->id,
            'name'        => 'Brake Pad Set',
            'condition'   => 'New',
            'price'       => 120.00,
            'quantity'    => 5,
            'description' => 'High quality brake pads for Toyota Camry',
        ]);

        $response->assertStatus(201)
                 ->assertJsonPath('success', true);

        $this->assertDatabaseHas('spare_parts', [
            'name'    => 'Brake Pad Set',
            'user_id' => $user->id,
        ]);
    }

    public function test_unauthenticated_user_cannot_create_spare_part(): void
    {
        $category = Category::factory()->create();

        $response = $this->postJson('/api/v1/spare-parts', [
            'category_id' => $category->id,
            'name'        => 'Brake Pad Set',
            'condition'   => 'New',
            'price'       => 120.00,
            'description' => 'High quality brake pads',
        ]);

        $response->assertStatus(401);
    }

    public function test_any_authenticated_user_can_create_spare_part(): void
    {
        $user     = User::factory()->create(['role' => 'customer']);
        $category = Category::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/spare-parts', [
            'category_id' => $category->id,
            'name'        => 'Brake Pad Set',
            'condition'   => 'New',
            'price'       => 120.00,
            'quantity'    => 2,
            'description' => 'High quality brake pads for Toyota Camry',
        ]);

        $response->assertStatus(201)
                 ->assertJsonPath('success', true);
    }

    public function test_owner_can_delete_spare_part(): void
    {
        $user = User::factory()->create(['role' => 'yard_owner']);
        $part = SparePart::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user)->deleteJson("/api/v1/spare-parts/{$part->id}");

        $response->assertStatus(200);
        $this->assertSoftDeleted('spare_parts', ['id' => $part->id]);
    }
}
