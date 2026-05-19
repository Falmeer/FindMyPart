<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('salvaged_vehicles', function (Blueprint $table) {
            $table->text('description')->nullable()->change();
        });

        Schema::table('spare_parts', function (Blueprint $table) {
            $table->text('description')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('salvaged_vehicles', function (Blueprint $table) {
            $table->text('description')->nullable(false)->change();
        });

        Schema::table('spare_parts', function (Blueprint $table) {
            $table->text('description')->nullable(false)->change();
        });
    }
};
