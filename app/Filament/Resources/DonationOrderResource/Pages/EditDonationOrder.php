<?php

namespace App\Filament\Resources\DonationOrderResource\Pages;

use App\Filament\Resources\DonationOrderResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditDonationOrder extends EditRecord
{
    protected static string $resource = DonationOrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
