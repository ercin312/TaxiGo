<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->timestamp('scheduled_at')->nullable()->after('expires_at');
            $table->string('product_mode')->default('taxi')->after('status');
            $table->string('vehicle_type')->default('standard')->after('product_mode');
            $table->string('passenger_note', 500)->nullable()->after('cancellation_reason');
            $table->index(['scheduled_at', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropIndex(['scheduled_at', 'status']);
            $table->dropColumn(['scheduled_at', 'product_mode', 'vehicle_type', 'passenger_note']);
        });
    }
};
