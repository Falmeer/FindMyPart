<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Auth\UserResource;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PhoneVerificationController extends Controller
{
    public function __construct(private OtpService $otp) {}

    public function sendOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'phone' => 'nullable|string|max:20',
        ]);

        $user = $request->user();

        if (! empty($validated['phone'])) {
            $user->update([
                'phone'             => $validated['phone'],
                'phone_verified_at' => null,
            ]);
            $user->refresh();
        }

        if (! $user->phone) {
            return response()->json([
                'success' => false,
                'message' => 'No phone number on file',
            ], 422);
        }

        if (! $this->otp->canSend($user)) {
            return response()->json([
                'success' => false,
                'message' => 'Please wait 60 seconds before requesting a new code',
            ], 429);
        }

        try {
            $code = $this->otp->send($user);
        } catch (\Throwable $e) {
            \Log::error('OTP send failed: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to send SMS. Please try again.',
            ], 500);
        }

        $response = ['success' => true, 'message' => 'Verification code sent'];

        // In local/dev without Twilio, expose the code so you can verify without SMS
        if (! config('services.twilio.sid')) {
            $response['dev_code'] = $code;
        }

        return response()->json($response);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'code' => 'required|string|size:6',
        ]);

        $user = $request->user();

        if (! $this->otp->verify($user, $validated['code'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired code',
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Phone verified successfully',
            'data'    => new UserResource($user->fresh()),
        ]);
    }
}
