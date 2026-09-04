<?php

namespace App\Filament\Resources\CharityResource\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class OrdersRelationManager extends RelationManager
{
    protected static string $relationship = 'orders';

    protected static ?string $title = 'سجل الطلبات';

    protected static ?string $recordTitleAttribute = 'food_type';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('food_type')
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('رقم الطلب')
                    ->formatStateUsing(fn ($state) => '#'.$state),
                Tables\Columns\TextColumn::make('food_type')
                    ->label('نوع الطعام'),
                Tables\Columns\TextColumn::make('quantity')
                    ->label('الكمية'),
                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'in_transit' => 'قيد التوصيل',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغى',
                        default => $state,
                    })
                    ->color(fn (string $state) => match ($state) {
                        'delivered' => 'success',
                        'in_transit' => 'warning',
                        'cancelled' => 'gray',
                        default => 'info',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('Y-m-d'),
            ])
            ->headerActions([])
            ->actions([])
            ->bulkActions([]);
    }
}
