<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rides', function (Blueprint $table) {
            $table->id();
            $table->string('reference')->unique();
            $table->foreignId('passenger_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('driver_id')->nullable()->constrained('drivers')->nullOnDelete();
            $table->string('status')->default('pending');
            $table->decimal('pickup_latitude', 10, 7);
            $table->decimal('pickup_longitude', 10, 7);
            $table->string('pickup_address');
            $table->decimal('dropoff_latitude', 10, 7);
            $table->decimal('dropoff_longitude', 10, 7);
            $table->string('dropoff_address');
            $table->decimal('estimated_distance_km', 8, 2)->nullable();
            $table->unsignedInteger('estimated_duration_minutes')->nullable();
            $table->decimal('estimated_fare', 10, 2)->nullable();
            $table->decimal('final_fare', 10, 2)->nullable();
            $table->decimal('distance_km', 8, 2)->nullable();
            $table->unsignedInteger('duration_minutes')->nullable();
            $table->string('payment_method')->default('cash');
            $table->foreignId('promo_code_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('commission_amount', 10, 2)->default(0);
            $table->text('cancellation_reason')->nullable();
            $table->timestamp('driver_assigned_at')->nullable();
            $table->timestamp('driver_arrived_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index(['passenger_id', 'status']);
            $table->index(['driver_id', 'status']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rides');
    }
};
