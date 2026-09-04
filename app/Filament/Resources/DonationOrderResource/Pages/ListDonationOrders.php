<?php

namespace App\Filament\Resources\DonationOrderResource\Pages;

use App\Filament\Resources\DonationOrderResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListDonationOrders extends ListRecords
{
    protected static string $resource = DonationOrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
