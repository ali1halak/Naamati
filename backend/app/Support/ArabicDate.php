<?php

namespace App\Support;

use DateTimeInterface;

/**
 * Arabic date wording for the screens that display it.
 *
 * Written by hand rather than through ext-intl: the extension is not enabled
 * everywhere this runs, and its output for `ar` varies by ICU version — which
 * would quietly change what users see after a server upgrade.
 */
class ArabicDate
{
    /** Gregorian months as the app writes them. */
    private const MONTHS = [
        1 => 'يناير', 2 => 'فبراير', 3 => 'مارس', 4 => 'أبريل',
        5 => 'مايو', 6 => 'يونيو', 7 => 'يوليو', 8 => 'أغسطس',
        9 => 'سبتمبر', 10 => 'أكتوبر', 11 => 'نوفمبر', 12 => 'ديسمبر',
    ];

    /** e.g. "12 أكتوبر 2026" — for the history list. */
    public static function day(?DateTimeInterface $date): ?string
    {
        if (! $date) {
            return null;
        }

        return $date->format('j') . ' ' . self::MONTHS[(int) $date->format('n')] . ' ' . $date->format('Y');
    }

    /** e.g. "02:00 PM" — for the audit timeline, which shows times only. */
    public static function time(?DateTimeInterface $date): ?string
    {
        return $date?->format('h:i A');
    }

    /** e.g. "05:00 مساءً" — same clock, Arabic half-day, for Arabic-only screens. */
    public static function timeArabic(?DateTimeInterface $date): ?string
    {
        if (! $date) {
            return null;
        }

        return $date->format('h:i') . ' ' . ($date->format('A') === 'AM' ? 'صباحاً' : 'مساءً');
    }

    /** e.g. "12 أكتوبر 2026، 02:00 PM" — day and time together. */
    public static function dayTime(?DateTimeInterface $date): ?string
    {
        if (! $date) {
            return null;
        }

        return self::day($date) . '، ' . self::time($date);
    }
}
