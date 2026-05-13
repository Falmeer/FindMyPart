<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AIController extends Controller
{
    public function analyzeWarningLight(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|file|mimes:jpg,jpeg,png,gif,webp|max:10240',
        ]);

        $apiKey = config('services.groq.key');
        if (!$apiKey) {
            return response()->json(['success' => false, 'message' => 'AI service not configured.'], 503);
        }

        $file   = $request->file('image');
        $base64 = base64_encode(file_get_contents($file->getRealPath()));
        $mime   = $file->getMimeType();

        $prompt = <<<PROMPT
You are an expert automotive technician specializing in vehicle dashboard warning lights.

Analyze this image and identify ALL dashboard warning lights visible.

Respond with ONLY valid JSON, no markdown, no extra text.

If one or more warning lights are clearly visible, use this format:
{
  "identified": true,
  "lights": [
    {
      "name": "Warning light name",
      "explanation": "Brief explanation of what this warning light means and why it appears.",
      "severity": "low|medium|high",
      "action": "Simple recommended action the driver should take."
    }
  ]
}

Include every distinct warning light you can identify. Order them from highest to lowest severity.

Severity guide:
- "low": minor issue, safe to drive, address within weeks
- "medium": should be addressed within a few days, monitor closely
- "high": address immediately, may be unsafe to continue driving

If no dashboard warning light is visible or the image is unclear, use:
{
  "identified": false,
  "message": "Brief reason why the warning light could not be identified."
}
PROMPT;

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $apiKey,
            'Content-Type'  => 'application/json',
        ])->post('https://api.groq.com/openai/v1/chat/completions', [
            'model'       => 'meta-llama/llama-4-scout-17b-16e-instruct',
            'max_tokens'  => 512,
            'temperature' => 0.1,
            'messages'    => [
                [
                    'role'    => 'user',
                    'content' => [
                        [
                            'type'      => 'image_url',
                            'image_url' => [
                                'url' => "data:{$mime};base64,{$base64}",
                            ],
                        ],
                        [
                            'type' => 'text',
                            'text' => $prompt,
                        ],
                    ],
                ],
            ],
        ]);

        if (!$response->successful()) {
            \Log::error('Groq API error', ['status' => $response->status(), 'body' => $response->body()]);
            $message = $response->status() === 429
                ? 'Too many requests. Please wait a moment and try again.'
                : 'AI service error. Please try again.';
            return response()->json(['success' => false, 'message' => $message], $response->status() === 429 ? 429 : 502);
        }

        $text = $response->json('choices.0.message.content', '');
        \Log::info('Groq response', ['text' => $text]);

        // Strip markdown code fences if model wraps the JSON
        $text   = preg_replace('/^```(?:json)?\s*/i', '', trim($text));
        $text   = preg_replace('/\s*```$/', '', $text);
        $result = json_decode(trim($text), true);

        if (!$result) {
            \Log::error('Groq JSON parse failed', ['raw' => $text]);
            return response()->json(['success' => false, 'message' => 'Could not parse AI response.'], 502);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }
}
