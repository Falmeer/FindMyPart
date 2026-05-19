<?php

namespace App\Http\Controllers\API\V1;

use App\Events\CommentPosted;
use App\Events\IssuePosted;
use App\Http\Controllers\Controller;
use App\Models\IssueComment;
use App\Models\VehicleIssue;
use App\Notifications\NewCommentNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VehicleIssueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $issues = VehicleIssue::withCount('comments')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(15);

        $items = collect($issues->items())->map(fn($issue) => [
            'id'            => $issue->id,
            'user_id'       => $issue->user_id,
            'brand'         => $issue->brand,
            'model'         => $issue->model,
            'year'          => $issue->year,
            'description'   => $issue->description,
            'status'        => $issue->status,
            'comment_count' => $issue->comments_count,
            'user'          => ['id' => $issue->user_id, 'name' => $request->user()->name],
            'created_at'    => $issue->created_at->toISOString(),
        ]);

        return response()->json([
            'success'    => true,
            'data'       => $items,
            'pagination' => [
                'current_page' => $issues->currentPage(),
                'last_page'    => $issues->lastPage(),
                'total'        => $issues->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'brand'       => 'required|string|max:100',
            'model'       => 'required|string|max:100',
            'year'        => 'required|integer|min:1980|max:2025',
            'description' => 'required|string|min:20',
            'latitude'    => 'nullable|numeric',
            'longitude'   => 'nullable|numeric',
        ]);

        $issue = VehicleIssue::create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        IssuePosted::dispatch($issue->id);

        return response()->json([
            'success' => true,
            'message' => 'Issue posted successfully',
            'data'    => $issue,
        ], 201);
    }

    public function openIssues(Request $request): JsonResponse
    {
        $issues = VehicleIssue::withCount('comments')
            ->with('user:id,name')
            ->where('status', 'open')
            ->latest()
            ->paginate(20);

        $items = collect($issues->items())->map(fn($issue) => [
            'id'            => $issue->id,
            'user_id'       => $issue->user_id,
            'brand'         => $issue->brand,
            'model'         => $issue->model,
            'year'          => $issue->year,
            'description'   => $issue->description,
            'status'        => $issue->status,
            'comment_count' => $issue->comments_count,
            'user'          => ['id' => $issue->user_id, 'name' => $issue->user->name ?? 'Anonymous'],
            'created_at'    => $issue->created_at->toISOString(),
        ]);

        return response()->json([
            'success'    => true,
            'data'       => $items,
            'pagination' => [
                'current_page' => $issues->currentPage(),
                'last_page'    => $issues->lastPage(),
                'total'        => $issues->total(),
            ],
        ]);
    }

    public function show(VehicleIssue $vehicleIssue): JsonResponse
    {
        $vehicleIssue->load(['user:id,name', 'comments.user:id,name']);

        $comments = $vehicleIssue->comments->map(fn($c) => [
            'id'         => $c->id,
            'user_id'    => $c->user_id,
            'user_name'  => $c->user->name ?? 'Anonymous',
            'body'       => $c->body,
            'created_at' => $c->created_at->toISOString(),
        ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'id'            => $vehicleIssue->id,
                'user_id'       => $vehicleIssue->user_id,
                'brand'         => $vehicleIssue->brand,
                'model'         => $vehicleIssue->model,
                'year'          => $vehicleIssue->year,
                'description'   => $vehicleIssue->description,
                'status'        => $vehicleIssue->status,
                'comment_count' => $comments->count(),
                'comments'      => $comments,
                'user'          => ['id' => $vehicleIssue->user_id, 'name' => $vehicleIssue->user->name ?? 'Anonymous'],
                'created_at'    => $vehicleIssue->created_at->toISOString(),
            ],
        ]);
    }

    public function getComments(Request $request, VehicleIssue $vehicleIssue): JsonResponse
    {
        $afterId = $request->integer('after_id', 0);

        $comments = $vehicleIssue->comments()
            ->with('user:id,name')
            ->when($afterId, fn($q) => $q->where('id', '>', $afterId))
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $comments->map(fn($c) => [
                'id'         => $c->id,
                'user_id'    => $c->user_id,
                'user_name'  => $c->user->name ?? 'Anonymous',
                'body'       => $c->body,
                'created_at' => $c->created_at->toISOString(),
            ]),
        ]);
    }

    public function storeComment(Request $request, VehicleIssue $vehicleIssue): JsonResponse
    {
        $validated = $request->validate([
            'body' => 'required|string|max:2000',
        ]);

        $comment = IssueComment::create([
            'vehicle_issue_id' => $vehicleIssue->id,
            'user_id'          => $request->user()->id,
            'body'             => $validated['body'],
        ]);

        $comment->load('user:id,name');

        CommentPosted::dispatch($comment);

        $issueOwner = $vehicleIssue->user;
        if ($issueOwner && $issueOwner->id !== $request->user()->id) {
            $issueOwner->notify(new NewCommentNotification($comment));
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id'         => $comment->id,
                'user_id'    => $comment->user_id,
                'user_name'  => $comment->user->name,
                'body'       => $comment->body,
                'created_at' => $comment->created_at->toISOString(),
            ],
        ], 201);
    }
}
