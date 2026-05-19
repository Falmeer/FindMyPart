<?php

namespace App\Notifications;

use App\Models\Message;
use Illuminate\Notifications\Notification;

class NewMessageNotification extends Notification
{
    public function __construct(private Message $message) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        $sender = $this->message->sender;
        $body = $this->message->body;

        if (empty($body)) {
            $preview = 'Sent an image';
        } elseif (strlen($body) > 80) {
            $preview = substr($body, 0, 80) . '…';
        } else {
            $preview = $body;
        }

        return [
            'type'        => 'new_message',
            'title'       => 'New message from ' . $sender->name,
            'body'        => $preview,
            'chat_id'     => $this->message->chat_id,
            'sender_name' => $sender->name,
        ];
    }
}
