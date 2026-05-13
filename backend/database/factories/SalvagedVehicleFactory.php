<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class SalvagedVehicleFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'      => User::factory()->state(['role' => 'yard_owner']),
            'brand'        => fake()->randomElement(['Toyota', 'Honda', 'BMW', 'Ford', 'Nissan']),
            'model'        => fake()->randomElement(['Camry', 'Civic', '3 Series', 'F-150', 'Altima']),
            'year'         => fake()->numberBetween(2000, 2023),
            'engine'       => '2.0L',
            'transmission' => fake()->randomElement(['Automatic', 'Manual']),
            'mileage'      => fake()->numberBetween(10000, 200000),
            'condition'    => fake()->randomElement(['Used', 'Damaged', 'Parts Only']),
            'description'  => fake()->sentence(12),
            'price'        => fake()->randomFloat(2, 500, 30000),
            'is_available' => true,
            'is_active'    => true,
        ];
    }
}
