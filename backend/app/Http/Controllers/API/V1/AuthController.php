<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\Auth\UserResource;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        error_log("[REGISTER] Attempt: email={$request->email}, role={$request->role}");

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        error_log("[REGISTER] Success: user_id={$user->id}, email={$user->email}");

        $token = $user->createToken('auth_token')->plainTextToken;

        $devCode = null;
        if ($user->phone) {
            try {
                $devCode = app(OtpService::class)->send($user);
            } catch (\Throwable $e) {
                Log::error('Post-register OTP failed: ' . $e->getMessage());
            }
        }

        $data = [
            'user'  => new UserResource($user),
            'token' => $token,
        ];

        if (! config('services.twilio.sid') && $devCode !== null) {
            $data['dev_code'] = $devCode;
        }

        return response()->json([
            'success' => true,
            'message' => 'Account created successfully',
            'data'    => $data,
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        error_log("[LOGIN] Attempt: phone={$request->phone}");

        $user = User::where('phone', $request->phone)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            error_log("[LOGIN] Failed: phone={$request->phone}, reason=" . (! $user ? 'user not found' : 'wrong password'));
            return response()->json([
                'success' => false,
                'message' => 'Invalid phone number or password',
            ], 401);
        }

        if (! $user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Account has been deactivated',
            ], 403);
        }

        error_log("[LOGIN] Success: user_id={$user->id}, phone={$user->phone}");

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => new UserResource($user),
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new UserResource($request->user()),
        ]);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $user = $request->user();
        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated',
            'data'    => new UserResource($user),
        ]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => 'required|string',
            'password'         => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (! Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect',
            ], 422);
        }

        $user->update([
            'password'             => Hash::make($validated['password']),
            'must_change_password' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully',
            'data'    => ['user' => new UserResource($user)],
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate(['email' => 'required|email']);

        Password::sendResetLink($request->only('email'));

        return response()->json([
            'success' => true,
            'message' => 'Reset link sent if email exists',
        ]);
    }
}
