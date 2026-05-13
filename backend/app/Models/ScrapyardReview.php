<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ScrapyardReview extends Model
{
    protected $table = 'scrapyard_reviews';

    protected $fillable = ['user_id', 'scrapyard_id', 'rating', 'comment'];

    protected static function booted(): void
    {
        static::saved(fn(ScrapyardReview $r) => $r->updateScrapyardRating());
        static::deleted(fn(ScrapyardReview $r) => $r->updateScrapyardRating());
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scrapyard()
    {
        return $this->belongsTo(Scrapyard::class);
    }

    private function updateScrapyardRating(): void
    {
        $scrapyard = $this->scrapyard;
        $scrapyard->update([
            'rating'       => $scrapyard->reviews()->avg('rating') ?? 0,
            'review_count' => $scrapyard->reviews()->count(),
        ]);
    }
}
