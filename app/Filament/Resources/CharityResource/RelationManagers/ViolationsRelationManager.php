<?php

namespace App\Filament\Resources\CharityResource\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ViolationsRelationManager extends RelationManager
{
    protected static string $relationship = 'violations';

    protected static ?string $title = 'المخالفات';

    protected static ?string $recordTitleAttribute = 'reason';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('reason')
            ->columns([
                Tables\Columns\TextColumn::make('reason')
                    ->label('سبب المخالفة')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'delay' => 'تأخير في تسليم الطلبات',
                        'storage' => 'سوء تخزين المواد الغذائية',
                        'hygiene' => 'نقص في معايير النظافة',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('severity')
                    ->label('الشدة')
                    ->badge()
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'low' => 'منخفضة',
                        'medium' => 'متوسطة',
                        'high' => 'عالية',
                        default => $state,
                    })
                    ->color(fn (string $state) => match ($state) {
                        'high' => 'danger',
                        'medium' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('notes')
                    ->label('الملاحظات')
                    ->limit(40),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('Y-m-d'),
            ])
            ->headerActions([])
            ->actions([
                Tables\Actions\DeleteAction::make()->label('حذف'),
            ])
            ->bulkActions([]);
    }
}
