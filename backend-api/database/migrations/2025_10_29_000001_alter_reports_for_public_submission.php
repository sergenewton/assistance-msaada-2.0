<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            // Raw payload and flexible fields to support public submissions
            $table->json('payload')->nullable()->after('closure_reason');
            $table->json('violence_types')->nullable()->after('violence_type');
            $table->json('incident_location_json')->nullable()->after('incident_location');
            $table->string('address_line')->nullable()->after('incident_location');
            $table->decimal('latitude', 10, 7)->nullable()->after('address_line');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
            $table->json('preferred_contact_methods')->nullable()->after('preferred_contact_method');
            $table->string('reporter_name')->nullable()->after('reporter_id');
            $table->string('victim_name')->nullable()->after('reporter_name');
            $table->string('contact_number')->nullable()->after('victim_name');
            $table->json('attachments')->nullable()->after('payload');
        });
    }

    public function down(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            $table->dropColumn([
                'payload',
                'violence_types',
                'incident_location_json',
                'address_line',
                'latitude',
                'longitude',
                'preferred_contact_methods',
                'reporter_name',
                'victim_name',
                'contact_number',
                'attachments',
            ]);
        });
    }
};
