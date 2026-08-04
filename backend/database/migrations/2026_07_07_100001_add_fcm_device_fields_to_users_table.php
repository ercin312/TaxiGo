<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->timestamp('fcm_token_updated_at')->nullable()->after('fcm_token');
            $table->boolean('is_active_device')->default(true)->after('fcm_token_updated_at');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['fcm_token_updated_at', 'is_active_device']);
        });
    }
};
