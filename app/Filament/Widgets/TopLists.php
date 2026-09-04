<?php

namespace App\Filament\Widgets;

use App\Models\Charity;
use App\Models\CharityViolation;
use App\Models\DonationOrder;
use Filament\Widgets\Widget;

class TopLists extends Widget
{
    protected static string $view = 'filament.widgets.top-lists';

    protected static ?int $sort = 3;

    protected int|string|array $columnSpan = 'full';

    public function getTopDonors(): array
    {
        return DonationOrder::query()
            ->selectRaw('donor_name, count(*) as total')
            ->groupBy('donor_name')
            ->orderByDesc('total')
            ->limit(5)
            ->get()
            ->map(fn ($row) => ['label' => $row->donor_name, 'value' => (int) $row->total])
            ->toArray();
    }

    public function getTopCharities(): array
    {
        return Charity::query()
            ->withCount('orders')
            ->orderByDesc('orders_count')
            ->limit(5)
            ->get()
            ->map(fn (Charity $charity) => ['label' => $charity->name, 'value' => $charity->orders_count])
            ->toArray();
    }

    public function getPriorityZones(): array
    {
        return CharityViolation::query()
            ->join('charities', 'charities.id', '=', 'charity_violations.charity_id')
            ->selectRaw('charities.region as region, count(*) as total')
            ->groupBy('charities.region')
            ->orderByDesc('total')
            ->limit(5)
            ->get()
            ->map(fn ($row) => ['label' => $row->region, 'value' => (int) $row->total])
            ->toArray();
    }
}
