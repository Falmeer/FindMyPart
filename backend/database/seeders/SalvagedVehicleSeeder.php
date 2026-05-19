<?php

namespace Database\Seeders;

use App\Models\SalvagedVehicle;
use App\Models\VehicleImage;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;

class SalvagedVehicleSeeder extends Seeder
{
    public function run(): void
    {
        $yardUser = User::where('role', 'yard_owner')->first();
        if (! $yardUser) return;

        $vehicles = [
            [
                'brand'        => 'Toyota',
                'model'        => 'Camry',
                'year'         => 2019,
                'engine'       => '2.5L 4-Cylinder',
                'transmission' => 'Automatic',
                'mileage'      => 145000,
                'condition'    => 'Damaged',
                'description'  => 'Front-end collision damage. Engine and drivetrain in excellent condition. All rear parts available.',
                'price'        => 8500,
                'images'       => [
                    'https://loremflickr.com/800/600/car,accident,crashed',
                    'https://loremflickr.com/800/600/wrecked,car,damage',
                ],
            ],
            [
                'brand'        => 'Honda',
                'model'        => 'Accord',
                'year'         => 2020,
                'engine'       => '1.5L Turbo',
                'transmission' => 'Automatic',
                'mileage'      => 98000,
                'condition'    => 'Parts Only',
                'description'  => 'Flooded vehicle. Perfect source for interior, electrical, and body parts.',
                'price'        => 5000,
                'images'       => [
                    'https://loremflickr.com/800/600/junkyard,car',
                    'https://loremflickr.com/800/600/scrapyard,automobile',
                ],
            ],
            [
                'brand'        => 'BMW',
                'model'        => '520i',
                'year'         => 2018,
                'engine'       => '2.0L Turbo',
                'transmission' => 'Automatic',
                'mileage'      => 210000,
                'condition'    => 'Used',
                'description'  => 'Running and driving. Needs engine rebuild. Great for parts or full rebuild project.',
                'price'        => 18000,
                'images'       => [
                    'https://loremflickr.com/800/600/bmw,car',
                    'https://loremflickr.com/800/600/car,engine,repair',
                    'https://loremflickr.com/800/600/luxury,sedan,car',
                ],
            ],
            [
                'brand'        => 'Toyota',
                'model'        => 'Land Cruiser',
                'year'         => 2016,
                'engine'       => '4.5L V8 Diesel',
                'transmission' => 'Automatic',
                'mileage'      => 320000,
                'condition'    => 'Used',
                'description'  => 'High mileage Land Cruiser. Body in decent condition. All parts available separately.',
                'price'        => 35000,
                'images'       => [
                    'https://loremflickr.com/800/600/toyota,suv,4x4',
                    'https://loremflickr.com/800/600/offroad,vehicle',
                ],
            ],
            [
                'brand'        => 'Hyundai',
                'model'        => 'Tucson',
                'year'         => 2021,
                'engine'       => '2.0L',
                'transmission' => 'Automatic',
                'mileage'      => 55000,
                'condition'    => 'Damaged',
                'description'  => 'Side collision. Airbags deployed. Engine and major components undamaged.',
                'price'        => 12000,
                'images'       => [
                    'https://loremflickr.com/800/600/car,damaged,collision',
                    'https://loremflickr.com/800/600/suv,accident,crash',
                ],
            ],
        ];

        foreach ($vehicles as $data) {
            $imageUrls = $data['images'];
            unset($data['images']);

            $vehicle = SalvagedVehicle::firstOrCreate(
                ['brand' => $data['brand'], 'model' => $data['model'], 'year' => $data['year'], 'user_id' => $yardUser->id],
                [...$data, 'user_id' => $yardUser->id]
            );

            if ($vehicle->images()->count() === 0) {
                foreach ($imageUrls as $index => $sourceUrl) {
                    $filename = 'vehicles/seeded-' . $vehicle->id . '-' . $index . '.jpg';

                    if ($this->downloadImage($sourceUrl, $filename)) {
                        $url = url('api/v1/files/' . $filename);
                    } else {
                        $url = $sourceUrl;
                    }

                    VehicleImage::create([
                        'salvaged_vehicle_id' => $vehicle->id,
                        'path'                => $filename,
                        'url'                 => $url,
                        'is_primary'          => $index === 0,
                    ]);
                }
            }
        }
    }

    private function downloadImage(string $url, string $storagePath): bool
    {
        try {
            $context = stream_context_create(['http' => ['timeout' => 15, 'follow_location' => true]]);
            $content = @file_get_contents($url, false, $context);
            if ($content === false || strlen($content) < 1000) return false;
            Storage::disk('public')->put($storagePath, $content);
            return true;
        } catch (\Throwable) {
            return false;
        }
    }
}
