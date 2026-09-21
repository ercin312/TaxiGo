<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ride_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->string('body', 280);
            $table->string('template_key', 64)->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->index(['ride_id', 'created_at']);
        });

        Schema::create('ride_call_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->cascadeOnDelete();
            $table->foreignId('initiator_id')->constrained('users')->cascadeOnDelete();
            $table->string('provider', 32)->default('stub');
            $table->string('proxy_number', 32)->nullable();
            $table->string('session_ref', 64)->unique();
            $table->string('status', 24)->default('created');
            $table->json('meta')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index(['ride_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ride_call_sessions');
        Schema::dropIfExists('ride_messages');
    }
};
