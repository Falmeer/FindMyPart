<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\SparePart;
use App\Models\User;
use Illuminate\Database\Seeder;

class SparePartSeeder extends Seeder
{
    public function run(): void
    {
        $garageUser = User::where('role', 'garage')->first();
        if (! $garageUser) return;

        $engineCat = Category::where('slug', 'engine')->first();
        $brakesCat = Category::where('slug', 'brakes')->first();
        $electricalCat = Category::where('slug', 'electrical')->first();
        $suspensionCat = Category::where('slug', 'suspension')->first();

        $parts = [
            [
                'category_id' => $engineCat?->id ?? 1,
                'name' => 'Toyota Camry 2018-2022 Engine Oil Filter',
                'condition' => 'New',
                'price' => 35,
                'quantity' => 20,
                'description' => 'OEM quality engine oil filter for Toyota Camry 2018-2022 models. Easy installation.',
                'compatibility' => 'Toyota Camry 2018–2022',
                'has_warranty' => true,
            ],
            [
                'category_id' => $brakesCat?->id ?? 4,
                'name' => 'Honda Accord Front Brake Pads Set',
                'condition' => 'New',
                'price' => 120,
                'quantity' => 8,
                'description' => 'High performance ceramic brake pads for Honda Accord. Low dust, low noise.',
                'compatibility' => 'Honda Accord 2018–2023',
                'has_warranty' => true,
            ],
            [
                'category_id' => $electricalCat?->id ?? 6,
                'name' => 'BMW 5 Series Alternator',
                'condition' => 'Used',
                'price' => 650,
                'quantity' => 2,
                'description' => 'Tested and working alternator from BMW 520i 2018. Only 80,000 km.',
                'compatibility' => 'BMW 5 Series 2017–2020',
                'has_warranty' => false,
            ],
            [
                'category_id' => $suspensionCat?->id ?? 3,
                'name' => 'Toyota Corolla Shock Absorber — Rear Pair',
                'condition' => 'New',
                'price' => 280,
                'quantity' => 5,
                'description' => 'KYB Excel-G shock absorbers. Direct OEM replacement. Sold as pair.',
                'compatibility' => 'Toyota Corolla 2014–2019',
                'has_warranty' => true,
            ],
        ];

        foreach ($parts as $data) {
            SparePart::firstOrCreate(
                ['name' => $data['name'], 'user_id' => $garageUser->id],
                [...$data, 'user_id' => $garageUser->id]
            );
        }
    }
}
