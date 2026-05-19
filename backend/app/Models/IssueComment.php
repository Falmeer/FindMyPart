<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IssueComment extends Model
{
    protected $fillable = ['vehicle_issue_id', 'user_id', 'body'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function issue()
    {
        return $this->belongsTo(VehicleIssue::class);
    }
}
