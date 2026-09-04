<?php

namespace App\Filament\Widgets;

use App\Models\DonationOrder;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class DonationsChart extends ChartWidget
{
    protected static ?string $heading = 'اتجاه التبرعات خلال 30 يومًا';

    protected static ?int $sort = 2;

    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $days = collect(range(29, 0))->map(fn(int $i) => Carbon::now()->subDays($i)->toDateString());

        $counts = DonationOrder::query()
            ->selectRaw('date(created_at) as day, count(*) as total')
            ->whereDate('created_at', '>=', Carbon::now()->subDays(29)->toDateString())
            ->groupBy('day')
            ->pluck('total', 'day');

        return [
            'datasets' => [
                [
                    'label' => 'عدد طلبات التبرع',
                    'data' => $days->map(fn(string $day) => $counts->get($day, 0))->values(),
                    'backgroundColor' => '#2F6B3C',
                    'borderColor' => '#2F6B3C',
                ],
            ],
            'labels' => $days->map(fn(string $day) => Carbon::parse($day)->format('m-d'))->values(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }

    protected function getOptions(): array
    {
        return [
            'scales' => [
                'y' => [
                    'beginAtZero' => true,
                    'ticks' => [
                        'stepSize' => 1,
                        'precision' => 0,
                    ],
                ],
            ],
        ];
    }
}
