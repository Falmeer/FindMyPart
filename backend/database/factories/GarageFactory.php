<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class GarageFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'     => User::factory()->state(['role' => 'garage']),
            'name'        => fake()->company() . ' Garage',
            'description' => fake()->sentence(10),
            'phone'       => fake()->numerify('+966#########'),
            'address'     => fake()->address(),
            'latitude'    => fake()->latitude(20, 30),
            'longitude'   => fake()->longitude(38, 56),
            'services'    => ['oil_change', 'tire_rotation'],
            'is_verified' => true,
            'is_active'   => true,
        ];
    }
}
