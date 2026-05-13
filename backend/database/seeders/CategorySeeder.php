<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Engine', 'slug' => 'engine', 'icon' => 'settings'],
            ['name' => 'Transmission', 'slug' => 'transmission', 'icon' => 'alt_route'],
            ['name' => 'Suspension', 'slug' => 'suspension', 'icon' => 'compress'],
            ['name' => 'Brakes', 'slug' => 'brakes', 'icon' => 'disc_full'],
            ['name' => 'AC', 'slug' => 'ac', 'icon' => 'ac_unit'],
            ['name' => 'Electrical', 'slug' => 'electrical', 'icon' => 'electric_bolt'],
            ['name' => 'Interior', 'slug' => 'interior', 'icon' => 'chair'],
            ['name' => 'Exterior', 'slug' => 'exterior', 'icon' => 'car_crash'],
            ['name' => 'Tires', 'slug' => 'tires', 'icon' => 'tire_repair'],
            ['name' => 'Electronics', 'slug' => 'electronics', 'icon' => 'devices'],
            ['name' => 'Cooling', 'slug' => 'cooling', 'icon' => 'waves'],
            ['name' => 'Exhaust', 'slug' => 'exhaust', 'icon' => 'cloud'],
            ['name' => 'Lighting', 'slug' => 'lighting', 'icon' => 'light'],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(['slug' => $category['slug']], $category);
        }
    }
}
