<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CharityResource\Pages;
use App\Filament\Resources\CharityResource\RelationManagers\OrdersRelationManager;
use App\Filament\Resources\CharityResource\RelationManagers\ViolationsRelationManager;
use App\Models\Charity;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class CharityResource extends Resource
{
    protected static ?string $model = Charity::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office-2';

    protected static ?string $navigationLabel = 'الجمعيات الشريكة';

    protected static ?string $modelLabel = 'جمعية';

    protected static ?string $pluralModelLabel = 'الجمعيات الشريكة';

    protected static ?string $navigationGroup = 'إدارة نعمتي';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\FileUpload::make('logo_path')
                    ->label('الشعار')
                    ->image()
                    ->avatar()
                    ->directory('charity-logos'),
                Forms\Components\TextInput::make('name')
                    ->label('اسم الجمعية')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('region')
                    ->label('المنطقة')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->tel()
                    ->required(),
                Forms\Components\TextInput::make('email')
                    ->label('البريد الإلكتروني')
                    ->email()
                    ->required(),
                Forms\Components\Toggle::make('active')
                    ->label('جمعية نشطة')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo_path')
                    ->label('الشعار')
                    ->circular()
                    ->defaultImageUrl(fn (Charity $record) => 'https://api.dicebear.com/9.x/initials/svg?seed='.urlencode($record->name)),
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('region')
                    ->label('المنطقة')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('orders_count')
                    ->label('إجمالي الطلبات')
                    ->counts('orders')
                    ->sortable(),
                Tables\Columns\TextColumn::make('rating')
                    ->label('متوسط التقييم')
                    ->numeric(1)
                    ->sortable()
                    ->icon('heroicon-s-star')
                    ->iconColor('warning'),
                Tables\Columns\ToggleColumn::make('active')
                    ->label('نشطة'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('region')
                    ->label('المنطقة')
                    ->options(fn () => Charity::query()->distinct()->pluck('region', 'region')->toArray()),
                Tables\Filters\TernaryFilter::make('active')
                    ->label('الحالة'),
            ])
            ->actions([
                Tables\Actions\EditAction::make()->label('تعديل'),
                Tables\Actions\DeleteAction::make()->label('حذف'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()->label('حذف المحدد'),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            OrdersRelationManager::class,
            ViolationsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCharities::route('/'),
            'create' => Pages\CreateCharity::route('/create'),
            'edit' => Pages\EditCharity::route('/{record}/edit'),
        ];
    }
}
