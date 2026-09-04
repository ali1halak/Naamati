<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CharityViolationResource\Pages;
use App\Models\CharityViolation;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class CharityViolationResource extends Resource
{
    protected static ?string $model = CharityViolation::class;

    protected static ?string $navigationIcon = 'heroicon-o-exclamation-triangle';

    protected static ?string $navigationLabel = 'المخالفات والامتثال';

    protected static ?string $modelLabel = 'مخالفة';

    protected static ?string $pluralModelLabel = 'المخالفات';

    protected static ?string $navigationGroup = 'إدارة نعمتي';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('charity_id')
                    ->label('الجمعية')
                    ->relationship('charity', 'name')
                    ->searchable()
                    ->required(),
                Forms\Components\Select::make('order_id')
                    ->label('الطلب المرتبط (اختياري)')
                    ->relationship('order', 'id')
                    ->getOptionLabelFromRecordUsing(fn ($record) => '#'.$record->id.' — '.$record->food_type)
                    ->searchable(),
                Forms\Components\Select::make('reason')
                    ->label('سبب المخالفة')
                    ->options([
                        'delay' => 'تأخير في تسليم الطلبات',
                        'storage' => 'سوء تخزين المواد الغذائية',
                        'hygiene' => 'نقص في معايير النظافة',
                    ])
                    ->required(),
                Forms\Components\Select::make('severity')
                    ->label('شدة المخالفة')
                    ->options([
                        'low' => 'منخفضة',
                        'medium' => 'متوسطة',
                        'high' => 'عالية',
                    ])
                    ->default('medium')
                    ->required(),
                Forms\Components\Textarea::make('notes')
                    ->label('ملاحظات إضافية')
                    ->placeholder('أدخل أي تفاصيل أخرى ذات صلة...')
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('charity.name')
                    ->label('الجمعية')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('reason')
                    ->label('سبب المخالفة')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'delay' => 'تأخير في تسليم الطلبات',
                        'storage' => 'سوء تخزين المواد الغذائية',
                        'hygiene' => 'نقص في معايير النظافة',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('Y-m-d')
                    ->sortable(),
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
                    })
                    ->sortable(),
                Tables\Columns\TextColumn::make('notes')
                    ->label('الملاحظات')
                    ->limit(50)
                    ->toggleable(),
            ])
            // Collapsible audit log grouped by charity.
            ->defaultGroup('charity.name')
            ->groups([
                Tables\Grouping\Group::make('charity.name')
                    ->label('الجمعية')
                    ->collapsible(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('severity')
                    ->label('الشدة')
                    ->options([
                        'low' => 'منخفضة',
                        'medium' => 'متوسطة',
                        'high' => 'عالية',
                    ]),
                Tables\Filters\SelectFilter::make('charity_id')
                    ->label('الجمعية')
                    ->relationship('charity', 'name'),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\EditAction::make()->label('تعديل'),
                Tables\Actions\DeleteAction::make()->label('حذف'),
                Tables\Actions\RestoreAction::make()->label('استرجاع'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()->label('حذف المحدد'),
                    Tables\Actions\RestoreBulkAction::make()->label('استرجاع المحدد'),
                ]),
            ]);
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes([SoftDeletingScope::class]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCharityViolations::route('/'),
            'create' => Pages\CreateCharityViolation::route('/create'),
            'edit' => Pages\EditCharityViolation::route('/{record}/edit'),
        ];
    }
}
