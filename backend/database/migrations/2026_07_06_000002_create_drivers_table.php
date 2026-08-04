<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('drivers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('approval_status')->default('pending');
            $table->boolean('is_online')->default(false);
            $table->decimal('current_latitude', 10, 7)->nullable();
            $table->decimal('current_longitude', 10, 7)->nullable();
            $table->decimal('heading', 5, 2)->nullable();
            $table->decimal('rating_average', 3, 2)->default(0);
            $table->unsignedInteger('rating_count')->default(0);
            $table->unsignedInteger('total_rides')->default(0);
            $table->timestamp('last_location_at')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['is_online', 'approval_status']);
            $table->index(['current_latitude', 'current_longitude']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('drivers');
    }
};
