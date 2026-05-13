<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Models\Scrapyard;
use App\Models\ScrapyardReview;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScrapyardReviewController extends Controller
{
    public function index(Scrapyard $scrapyard): JsonResponse
    {
        $reviews = $scrapyard->reviews()->with('user')->latest()->paginate(20);

        return response()->json([
            'success'    => true,
            'data'       => $reviews->items(),
            'pagination' => [
                'current_page' => $reviews->currentPage(),
                'total'        => $reviews->total(),
            ],
        ]);
    }

    public function store(Request $request, Scrapyard $scrapyard): JsonResponse
    {
        $validated = $request->validate([
            'rating'  => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $review = ScrapyardReview::updateOrCreate(
            ['user_id' => $request->user()->id, 'scrapyard_id' => $scrapyard->id],
            $validated
        );

        return response()->json([
            'success' => true,
            'message' => 'Review submitted',
            'data'    => $review,
        ], 201);
    }
}
