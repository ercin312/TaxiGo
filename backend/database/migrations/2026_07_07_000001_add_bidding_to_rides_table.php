<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->decimal('offered_fare', 10, 2)->nullable()->after('estimated_fare');
            $table->decimal('minimum_fare', 10, 2)->nullable()->after('offered_fare');
            $table->boolean('is_bidding')->default(true)->after('minimum_fare');
        });
    }

    public function down(): void
    {
        Schema::table('rides', function (Blueprint $table) {
            $table->dropColumn(['offered_fare', 'minimum_fare', 'is_bidding']);
        });
    }
};
