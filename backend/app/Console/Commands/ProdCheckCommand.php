<?php

namespace App\Console\Commands;

use App\Models\Setting;
use App\Models\User;
use App\Services\FeatureModuleService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ProdCheckCommand extends Command
{
    protected $signature = 'taxigo:prod-check
                            {--apply : Disable demo login module and set production-friendly defaults}';

    protected $description = 'Validate TaxiGo production readiness (WhatsApp, Firebase, payments, scheduler)';

    public function handle(FeatureModuleService $modules): int
    {
        $ok = true;
        $this->info('TaxiGo production checklist');
        $this->newLine();

        $checks = [
            'APP_KEY set' => ! empty(config('app.key')),
            'APP_DEBUG false in production' => ! app()->environment('production') || ! config('app.debug'),
            'APP_URL uses https in production' => ! app()->environment('production')
                || str_starts_with((string) config('app.url'), 'https://'),
            'Database configured' => config('database.default') !== null,
            'Firebase project id' => ! empty(config('taxigo.firebase.project_id')),
            'Firebase database URL' => ! empty(config('taxigo.firebase.database_url')),
            'Firebase credentials readable' => $this->credentialsReadable(),
            'Google Maps API key' => ! empty(config('taxigo.google_maps_api_key')),
            'SMS/WhatsApp driver not log (prod)' => ! app()->environment('production')
                || in_array(config('taxigo.sms.driver'), ['whatsapp', 'twilio', 'webhook'], true),
            'Twilio SID (if whatsapp/twilio)' => ! in_array(config('taxigo.sms.driver'), ['whatsapp', 'twilio'], true)
                || ! empty(config('taxigo.sms.twilio.sid')),
            'Twilio WhatsApp From (if whatsapp)' => config('taxigo.sms.driver') !== 'whatsapp'
                || ! empty(config('taxigo.sms.twilio.whatsapp_from'))
                || ! empty(config('taxigo.sms.twilio.from')),
            'Demo login disabled in production' => ! app()->environment('production')
                || $modules->disabled('demo_login'),
            'Super admin exists' => User::query()->where('role', 'super_admin')->exists(),
            'Card driver stub or configured iyzico' => config('taxigo.payments.driver') === 'stub'
                || (
                    ! empty(config('taxigo.payments.iyzico.api_key'))
                    && ! empty(config('taxigo.payments.iyzico.secret_key'))
                ),
        ];

        foreach ($checks as $label => $pass) {
            $this->line(($pass ? '[OK]  ' : '[!!] ').$label);
            if (! $pass) {
                $ok = false;
            }
        }

        $this->newLine();
        $this->line('Scheduler: run `php artisan schedule:work` (dev) or system cron/Task Scheduler:');
        $this->line('  * * * * * php '.base_path('artisan').' schedule:run');
        $this->line('Firebase rules: from /firebase → `firebase deploy --only database`');
        $this->newLine();

        if ($this->option('apply') && app()->environment('production')) {
            $modules->set('demo_login', false);
            Setting::setValue('modules.demo_login', '0', 'boolean', 'modules');
            $this->info('Applied: demo_login module disabled.');
        }

        return $ok ? self::SUCCESS : self::FAILURE;
    }

    protected function credentialsReadable(): bool
    {
        $path = config('taxigo.firebase.credentials');
        if (empty($path)) {
            return false;
        }

        if (! str_starts_with((string) $path, '/') && ! preg_match('/^[A-Za-z]:/', (string) $path)) {
            $candidates = [
                base_path($path),
                storage_path('app/'.ltrim((string) $path, '/')),
            ];
            foreach ($candidates as $candidate) {
                if (File::isReadable($candidate)) {
                    return true;
                }
            }

            return false;
        }

        return File::isReadable((string) $path);
    }
}
