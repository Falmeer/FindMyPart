<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use App\Models\Garage;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index(Garage $garage): JsonResponse
    {
        $reviews = $garage->reviews()->with('user')->latest()->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $reviews->items(),
            'pagination' => [
                'current_page' => $reviews->currentPage(),
                'total' => $reviews->total(),
            ],
        ]);
    }

    public function store(Request $request, Garage $garage): JsonResponse
    {
        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $review = Review::updateOrCreate(
            ['user_id' => $request->user()->id, 'garage_id' => $garage->id],
            $validated
        );

        return response()->json([
            'success' => true,
            'message' => 'Review submitted',
            'data' => $review,
        ], 201);
    }
}
