<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class SparePartFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id'       => User::factory()->state(['role' => 'yard_owner']),
            'category_id'   => Category::factory(),
            'name'          => fake()->words(3, true) . ' part',
            'condition'     => fake()->randomElement(['New', 'Used', 'Refurbished']),
            'price'         => fake()->randomFloat(2, 10, 2000),
            'quantity'      => fake()->numberBetween(1, 50),
            'description'   => fake()->sentence(12),
            'compatibility' => 'Toyota Camry 2018–2022',
            'has_warranty'  => false,
            'is_active'     => true,
        ];
    }
}
