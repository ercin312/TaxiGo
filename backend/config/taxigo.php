<?php

return [
    'support_email' => env('TAXIGO_SUPPORT_EMAIL', 'destek@taxigo.app'),
    'marketing_url' => env('TAXIGO_MARKETING_URL'),
    'google_maps_api_key' => env('GOOGLE_MAPS_API_KEY', env('TAXIGO_GOOGLE_MAPS_API_KEY')),
    'service_country' => env('TAXIGO_SERVICE_COUNTRY', 'me'),
    'default_latitude' => (float) env('TAXIGO_DEFAULT_LATITUDE', 42.4304),
    'default_longitude' => (float) env('TAXIGO_DEFAULT_LONGITUDE', 19.2594),
    'places_search_radius_meters' => (int) env('TAXIGO_PLACES_RADIUS', 150000),
    'currency' => env('TAXIGO_CURRENCY', 'EUR'),
    'demo_login' => (bool) env('TAXIGO_DEMO_LOGIN', true),
    'commission_rate' => (float) env('TAXIGO_COMMISSION_RATE', 0.15),
    'ride_expiry_minutes' => (int) env('TAXIGO_RIDE_EXPIRY_MINUTES', 15),
    'matching' => [
        'radius_km' => (float) env('TAXIGO_MATCHING_RADIUS_KM', 5),
        'max_drivers' => (int) env('TAXIGO_MATCHING_MAX_DRIVERS', 20),
    ],
    'wallet' => [
        'min_topup' => (float) env('TAXIGO_WALLET_MIN_TOPUP', 5),
        'min_withdrawal' => (float) env('TAXIGO_WALLET_MIN_WITHDRAWAL', 20),
        'topup_presets' => [5, 10, 20, 50, 100],
    ],
    'payments' => [
        // stub | iyzico — used by card capture and wallet top-up
        'driver' => env('TAXIGO_PAYMENTS_DRIVER', 'stub'),
        'iyzico' => [
            'api_key' => env('IYZICO_API_KEY'),
            'secret_key' => env('IYZICO_SECRET_KEY'),
            'base_url' => env('IYZICO_BASE_URL', 'https://sandbox-api.iyzipay.com'),
        ],
    ],
    'comms' => [
        'masked_call' => [
            // stub | twilio
            'driver' => env('TAXIGO_MASKED_CALL_DRIVER', 'stub'),
            // Optional E.164 proxy number for stub dial (never exposes real numbers in UI)
            'proxy_number' => env('TAXIGO_MASKED_CALL_PROXY'),
            'twilio' => [
                'account_sid' => env('TWILIO_ACCOUNT_SID'),
                'auth_token' => env('TWILIO_AUTH_TOKEN'),
                'proxy_service_sid' => env('TWILIO_PROXY_SERVICE_SID'),
                'proxy_number' => env('TWILIO_PROXY_NUMBER'),
            ],
        ],
    ],
    'company' => [
        'name' => env('TAXIGO_COMPANY_NAME', 'TaxiGo Montenegro'),
        'address' => env('TAXIGO_COMPANY_ADDRESS', 'Podgorica, Montenegro'),
        'tax_id' => env('TAXIGO_COMPANY_TAX_ID'),
        'email' => env('TAXIGO_COMPANY_EMAIL', env('TAXIGO_SUPPORT_EMAIL', 'destek@taxigo.app')),
        'phone' => env('TAXIGO_COMPANY_PHONE'),
    ],
];
