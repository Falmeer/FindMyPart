<?php

namespace Database\Seeders;

use App\Models\SalvagedVehicle;
use App\Models\User;
use Illuminate\Database\Seeder;

class SalvagedVehicleSeeder extends Seeder
{
    public function run(): void
    {
        $yardUser = User::where('role', 'yard_owner')->first();
        if (! $yardUser) return;

        $vehicles = [
            [
                'brand' => 'Toyota', 'model' => 'Camry', 'year' => 2019,
                'engine' => '2.5L 4-Cylinder', 'transmission' => 'Automatic',
                'mileage' => 145000, 'condition' => 'Damaged',
                'description' => 'Front-end collision damage. Engine and drivetrain in excellent condition. All rear parts available.',
                'price' => 8500,
            ],
            [
                'brand' => 'Honda', 'model' => 'Accord', 'year' => 2020,
                'engine' => '1.5L Turbo', 'transmission' => 'Automatic',
                'mileage' => 98000, 'condition' => 'Parts Only',
                'description' => 'Flooded vehicle. Perfect source for interior, electrical, and body parts.',
                'price' => 5000,
            ],
            [
                'brand' => 'BMW', 'model' => '520i', 'year' => 2018,
                'engine' => '2.0L Turbo', 'transmission' => 'Automatic',
                'mileage' => 210000, 'condition' => 'Used',
                'description' => 'Running and driving. Needs engine rebuild. Great for parts or full rebuild project.',
                'price' => 18000,
            ],
            [
                'brand' => 'Toyota', 'model' => 'Land Cruiser', 'year' => 2016,
                'engine' => '4.5L V8 Diesel', 'transmission' => 'Automatic',
                'mileage' => 320000, 'condition' => 'Used',
                'description' => 'High mileage Land Cruiser. Body in decent condition. All parts available separately.',
                'price' => 35000,
            ],
            [
                'brand' => 'Hyundai', 'model' => 'Tucson', 'year' => 2021,
                'engine' => '2.0L', 'transmission' => 'Automatic',
                'mileage' => 55000, 'condition' => 'Damaged',
                'description' => 'Side collision. Airbags deployed. Engine and major components undamaged.',
                'price' => 12000,
            ],
        ];

        foreach ($vehicles as $data) {
            SalvagedVehicle::firstOrCreate(
                ['brand' => $data['brand'], 'model' => $data['model'], 'year' => $data['year'], 'user_id' => $yardUser->id],
                [...$data, 'user_id' => $yardUser->id]
            );
        }
    }
}
