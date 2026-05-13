<?php

namespace App\Services;

use App\Models\PhoneOtp;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class OtpService
{
    private const EXPIRY_MINUTES = 10;
    private const RATE_LIMIT_SECONDS = 60;

    public function canSend(User $user): bool
    {
        return ! PhoneOtp::where('user_id', $user->id)
            ->where('created_at', '>', now()->subSeconds(self::RATE_LIMIT_SECONDS))
            ->exists();
    }

    public function send(User $user): string
    {
        PhoneOtp::where('user_id', $user->id)->delete();

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        PhoneOtp::create([
            'user_id'    => $user->id,
            'code'       => $code,
            'expires_at' => now()->addMinutes(self::EXPIRY_MINUTES),
        ]);

        $this->dispatch($user->phone, $code);

        return $code;
    }

    public function verify(User $user, string $code): bool
    {
        $otp = PhoneOtp::where('user_id', $user->id)
            ->where('code', $code)
            ->where('expires_at', '>', now())
            ->first();

        if (! $otp) {
            return false;
        }

        $otp->delete();
        $user->update(['phone_verified_at' => now()]);

        return true;
    }

    private function dispatch(string $phone, string $code): void
    {
        $sid   = config('services.twilio.sid');
        $token = config('services.twilio.token');
        $from  = config('services.twilio.from');

        if ($sid && $token && $from && class_exists(\Twilio\Rest\Client::class)) {
            $client = new \Twilio\Rest\Client($sid, $token);
            $client->messages->create($phone, [
                'from' => $from,
                'body' => "Your FindMyPart verification code is: {$code}. Valid for 10 minutes.",
            ]);
        } else {
            // Dev fallback — code appears in storage/logs/laravel.log
            Log::info("[OTP] {$phone} → {$code}");
        }
    }
}
