<?php

namespace App\Filament\Widgets;

use App\Enums\CharityStatus;
use App\Enums\RequestStatus;
use App\Models\Charity;
use App\Models\Distribution;
use App\Models\DonationRequest;
use App\Models\Violation;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

/**
 * The numbers an admin needs on opening the panel.
 *
 * Every figure is counted from real rows. The prototype estimated families
 * served by multiplying orders by a guess; the charities actually report those
 * counts after distributing, so the real sum is used instead — a dashboard that
 * invents its own impact numbers is worse than one that shows none.
 */
class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $completed = DonationRequest::where('status', RequestStatus::Completed)->count();
        $open      = DonationRequest::whereIn('status', [RequestStatus::Pending, RequestStatus::Accepted])->count();
        $waiting   = DonationRequest::where('status', RequestStatus::Pending)->count();

        $families    = (int) Distribution::sum('families_count');
        $individuals = (int) Distribution::sum('individuals_count');

        $activeCharities  = Charity::where('status', CharityStatus::Active)->count();
        $pendingCharities = Charity::where('status', CharityStatus::Pending)->count();

        return [
            Stat::make('تبرعات مكتملة', number_format($completed))
                ->description('وصلت إلى مستحقيها ووُثّقت أرقامها')
                ->descriptionIcon('heroicon-m-check-badge')
                ->color('success'),

            Stat::make('طلبات جارية', number_format($open))
                ->description($waiting > 0
                    ? number_format($waiting) . ' منها بانتظار جمعية'
                    : 'لا توجد طلبات بانتظار جمعية')
                ->descriptionIcon('heroicon-m-clock')
                ->color($waiting > 0 ? 'warning' : 'primary'),

            Stat::make('أفراد مستفيدون', number_format($individuals))
                ->description(number_format($families) . ' عائلة، بحسب تقارير الجمعيات')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),

            Stat::make('الجمعيات المفعّلة', number_format($activeCharities))
                ->description($pendingCharities > 0
                    ? number_format($pendingCharities) . ' بانتظار الاعتماد'
                    : 'لا توجد طلبات اعتماد معلقة')
                ->descriptionIcon('heroicon-m-building-office-2')
                ->color($pendingCharities > 0 ? 'warning' : 'success'),

            Stat::make('المخالفات المسجّلة', number_format(Violation::count()))
                ->description('على الجمعيات الشريكة')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color(Violation::count() > 0 ? 'danger' : 'gray'),
        ];
    }
}
