<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('salvaged_vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('brand');
            $table->string('model');
            $table->unsignedSmallInteger('year');
            $table->string('engine')->nullable();
            $table->enum('transmission', ['Automatic', 'Manual'])->nullable();
            $table->unsignedInteger('mileage')->nullable();
            $table->enum('condition', ['Used', 'Damaged', 'Parts Only'])->default('Used');
            $table->string('vin', 17)->nullable()->unique();
            $table->text('description');
            $table->decimal('price', 10, 2)->nullable();
            $table->boolean('is_available')->default(true);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('brand');
            $table->index('model');
            $table->index('year');
            $table->index('condition');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('salvaged_vehicles');
    }
};
