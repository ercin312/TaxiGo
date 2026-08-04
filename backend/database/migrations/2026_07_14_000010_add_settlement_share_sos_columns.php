<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->timestamp('settled_at')->nullable()->after('completed_at');
            $table->string('share_token', 64)->nullable()->after('reference');
            $table->timestamp('share_expires_at')->nullable()->after('share_token');
        });

        Schema::table('complaints', function (Blueprint $table) {
            $table->decimal('latitude', 10, 7)->nullable()->after('description');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
            $table->json('metadata')->nullable()->after('longitude');
        });
    }

    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn(['settled_at', 'share_token', 'share_expires_at']);
        });

        Schema::table('complaints', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'metadata']);
        });
    }
};
