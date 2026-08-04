<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fare_tariffs', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('vehicle_type')->default('standard');
            $table->decimal('base_fare', 10, 2);
            $table->decimal('per_km_rate', 10, 2);
            $table->decimal('per_minute_rate', 10, 2);
            $table->decimal('minimum_fare', 10, 2);
            $table->decimal('surge_multiplier', 4, 2)->default(1);
            $table->string('currency', 3)->default('USD');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['vehicle_type', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fare_tariffs');
    }
};
