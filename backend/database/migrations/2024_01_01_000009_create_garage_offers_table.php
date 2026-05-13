<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('garage_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_issue_id')->constrained()->cascadeOnDelete();
            $table->foreignId('garage_id')->constrained()->cascadeOnDelete();
            $table->text('message');
            $table->decimal('price', 10, 2)->nullable();
            $table->enum('status', ['pending', 'accepted', 'rejected'])->default('pending');
            $table->timestamps();

            $table->index('vehicle_issue_id');
            $table->index('garage_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('garage_offers');
    }
};
