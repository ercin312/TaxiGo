<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('firebase_uid')->nullable()->unique()->after('id');
            $table->string('phone')->nullable()->unique()->after('email');
            $table->string('role')->default('passenger')->after('phone');
            $table->string('locale', 10)->default('en')->after('role');
            $table->string('avatar')->nullable()->after('locale');
            $table->boolean('is_active')->default(true)->after('avatar');
            $table->string('fcm_token')->nullable()->after('is_active');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'firebase_uid',
                'phone',
                'role',
                'locale',
                'avatar',
                'is_active',
                'fcm_token',
            ]);
        });
    }
};
