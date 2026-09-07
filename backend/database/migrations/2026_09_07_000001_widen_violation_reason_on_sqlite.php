<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Lets SQLite store the violation types other than `no_show`.
 *
 * The rename migration assumed SQLite treats `enum` as free text. It does not:
 * Laravel emits a `check ("reason" in ('no_show'))` constraint, so filing a
 * late_pickup or quantity_mismatch died with "CHECK constraint failed" — the
 * whole compliance feature was unusable on SQLite, which is what the test suite
 * runs on. MySQL was fine because its branch widened the enum properly.
 *
 * Dropping to a plain string is deliberate. The allowed values are already
 * enforced twice above the database — StoreViolationRequest validates against
 * ViolationType, and the model casts to it — so the constraint bought nothing
 * except a schema that has to be rewritten every time a type is added.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (DB::getDriverName() !== 'sqlite') {
            return;
        }

        Schema::table('violations', function (Blueprint $table) {
            $table->string('reason', 30)->default('no_show')->change();
        });
    }

    public function down(): void
    {
        // Restoring a constraint that only ever caused failures would be a
        // regression; the enum cast keeps the column honest either way.
    }
};
