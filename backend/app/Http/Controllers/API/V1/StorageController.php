<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

class StorageController extends Controller
{
    public function serve(string $path)
    {
        if (!Storage::disk('public')->exists($path)) {
            abort(404);
        }

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
}
