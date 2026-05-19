<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\SparePart;
use App\Models\SparePartImage;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;

class SparePartSeeder extends Seeder
{
    public function run(): void
    {
        $garageUser = User::where('role', 'garage')->first();
        if (! $garageUser) return;

        $engineCat     = Category::where('slug', 'engine')->first();
        $brakesCat     = Category::where('slug', 'brakes')->first();
        $electricalCat = Category::where('slug', 'electrical')->first();
        $suspensionCat = Category::where('slug', 'suspension')->first();

        $parts = [
            [
                'category_id'   => $engineCat?->id ?? 1,
                'name'          => 'Toyota Camry 2018-2022 Engine Oil Filter',
                'condition'     => 'New',
                'price'         => 35,
                'quantity'      => 20,
                'description'   => 'OEM quality engine oil filter for Toyota Camry 2018-2022 models. Easy installation.',
                'compatibility' => 'Toyota Camry 2018–2022',
                'has_warranty'  => true,
                'images'        => [
                    'https://loremflickr.com/800/600/oil,filter,car',
                    'https://loremflickr.com/800/600/engine,oil,automotive',
                ],
            ],
            [
                'category_id'   => $brakesCat?->id ?? 4,
                'name'          => 'Honda Accord Front Brake Pads Set',
                'condition'     => 'New',
                'price'         => 120,
                'quantity'      => 8,
                'description'   => 'High performance ceramic brake pads for Honda Accord. Low dust, low noise.',
                'compatibility' => 'Honda Accord 2018–2023',
                'has_warranty'  => true,
                'images'        => [
                    'https://loremflickr.com/800/600/brake,pads,car',
                    'https://loremflickr.com/800/600/brake,disc,rotor',
                ],
            ],
            [
                'category_id'   => $electricalCat?->id ?? 6,
                'name'          => 'BMW 5 Series Alternator',
                'condition'     => 'Used',
                'price'         => 650,
                'quantity'      => 2,
                'description'   => 'Tested and working alternator from BMW 520i 2018. Only 80,000 km.',
                'compatibility' => 'BMW 5 Series 2017–2020',
                'has_warranty'  => false,
                'images'        => [
                    'https://loremflickr.com/800/600/alternator,car',
                    'https://loremflickr.com/800/600/car,engine,electrical',
                ],
            ],
            [
                'category_id'   => $suspensionCat?->id ?? 3,
                'name'          => 'Toyota Corolla Shock Absorber — Rear Pair',
                'condition'     => 'New',
                'price'         => 280,
                'quantity'      => 5,
                'description'   => 'KYB Excel-G shock absorbers. Direct OEM replacement. Sold as pair.',
                'compatibility' => 'Toyota Corolla 2014–2019',
                'has_warranty'  => true,
                'images'        => [
                    'https://loremflickr.com/800/600/shock,absorber,car',
                    'https://loremflickr.com/800/600/suspension,car,parts',
                ],
            ],
        ];

        foreach ($parts as $data) {
            $imageUrls = $data['images'];
            unset($data['images']);

            $part = SparePart::firstOrCreate(
                ['name' => $data['name'], 'user_id' => $garageUser->id],
                [...$data, 'user_id' => $garageUser->id]
            );

            if ($part->images()->count() === 0) {
                foreach ($imageUrls as $index => $sourceUrl) {
                    $filename = 'spare-parts/seeded-' . $part->id . '-' . $index . '.jpg';

                    if ($this->downloadImage($sourceUrl, $filename)) {
                        $url = url('api/v1/files/' . $filename);
                    } else {
                        $url = $sourceUrl;
                    }

                    SparePartImage::create([
                        'spare_part_id' => $part->id,
                        'path'          => $filename,
                        'url'           => $url,
                        'is_primary'    => $index === 0,
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
