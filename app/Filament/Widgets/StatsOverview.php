<?php

namespace App\Filament\Widgets;

use App\Models\Charity;
use App\Models\CharityViolation;
use App\Models\DonationOrder;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $totalDonations = DonationOrder::count();
        $familiesServed = (int) round(DonationOrder::distinct('donor_name')->count('donor_name') * 14);
        $activeCharities = Charity::where('active', true)->count();
        $openViolations = CharityViolation::count();

        return [
            Stat::make('إجمالي التبرعات', number_format($totalDonations))
                ->description('خلال آخر 30 يومًا')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),

            Stat::make('العائلات المستفيدة', number_format($familiesServed))
                ->description('تقديري بناءً على عدد الطلبات')
                ->descriptionIcon('heroicon-m-home')
                ->color('primary'),

            Stat::make('الجمعيات النشطة', number_format($activeCharities))
                ->description('من إجمالي '.Charity::count().' جمعية شريكة')
                ->descriptionIcon('heroicon-m-building-office-2')
                ->color('primary'),

            Stat::make('المخالفات المفتوحة', number_format($openViolations))
                ->description('مسجلة بحق الجمعيات الشريكة')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color('danger'),
        ];
    }
}
