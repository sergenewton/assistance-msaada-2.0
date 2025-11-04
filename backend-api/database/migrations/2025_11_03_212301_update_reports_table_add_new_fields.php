<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            if (!Schema::hasColumn('reports', 'perpetrator_has_home_access')) {
                $table->boolean('perpetrator_has_home_access')->nullable()->after('perpetrator_relationship');
            }
            if (!Schema::hasColumn('reports', 'created_by')) {
                $table->string('created_by')->default('public_api')->after('status');
            }
            if (!Schema::hasColumn('reports', 'preferred_contact_methods')) {
                $table->json('preferred_contact_methods')->nullable()->after('preferred_contact_method');
            }
            if (!Schema::hasColumn('reports', 'preferred_contact_hours')) {
                $table->text('preferred_contact_hours')->nullable()->after('preferred_contact_methods');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            $table->dropColumn([
                'perpetrator_has_home_access',
                'created_by',
                'preferred_contact_methods',
                'preferred_contact_hours'
            ]);
        });
    }
};
