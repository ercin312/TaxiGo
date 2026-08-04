<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_registrations', function (Blueprint $table) {
            $table->id();
            $table->string('device_id', 64)->unique();
            $table->string('phone', 20)->nullable()->index();
            $table->string('fcm_token', 512);
            $table->string('platform', 16)->default('android');
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_seen_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_registrations');
    }
};
