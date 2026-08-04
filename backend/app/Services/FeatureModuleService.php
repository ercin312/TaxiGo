<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Cache;

class FeatureModuleService
{
    public const CACHE_KEY = 'taxigo.feature_modules';

    /**
     * Registry of modular product features (Super Admin controlled).
     *
     * @return array<string, array{label: string, description: string, category: string, default: bool}>
     */
    public function definitions(): array
    {
        return [
            'otp_login' => [
                'label' => 'OTP / WhatsApp Login',
                'description' => 'Phone OTP login via WhatsApp, SMS, webhook or log driver.',
                'category' => 'auth',
                'default' => true,
            ],
            'demo_login' => [
                'label' => 'Demo Login',
                'description' => 'Passwordless demo login without OTP (dev / staging).',
                'category' => 'auth',
                'default' => ! app()->environment('production')
                    && (bool) config('taxigo.demo_login', true),
            ],
            'directions_fare' => [
                'label' => 'Directions Fare / ETA',
                'description' => 'Use Google Directions for road distance, duration and fare.',
                'category' => 'maps',
                'default' => true,
            ],
            'places_autocomplete' => [
                'label' => 'Places Autocomplete',
                'description' => 'Google Places search and place details for addresses.',
                'category' => 'maps',
                'default' => true,
            ],
            'ride_settlement' => [
                'label' => 'Ride Settlement',
                'description' => 'Wallet debit / driver earning on ride complete.',
                'category' => 'payments',
                'default' => true,
            ],
            'card_payments' => [
                'label' => 'Card Payments',
                'description' => 'Allow card payment method (stub / iyzico driver).',
                'category' => 'payments',
                'default' => true,
            ],
            'withdrawals' => [
                'label' => 'Driver Withdrawals',
                'description' => 'Drivers can request wallet withdrawals from the app.',
                'category' => 'payments',
                'default' => true,
            ],
            'rtdb_sync' => [
                'label' => 'Realtime Tracking (RTDB)',
                'description' => 'Sync rides to Firebase Realtime Database.',
                'category' => 'realtime',
                'default' => true,
            ],
            'fcm_dispatch' => [
                'label' => 'FCM Ride Dispatch',
                'description' => 'Push new ride requests to nearby drivers with sound.',
                'category' => 'realtime',
                'default' => true,
            ],
            'sos_alerts' => [
                'label' => 'SOS Alerts',
                'description' => 'Emergency SOS with admin/driver push and webhook.',
                'category' => 'safety',
                'default' => true,
            ],
            'share_trip' => [
                'label' => 'Share Trip',
                'description' => 'Public live trip share link for passengers.',
                'category' => 'safety',
                'default' => true,
            ],
            'ride_expiry' => [
                'label' => 'Ride Expiry Job',
                'description' => 'Auto-expire pending rides past expires_at.',
                'category' => 'rides',
                'default' => true,
            ],
            'bidding' => [
                'label' => 'Ride Bidding',
                'description' => 'Passenger offer / driver counter-bid flow.',
                'category' => 'rides',
                'default' => true,
            ],
        ];
    }

    public function enabled(string $key, ?bool $fallback = null): bool
    {
        $definitions = $this->definitions();
        if (! isset($definitions[$key])) {
            return $fallback ?? false;
        }

        $default = $fallback ?? (bool) $definitions[$key]['default'];

        return (bool) Setting::getValue($this->settingKey($key), $default);
    }

    public function disabled(string $key): bool
    {
        return ! $this->enabled($key);
    }

    /**
     * @return array<string, bool>
     */
    public function flags(): array
    {
        return Cache::remember(self::CACHE_KEY, 300, function () {
            $flags = [];
            foreach ($this->definitions() as $key => $meta) {
                $flags[$key] = $this->enabled($key);
            }

            return $flags;
        });
    }

    /**
     * @return list<array{key: string, label: string, description: string, category: string, enabled: bool, default: bool}>
     */
    public function catalog(): array
    {
        $items = [];
        foreach ($this->definitions() as $key => $meta) {
            $items[] = [
                'key' => $key,
                'label' => $meta['label'],
                'description' => $meta['description'],
                'category' => $meta['category'],
                'enabled' => $this->enabled($key),
                'default' => (bool) $meta['default'],
            ];
        }

        return $items;
    }

    public function set(string $key, bool $enabled): void
    {
        if (! isset($this->definitions()[$key])) {
            throw new \InvalidArgumentException("Unknown module: {$key}");
        }

        Setting::setValue($this->settingKey($key), $enabled ? '1' : '0', 'boolean', 'modules');
        $this->forgetCache();
    }

    /**
     * @param  array<string, bool>  $modules
     */
    public function sync(array $modules): void
    {
        foreach ($modules as $key => $enabled) {
            if (! isset($this->definitions()[$key])) {
                continue;
            }
            Setting::setValue(
                $this->settingKey((string) $key),
                filter_var($enabled, FILTER_VALIDATE_BOOLEAN) ? '1' : '0',
                'boolean',
                'modules',
            );
        }

        $this->forgetCache();
    }

    public function seedDefaults(bool $force = false): void
    {
        foreach ($this->definitions() as $key => $meta) {
            $settingKey = $this->settingKey($key);
            if (! $force && Setting::query()->where('key', $settingKey)->exists()) {
                continue;
            }
            Setting::setValue(
                $settingKey,
                $meta['default'] ? '1' : '0',
                'boolean',
                'modules',
            );
        }

        $this->forgetCache();
    }

    public function forgetCache(): void
    {
        Cache::forget(self::CACHE_KEY);
        foreach (array_keys($this->definitions()) as $key) {
            Cache::forget('setting.'.$this->settingKey($key));
        }
    }

    public function settingKey(string $key): string
    {
        return 'modules.'.$key;
    }
}
