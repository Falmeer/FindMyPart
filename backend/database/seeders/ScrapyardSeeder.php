<?php

namespace Database\Seeders;

use App\Models\Scrapyard;
use App\Models\User;
use Illuminate\Database\Seeder;

class ScrapyardSeeder extends Seeder
{
    public function run(): void
    {
        $yardUser = User::where('role', 'yard_owner')->first();
        if (! $yardUser) return;

        $scrapyards = [
            [
                'name' => 'Salmabad Auto Parts Market',
                'description' => 'Bahrain\'s largest used auto parts market. Hundreds of vehicles dismantled for spare parts covering all makes and models.',
                'phone' => '+97317624400',
                'address' => 'Salmabad Industrial Area, Bahrain',
                'latitude' => 26.1620,
                'longitude' => 50.5330,
                'services' => ['Used Engines', 'Gearboxes', 'Body Panels', 'Electrical Parts', 'Interior Parts'],
                'working_hours' => 'Sat–Thu: 7:00 AM – 6:00 PM',
                'rating' => 4.4,
                'review_count' => 630,
                'is_verified' => true,
            ],
            [
                'name' => 'Al Wusta Used Spare Parts',
                'description' => 'Specialised in Japanese and Korean vehicle parts. All parts tested and guaranteed for 30 days.',
                'phone' => '+97317627711',
                'address' => 'Salmabad, Central Governorate, Bahrain',
                'latitude' => 26.1680,
                'longitude' => 50.5370,
                'services' => ['Toyota Parts', 'Honda Parts', 'Nissan Parts', 'Hyundai Parts', 'Kia Parts'],
                'working_hours' => 'Sat–Thu: 7:30 AM – 5:30 PM',
                'rating' => 4.2,
                'review_count' => 218,
                'is_verified' => true,
            ],
            [
                'name' => 'Gulf Used Cars & Parts',
                'description' => 'Large salvage yard with over 500 vehicles. We buy accident and non-runner vehicles and sell parts at wholesale prices.',
                'phone' => '+97317628833',
                'address' => 'Salmabad, Bahrain',
                'latitude' => 26.1600,
                'longitude' => 50.5280,
                'services' => ['Vehicle Purchase', 'Engine Parts', 'Suspension Parts', 'Doors & Panels', 'Glass'],
                'working_hours' => 'Sat–Thu: 7:00 AM – 6:00 PM',
                'rating' => 4.0,
                'review_count' => 145,
                'is_verified' => false,
            ],
            [
                'name' => 'Al Zayani Auto Recycling',
                'description' => 'European vehicle specialists. BMW, Mercedes, Audi and Volkswagen recycled parts at a fraction of original cost.',
                'phone' => '+97317633399',
                'address' => 'Salmabad Industrial Area, Bahrain',
                'latitude' => 26.1720,
                'longitude' => 50.5400,
                'services' => ['BMW Parts', 'Mercedes Parts', 'Audi Parts', 'VW Parts', 'Land Rover Parts'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 6:00 PM',
                'rating' => 4.5,
                'review_count' => 189,
                'is_verified' => true,
            ],
            [
                'name' => 'Bahrain Car Parts Centre',
                'description' => 'General used parts dealer. Largest stock of American vehicle parts in Bahrain including GM, Ford and Dodge.',
                'phone' => '+97317620055',
                'address' => 'Salmabad, Bahrain',
                'latitude' => 26.1550,
                'longitude' => 50.5310,
                'services' => ['GM Parts', 'Ford Parts', 'Dodge Parts', 'Jeep Parts', 'Chevrolet Parts'],
                'working_hours' => 'Sat–Thu: 7:00 AM – 5:00 PM',
                'rating' => 4.1,
                'review_count' => 97,
                'is_verified' => false,
            ],
            [
                'name' => 'Hidd Auto Recycling',
                'description' => 'Industrial-scale vehicle recycling in the Hidd area. Supplying workshops across Bahrain with quality second-hand parts.',
                'phone' => '+97317342200',
                'address' => 'Hidd Industrial Area, Muharraq, Bahrain',
                'latitude' => 26.2400,
                'longitude' => 50.6450,
                'services' => ['Bulk Parts', 'Fleet Vehicles', 'Engines', 'Axles', 'Differentials'],
                'working_hours' => 'Sat–Thu: 7:00 AM – 5:00 PM',
                'rating' => 4.0,
                'review_count' => 73,
                'is_verified' => false,
            ],
            [
                'name' => 'Sitra Used Parts & Scrap',
                'description' => 'Family-run scrapyard in Sitra serving the Eastern coast of Bahrain. Competitive cash-for-cars service available.',
                'phone' => '+97317735544',
                'address' => 'Sitra, Bahrain',
                'latitude' => 26.1550,
                'longitude' => 50.6070,
                'services' => ['Cash for Cars', 'Used Parts', 'Tyres', 'Rims', 'Batteries'],
                'working_hours' => 'Sat–Thu: 7:30 AM – 5:30 PM',
                'rating' => 3.9,
                'review_count' => 54,
                'is_verified' => false,
            ],
            [
                'name' => 'Al Rifaa Used Auto Parts',
                'description' => 'Convenient parts yard serving Riffa and the Southern Governorate. SUV and 4x4 parts specialists.',
                'phone' => '+97317779966',
                'address' => 'Riffa, Southern Governorate, Bahrain',
                'latitude' => 26.1200,
                'longitude' => 50.5480,
                'services' => ['SUV Parts', '4x4 Parts', 'Used Tyres', 'Rims', 'Suspension'],
                'working_hours' => 'Sat–Thu: 7:00 AM – 6:00 PM',
                'rating' => 4.1,
                'review_count' => 88,
                'is_verified' => false,
            ],
        ];

        foreach ($scrapyards as $data) {
            Scrapyard::firstOrCreate(
                ['name' => $data['name'], 'user_id' => $yardUser->id],
                [...$data, 'user_id' => $yardUser->id]
            );
        }
    }
}
