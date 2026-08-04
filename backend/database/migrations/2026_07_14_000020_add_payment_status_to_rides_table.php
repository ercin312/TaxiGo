<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->string('payment_status')->default('pending')->after('payment_method');
            $table->string('payment_provider')->nullable()->after('payment_status');
            $table->string('payment_reference')->nullable()->after('payment_provider');
            $table->json('payment_meta')->nullable()->after('payment_reference');
        });
    }

    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn([
                'payment_status',
                'payment_provider',
                'payment_reference',
                'payment_meta',
            ]);
        });
    }
};
