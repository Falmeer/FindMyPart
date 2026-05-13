<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ScrapyardFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'     => User::factory()->state(['role' => 'yard_owner']),
            'name'        => fake()->company() . ' Scrapyard',
            'description' => fake()->sentence(10),
            'phone'       => fake()->numerify('+973########'),
            'address'     => fake()->address(),
            'latitude'    => fake()->latitude(25, 27),
            'longitude'   => fake()->longitude(50, 51),
            'services'    => ['vehicle_parts', 'metal_recycling'],
            'is_verified' => true,
            'is_active'   => true,
        ];
    }
}
