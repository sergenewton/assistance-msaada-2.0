<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('organizations', function (Blueprint $table) {
            if (!Schema::hasColumn('organizations', 'sector')) {
                $table->string('sector')->nullable()->after('type');
            }
            if (!Schema::hasColumn('organizations', 'contact_person')) {
                $table->string('contact_person')->nullable()->after('contact_phone');
            }
            if (!Schema::hasColumn('organizations', 'services_offered')) {
                $table->json('services_offered')->nullable()->after('contact_person');
            }
            if (!Schema::hasColumn('organizations', 'availability')) {
                $table->string('availability')->nullable()->after('services_offered');
            }
        });
    }

    public function down(): void
    {
    Schema::table('organizations', function (Blueprint $table) {
        if (Schema::hasColumn('organizations', 'sector')) {
            $table->dropColumn('sector');
        }

        if (Schema::hasColumn('organizations', 'contact_person')) {
            $table->dropColumn('contact_person');
        }

        if (Schema::hasColumn('organizations', 'services_offered')) {
            $table->dropColumn('services_offered');
        }

        if (Schema::hasColumn('organizations', 'availability')) {
            $table->dropColumn('availability');
        }
    });
    }
};
