<?php

namespace App\Notifications;

use App\Models\IssueComment;
use Illuminate\Notifications\Notification;

class NewCommentNotification extends Notification
{
    public function __construct(private IssueComment $comment) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        $body = $this->comment->body;
        $preview = strlen($body) > 80 ? substr($body, 0, 80) . '…' : $body;

        return [
            'type'           => 'new_comment',
            'title'          => $this->comment->user->name . ' commented on your issue',
            'body'           => $preview,
            'issue_id'       => $this->comment->vehicle_issue_id,
            'commenter_name' => $this->comment->user->name,
        ];
    }
}
