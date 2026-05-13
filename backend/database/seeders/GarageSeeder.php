<?php

namespace Database\Seeders;

use App\Models\Garage;
use App\Models\User;
use Illuminate\Database\Seeder;

class GarageSeeder extends Seeder
{
    public function run(): void
    {
        $garageUser = User::where('role', 'garage')->first();
        if (! $garageUser) return;

        $garages = [
            [
                'name' => 'Fast Fit Auto Service – Seef',
                'description' => 'Quick and reliable auto service in the heart of Seef District. Specialising in tyres, brakes, oil changes and general maintenance.',
                'phone' => '+97317583000',
                'address' => 'Seef District, Manama, Bahrain',
                'latitude' => 26.2285,
                'longitude' => 50.5499,
                'services' => ['Tyre Change', 'Oil Change', 'Brake Service', 'Wheel Alignment', 'Battery Replacement'],
                'working_hours' => 'Sat–Thu: 7:30 AM – 10:00 PM',
                'rating' => 4.6,
                'review_count' => 312,
                'is_verified' => true,
            ],
            [
                'name' => 'Kanoo Motors Service Centre',
                'description' => 'Authorised multi-brand service centre with certified technicians and genuine parts. Serving Bahrain for over 40 years.',
                'phone' => '+97317255111',
                'address' => 'Al Khalifa Avenue, Manama, Bahrain',
                'latitude' => 26.2180,
                'longitude' => 50.5660,
                'services' => ['Full Service', 'Engine Diagnostics', 'Transmission', 'AC Service', 'Warranty Repairs'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 6:00 PM',
                'rating' => 4.7,
                'review_count' => 524,
                'is_verified' => true,
            ],
            [
                'name' => 'Al Naeem Auto Workshop',
                'description' => 'Trusted family-run garage in Adliya. Expert in European vehicles with over 20 years of experience.',
                'phone' => '+97317714488',
                'address' => 'Adliya, Manama, Bahrain',
                'latitude' => 26.2050,
                'longitude' => 50.5900,
                'services' => ['Engine Repair', 'Electrical Diagnostics', 'Suspension', 'Oil Change', 'Inspection'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 8:00 PM',
                'rating' => 4.4,
                'review_count' => 178,
                'is_verified' => true,
            ],
            [
                'name' => 'Speedy Auto Service – Riffa',
                'description' => 'Fast turnaround garage in Riffa serving the Southern Governorate. Walk-ins welcome.',
                'phone' => '+97317770022',
                'address' => 'Riffa, Southern Governorate, Bahrain',
                'latitude' => 26.1290,
                'longitude' => 50.5550,
                'services' => ['Tyre Rotation', 'Oil Change', 'Brake Pads', 'AC Gas Refill', 'Battery'],
                'working_hours' => 'Sat–Thu: 7:00 AM – 10:00 PM, Fri: 2:00 PM – 10:00 PM',
                'rating' => 4.3,
                'review_count' => 201,
                'is_verified' => false,
            ],
            [
                'name' => 'Gulf Star Motors – Muharraq',
                'description' => 'Full-service workshop in Muharraq with state-of-the-art equipment. Japanese and Korean vehicle specialists.',
                'phone' => '+97317322211',
                'address' => 'Muharraq, Bahrain',
                'latitude' => 26.2666,
                'longitude' => 50.6122,
                'services' => ['Engine Overhaul', 'Gearbox Repair', 'Body Work', 'Painting', 'Denting'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 9:00 PM',
                'rating' => 4.5,
                'review_count' => 143,
                'is_verified' => true,
            ],
            [
                'name' => 'Hamad Town Auto Centre',
                'description' => 'Convenient garage serving Hamad Town and surrounding areas. Competitive pricing with quality workmanship.',
                'phone' => '+97317681234',
                'address' => 'Hamad Town, Bahrain',
                'latitude' => 26.1090,
                'longitude' => 50.5090,
                'services' => ['General Maintenance', 'Oil Change', 'Tyre Service', 'Brake Service', 'Wheel Balancing'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 8:00 PM',
                'rating' => 4.1,
                'review_count' => 87,
                'is_verified' => false,
            ],
            [
                'name' => 'Seef Auto Experts',
                'description' => 'Specialised in luxury and high-performance vehicles. Authorised service for multiple premium brands.',
                'phone' => '+97317567890',
                'address' => 'Seef District, Manama, Bahrain',
                'latitude' => 26.2310,
                'longitude' => 50.5460,
                'services' => ['Full Detailing', 'Engine Tuning', 'Warranty Service', 'Ceramic Coating', 'PPF'],
                'working_hours' => 'Sat–Thu: 9:00 AM – 7:00 PM',
                'rating' => 4.9,
                'review_count' => 410,
                'is_verified' => true,
            ],
            [
                'name' => 'Isa Town Auto Services',
                'description' => 'Trusted neighbourhood garage in Isa Town. Quality service at fair prices for all vehicle types.',
                'phone' => '+97317456789',
                'address' => 'Isa Town, Central Governorate, Bahrain',
                'latitude' => 26.1736,
                'longitude' => 50.5301,
                'services' => ['Oil Change', 'Brake Service', 'Wheel Alignment', 'Engine Diagnostics', 'AC Service'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 8:00 PM',
                'rating' => 4.2,
                'review_count' => 95,
                'is_verified' => false,
            ],
            [
                'name' => 'Manama Auto Centre',
                'description' => 'Premier auto repair and maintenance in the heart of Manama. Specialised in European and Japanese vehicles.',
                'phone' => '+97317123456',
                'address' => 'Shaikh Khalifa Bin Salman Highway, Manama, Bahrain',
                'latitude' => 26.2154,
                'longitude' => 50.5832,
                'services' => ['Engine Repair', 'AC Service', 'Brake Service', 'Oil Change', 'Tyre Rotation'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 10:00 PM',
                'rating' => 4.8,
                'review_count' => 342,
                'is_verified' => true,
            ],
            [
                'name' => 'West Budaiya Auto Workshop',
                'description' => 'Serving the Budaiya and Jannusan communities. Honest, transparent pricing with no hidden fees.',
                'phone' => '+97317451122',
                'address' => 'Budaiya Highway, Budaiya, Bahrain',
                'latitude' => 26.2180,
                'longitude' => 50.4480,
                'services' => ['Full Service', 'Tyre Change', 'Suspension Repair', 'Electrical', 'Oil Change'],
                'working_hours' => 'Sat–Thu: 8:00 AM – 9:00 PM',
                'rating' => 4.3,
                'review_count' => 112,
                'is_verified' => false,
            ],
            [
                'name' => 'Juffair Quick Lube & Service',
                'description' => 'Express oil change and maintenance centre near the Juffair diplomatic area. No appointment needed.',
                'phone' => '+97317720033',
                'address' => 'Juffair, Manama, Bahrain',
                'latitude' => 26.1970,
                'longitude' => 50.5990,
                'services' => ['Express Oil Change', 'Tyre Inspection', 'Battery', 'Wiper Replacement', 'AC Check'],
                'working_hours' => 'Daily: 7:00 AM – 11:00 PM',
                'rating' => 4.0,
                'review_count' => 68,
                'is_verified' => false,
            ],
            [
                'name' => 'Al Muharraq Quick Fix',
                'description' => 'Fast and reliable auto service in Muharraq. Walk-ins welcome for basic services.',
                'phone' => '+97317345678',
                'address' => 'Muharraq Avenue, Muharraq, Bahrain',
                'latitude' => 26.2580,
                'longitude' => 50.6080,
                'services' => ['Oil Change', 'Battery Replacement', 'Tyre Change', 'Inspection', 'AC Gas Refill'],
                'working_hours' => 'Daily: 7:00 AM – 11:00 PM',
                'rating' => 4.3,
                'review_count' => 74,
                'is_verified' => false,
            ],
        ];

        foreach ($garages as $data) {
            Garage::firstOrCreate(
                ['name' => $data['name'], 'user_id' => $garageUser->id],
                [...$data, 'user_id' => $garageUser->id]
            );
        }
    }
}
