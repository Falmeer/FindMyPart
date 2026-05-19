<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('garages', function (Blueprint $table) {
            $table->enum('status', ['pending', 'approved', 'rejected', 'suspended'])->default('approved')->after('is_active');
            $table->text('admin_notes')->nullable()->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('garages', function (Blueprint $table) {
            $table->dropColumn(['status', 'admin_notes']);
        });
    }
};
