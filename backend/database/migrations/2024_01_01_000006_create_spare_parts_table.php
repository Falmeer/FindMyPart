<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('spare_parts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->constrained()->restrictOnDelete();
            $table->string('name');
            $table->enum('condition', ['New', 'Used', 'Refurbished'])->default('Used');
            $table->decimal('price', 10, 2);
            $table->unsignedInteger('quantity')->default(1);
            $table->text('description');
            $table->string('compatibility')->nullable();
            $table->boolean('has_warranty')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('category_id');
            $table->index('condition');
            $table->index('price');
            // $table->fullText('name'); // MySQL only
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('spare_parts');
    }
};
