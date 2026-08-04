<?php

namespace Database\Seeders;

use App\Enums\DriverApprovalStatus;
use App\Enums\UserRole;
use App\Models\Driver;
use App\Models\FareTariff;
use App\Models\Setting;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\Wallet;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $admin = User::query()->updateOrCreate(
            ['email' => 'admin@taxigo.app'],
            [
                'name' => 'TaxiGo Super Admin',
                'password' => Hash::make('password'),
                'role' => UserRole::SuperAdmin,
                'locale' => 'tr',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
        );

        Wallet::query()->firstOrCreate(
            ['user_id' => $admin->id],
            ['balance' => 0, 'currency' => config('taxigo.currency', 'USD')],
        );

        $operator = User::query()->updateOrCreate(
            ['email' => 'ops@taxigo.app'],
            [
                'name' => 'Operasyon Admin',
                'password' => Hash::make('password'),
                'role' => UserRole::Admin,
                'locale' => 'tr',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
        );

        Wallet::query()->firstOrCreate(
            ['user_id' => $operator->id],
            ['balance' => 0, 'currency' => config('taxigo.currency', 'USD')],
        );

        $passengers = [
            ['name' => 'Ahmet Yolcu', 'phone' => '+905551000001', 'email' => 'ahmet@demo.taxigo.app'],
            ['name' => 'Ayşe Yolcu', 'phone' => '+905551000002', 'email' => 'ayse@demo.taxigo.app'],
            ['name' => 'Emre Yolcu', 'phone' => '+905551000003', 'email' => 'emre@demo.taxigo.app'],
        ];

        foreach ($passengers as $data) {
            $user = User::query()->updateOrCreate(
                ['phone' => $data['phone']],
                [
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'password' => Hash::make('password'),
                    'role' => UserRole::Passenger,
                    'locale' => 'tr',
                    'is_active' => true,
                    'email_verified_at' => now(),
                ],
            );
            Wallet::query()->firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 50, 'currency' => config('taxigo.currency', 'USD')],
            );
        }

        $drivers = [
            [
                'name' => 'Mehmet Şoför',
                'phone' => '+905552000001',
                'email' => 'mehmet@demo.taxigo.app',
                'plate' => '34 TG 01',
                'make' => 'Toyota',
                'model' => 'Corolla',
                'color' => 'Beyaz',
            ],
            [
                'name' => 'Can Şoför',
                'phone' => '+905552000002',
                'email' => 'can@demo.taxigo.app',
                'plate' => '34 TG 02',
                'make' => 'Volkswagen',
                'model' => 'Passat',
                'color' => 'Siyah',
            ],
            [
                'name' => 'Deniz Şoför',
                'phone' => '+905552000003',
                'email' => 'deniz@demo.taxigo.app',
                'plate' => '34 TG 03',
                'make' => 'Renault',
                'model' => 'Megane',
                'color' => 'Gri',
            ],
        ];

        foreach ($drivers as $data) {
            $user = User::query()->updateOrCreate(
                ['phone' => $data['phone']],
                [
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'password' => Hash::make('password'),
                    'role' => UserRole::Driver,
                    'locale' => 'tr',
                    'is_active' => true,
                    'email_verified_at' => now(),
                ],
            );

            Wallet::query()->firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 100, 'currency' => config('taxigo.currency', 'USD')],
            );

            $driver = Driver::query()->updateOrCreate(
                ['user_id' => $user->id],
                [
                    'approval_status' => DriverApprovalStatus::Approved,
                    'is_online' => false,
                    'rating_average' => 4.80,
                    'rating_count' => 40,
                    'total_rides' => 120,
                    'approved_at' => now(),
                    'current_latitude' => 41.0082,
                    'current_longitude' => 28.9784,
                ],
            );

            Vehicle::query()->updateOrCreate(
                ['driver_id' => $driver->id],
                [
                    'make' => $data['make'],
                    'model' => $data['model'],
                    'year' => 2022,
                    'color' => $data['color'],
                    'plate_number' => $data['plate'],
                    'vehicle_type' => 'standard',
                    'seats' => 4,
                    'is_active' => true,
                ],
            );
        }

        FareTariff::query()->updateOrCreate(
            ['name' => 'Standard', 'vehicle_type' => 'standard'],
            [
                'base_fare' => config('taxigo.fare.base_fare', 2.50),
                'per_km_rate' => config('taxigo.fare.per_km_rate', 1.20),
                'per_minute_rate' => config('taxigo.fare.per_minute_rate', 0.25),
                'minimum_fare' => config('taxigo.fare.minimum_fare', 5.00),
                'surge_multiplier' => 1.0,
                'currency' => config('taxigo.currency', 'USD'),
                'is_active' => true,
            ],
        );

        FareTariff::query()->updateOrCreate(
            ['name' => 'Comfort', 'vehicle_type' => 'comfort'],
            [
                'base_fare' => 3.50,
                'per_km_rate' => 1.60,
                'per_minute_rate' => 0.35,
                'minimum_fare' => 7.00,
                'surge_multiplier' => 1.0,
                'currency' => config('taxigo.currency', 'USD'),
                'is_active' => true,
            ],
        );

        FareTariff::query()->updateOrCreate(
            ['name' => 'Premium', 'vehicle_type' => 'premium'],
            [
                'base_fare' => 5.00,
                'per_km_rate' => 2.20,
                'per_minute_rate' => 0.45,
                'minimum_fare' => 10.00,
                'surge_multiplier' => 1.0,
                'currency' => config('taxigo.currency', 'USD'),
                'is_active' => true,
            ],
        );

        Setting::setValue(
            'commission_rate',
            config('taxigo.commission_rate', 0.15),
            'float',
            'billing',
        );

        Setting::setValue(
            'ride_expiry_minutes',
            config('taxigo.ride_expiry_minutes', 15),
            'integer',
            'rides',
        );

        Setting::setValue(
            'matching_radius_km',
            config('taxigo.matching.radius_km', 5.0),
            'float',
            'matching',
        );

        app(\App\Services\FeatureModuleService::class)->seedDefaults();
    }
}
