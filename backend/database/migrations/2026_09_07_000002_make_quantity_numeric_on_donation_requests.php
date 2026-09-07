<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * `quantity_desc` was a VARCHAR even though validation only ever accepted a
 * whole number — the column and the contract finally agree: `quantity` is an
 * unsigned integer (the estimated people count, 1–99999).
 *
 * Existing rows keep their number: the first digits of the old text are
 * parsed ("20 وجبة" → 20); rows with no digits at all keep the column's
 * default of 1 so the column can stay NOT NULL.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->unsignedInteger('quantity')->default(1)->after('needs_cooking');
        });

        DB::table('donation_requests')->orderBy('id')->chunk(100, function ($rows) {
            foreach ($rows as $row) {
                $quantity = $this->parseQuantity($row->quantity_desc);

                if ($quantity !== null) {
                    DB::table('donation_requests')
                        ->where('id', $row->id)
                        ->update(['quantity' => $quantity]);
                }
            }
        });

        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn('quantity_desc');
        });
    }

    public function down(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->string('quantity_desc', 150)->default('')->after('needs_cooking');
        });

        DB::table('donation_requests')->orderBy('id')->chunk(100, function ($rows) {
            foreach ($rows as $row) {
                DB::table('donation_requests')
                    ->where('id', $row->id)
                    ->update(['quantity_desc' => (string) $row->quantity]);
            }
        });

        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn('quantity');
        });
    }

    /**
     * The old free text was usually a bare number ("25") written by the app,
     * sometimes a number with words ("حوالي 20 وجبة") — take the digits; keep
     * the validation bounds (1–99999) while at it. Null means "no number at
     * all" and the row simply keeps the column default.
     */
    private function parseQuantity(?string $desc): ?int
    {
        if ($desc === null || trim($desc) === '') {
            return null;
        }

        if (preg_match('/\d+/', $desc, $m) !== 1) {
            return null;
        }

        return max(1, min((int) $m[0], 99999));
    }
};
