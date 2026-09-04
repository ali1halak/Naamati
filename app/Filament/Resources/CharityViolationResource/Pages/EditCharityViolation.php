<?php

namespace App\Filament\Resources\CharityViolationResource\Pages;

use App\Filament\Resources\CharityViolationResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditCharityViolation extends EditRecord
{
    protected static string $resource = CharityViolationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
