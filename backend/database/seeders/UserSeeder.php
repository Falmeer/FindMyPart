<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Carbon;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin (web dashboard only — email login)
        User::updateOrCreate(
            ['email' => 'admin@findmypart.com'],
            [
                'name'      => 'Admin',
                'password'  => Hash::make('FMP#3003'),
                'role'      => 'admin',
                'is_active' => true,
            ]
        );

        $verified = Carbon::now();

        // Demo customer
        User::firstOrCreate(
            ['email' => 'customer@demo.com'],
            [
                'name'              => 'Ahmed Al-Rashid',
                'phone'             => '+966501234567',
                'phone_verified_at' => $verified,
                'password'          => Hash::make('password'),
                'role'              => 'customer',
                'is_active'         => true,
            ]
        );

        // Demo garage owner
        User::firstOrCreate(
            ['email' => 'garage@demo.com'],
            [
                'name'              => 'Mohammed Al-Garage',
                'phone'             => '+966509876543',
                'phone_verified_at' => $verified,
                'password'          => Hash::make('password'),
                'role'              => 'garage',
                'is_active'         => true,
            ]
        );

        // Demo yard owner
        User::firstOrCreate(
            ['email' => 'yard@demo.com'],
            [
                'name'              => 'Khalid Al-Yard',
                'phone'             => '+966505551234',
                'phone_verified_at' => $verified,
                'password'          => Hash::make('password'),
                'role'              => 'yard_owner',
                'is_active'         => true,
            ]
        );
    }
}
