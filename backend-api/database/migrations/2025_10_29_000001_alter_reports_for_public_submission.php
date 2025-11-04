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
        if (Schema::hasColumn('reports', 'payload')) {
            $table->dropColumn('payload');
        }

        if (Schema::hasColumn('reports', 'violence_types')) {
            $table->dropColumn('violence_types');
        }

        if (Schema::hasColumn('reports', 'incident_location_json')) {
            $table->dropColumn('incident_location_json');
        }

        if (Schema::hasColumn('reports', 'address_line')) {
            $table->dropColumn('address_line');
        }

        if (Schema::hasColumn('reports', 'latitude')) {
            $table->dropColumn('latitude');
        }

        if (Schema::hasColumn('reports', 'longitude')) {
            $table->dropColumn('longitude');
        }

        if (Schema::hasColumn('reports', 'preferred_contact_methods')) {
            $table->dropColumn('preferred_contact_methods');
        }

        if (Schema::hasColumn('reports', 'reporter_name')) {
            $table->dropColumn('reporter_name');
        }

        if (Schema::hasColumn('reports', 'victim_name')) {
            $table->dropColumn('victim_name');
        }

        if (Schema::hasColumn('reports', 'contact_number')) {
            $table->dropColumn('contact_number');
        }

        if (Schema::hasColumn('reports', 'attachments')) {
            $table->dropColumn('attachments');
        }
    });
    }
};
