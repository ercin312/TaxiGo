<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SmsOtpService
{
    public function sendOtp(string $phone, string $code): bool
    {
        $driver = config('taxigo.sms.driver', 'log');

        return match ($driver) {
            'whatsapp' => $this->sendViaTwilioWhatsApp($phone, $code),
            'twilio' => $this->sendViaTwilio($phone, $code),
            'webhook' => $this->sendViaWebhook($phone, $code),
            default => $this->sendViaLog($phone, $code),
        };
    }

    public function channel(): string
    {
        return match (config('taxigo.sms.driver', 'log')) {
            'whatsapp' => 'whatsapp',
            'twilio' => 'sms',
            'webhook' => 'webhook',
            default => 'log',
        };
    }

    protected function sendViaLog(string $phone, string $code): bool
    {
        Log::info('SMS OTP (log driver)', [
            'phone' => $this->maskPhone($phone),
            'code_length' => strlen($code),
            'hint' => app()->environment('local') ? $code : 'hidden',
        ]);

        return true;
    }

    protected function sendViaTwilio(string $phone, string $code): bool
    {
        return $this->sendTwilioMessage(
            to: $phone,
            body: $this->otpBody($code),
            from: config('taxigo.sms.twilio.from'),
            label: 'Twilio SMS',
        );
    }

    protected function sendViaTwilioWhatsApp(string $phone, string $code): bool
    {
        $from = config('taxigo.sms.twilio.whatsapp_from')
            ?: config('taxigo.sms.twilio.from');

        if (empty($from)) {
            Log::warning('Twilio WhatsApp From not configured');

            return false;
        }

        if (! str_starts_with($from, 'whatsapp:')) {
            $from = 'whatsapp:'.$from;
        }

        $to = str_starts_with($phone, 'whatsapp:') ? $phone : 'whatsapp:'.$phone;

        return $this->sendTwilioMessage(
            to: $to,
            body: $this->otpBody($code),
            from: $from,
            label: 'Twilio WhatsApp',
        );
    }

    protected function otpBody(string $code): string
    {
        return str_replace(
            ':code',
            $code,
            config('taxigo.sms.message', 'TaxiGo login code: :code')
        );
    }

    protected function sendTwilioMessage(
        string $to,
        string $body,
        ?string $from,
        string $label,
    ): bool {
        $sid = config('taxigo.sms.twilio.sid');
        $token = config('taxigo.sms.twilio.token');

        if (empty($sid) || empty($token) || empty($from)) {
            Log::warning("{$label} not configured");

            return false;
        }

        $response = Http::withBasicAuth($sid, $token)
            ->asForm()
            ->post("https://api.twilio.com/2010-04-01/Accounts/{$sid}/Messages.json", [
                'From' => $from,
                'To' => $to,
                'Body' => $body,
            ]);

        if ($response->failed()) {
            Log::warning("{$label} failed", ['body' => $response->body()]);

            return false;
        }

        return true;
    }

    protected function sendViaWebhook(string $phone, string $code): bool
    {
        $url = config('taxigo.sms.webhook_url');

        if (empty($url)) {
            return false;
        }

        $response = Http::timeout(15)->post($url, [
            'phone' => $phone,
            'code' => $code,
            'message' => str_replace(':code', $code, config('taxigo.sms.message', 'TaxiGo login code: :code')),
        ]);

        return $response->successful();
    }

    protected function maskPhone(string $phone): string
    {
        $digits = preg_replace('/\D/', '', $phone) ?? '';

        if (strlen($digits) < 4) {
            return '****';
        }

        return str_repeat('*', max(0, strlen($digits) - 4)).substr($digits, -4);
    }
}
