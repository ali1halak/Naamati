<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DonationOrderResource\Pages;
use App\Models\CharityViolation;
use App\Models\DonationOrder;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Infolists\Components as InfolistComponents;
use Filament\Infolists\Infolist;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class DonationOrderResource extends Resource
{
    protected static ?string $model = DonationOrder::class;

    protected static ?string $navigationIcon = 'heroicon-o-archive-box-arrow-down';

    protected static ?string $navigationLabel = 'طلبات التبرع';

    protected static ?string $modelLabel = 'طلب تبرع';

    protected static ?string $pluralModelLabel = 'طلبات التبرع';

    protected static ?string $navigationGroup = 'إدارة نعمتي';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('charity_id')
                    ->label('الجمعية')
                    ->relationship('charity', 'name')
                    ->searchable()
                    ->required(),
                Forms\Components\TextInput::make('food_type')
                    ->label('نوع الطعام')
                    ->required(),
                Forms\Components\TextInput::make('quantity')
                    ->label('الكمية')
                    ->numeric()
                    ->required(),
                Forms\Components\TextInput::make('donor_name')
                    ->label('اسم المتبرع')
                    ->required(),
                Forms\Components\TextInput::make('donor_phone')
                    ->label('هاتف المتبرع')
                    ->tel()
                    ->required(),
                Forms\Components\Select::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'in_transit' => 'قيد التوصيل',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغى',
                    ])
                    ->required(),
                Forms\Components\DateTimePicker::make('delivered_at')
                    ->label('تاريخ التسليم'),
            ]);
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                InfolistComponents\Section::make('بيانات المتبرع')
                    ->schema([
                        InfolistComponents\TextEntry::make('donor_name')->label('اسم المتبرع'),
                        InfolistComponents\TextEntry::make('donor_phone')->label('هاتف المتبرع'),
                        InfolistComponents\TextEntry::make('donor_rating')->label('تقييم المتبرع')
                            ->suffix(' / 5')
                            ->icon('heroicon-s-star')
                            ->iconColor('warning'),
                        InfolistComponents\TextEntry::make('charity.name')->label('الجمعية المستلمة'),
                    ])
                    ->columns(2),
                InfolistComponents\Section::make('بيانات اللوجستيات')
                    ->schema([
                        InfolistComponents\TextEntry::make('food_type')->label('نوع الطعام'),
                        InfolistComponents\TextEntry::make('quantity')->label('الكمية'),
                        InfolistComponents\TextEntry::make('status')
                            ->label('الحالة')
                            ->badge()
                            ->formatStateUsing(fn (string $state) => match ($state) {
                                'pending' => 'قيد الانتظار',
                                'in_transit' => 'قيد التوصيل',
                                'delivered' => 'تم التسليم',
                                'cancelled' => 'ملغى',
                                default => $state,
                            }),
                        InfolistComponents\TextEntry::make('created_at')->label('تاريخ الإنشاء')->dateTime('Y-m-d H:i'),
                        InfolistComponents\TextEntry::make('delivered_at')->label('تاريخ التسليم')->dateTime('Y-m-d H:i')
                            ->placeholder('—'),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('رقم الطلب')
                    ->formatStateUsing(fn ($state) => '#'.$state)
                    ->searchable(),
                Tables\Columns\TextColumn::make('food_type')
                    ->label('نوع الطعام')
                    ->searchable(),
                Tables\Columns\TextColumn::make('quantity')
                    ->label('الكمية')
                    ->sortable(),
                Tables\Columns\TextColumn::make('charity.name')
                    ->label('الجمعية')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('donor_rating')
                    ->label('التقييم')
                    ->icon('heroicon-s-star')
                    ->iconColor('warning')
                    ->numeric(1)
                    ->sortable(),
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
                    })
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'in_transit' => 'قيد التوصيل',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغى',
                    ]),
                Tables\Filters\SelectFilter::make('charity_id')
                    ->label('الجمعية')
                    ->relationship('charity', 'name'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()->label('عرض'),
                Tables\Actions\EditAction::make()->label('تعديل'),
                Tables\Actions\DeleteAction::make()->label('حذف'),
                static::penalizeCharityAction(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()->label('حذف المحدد'),
                ]),
            ]);
    }

    /**
     * Custom Action Header: prominent red button that logs a violation
     * against the order's charity — see the spec's production code blueprint.
     */
    public static function penalizeCharityAction(): Tables\Actions\Action
    {
        return Tables\Actions\Action::make('penalize_charity')
            ->label('تسجيل مخالفة بحق الجمعية')
            ->color('danger')
            ->icon('heroicon-o-exclamation-triangle')
            ->form([
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
                    ->placeholder('أدخل أي تفاصيل أخرى ذات صلة...'),
            ])
            ->action(function (array $data, DonationOrder $record) {
                CharityViolation::create([
                    'charity_id' => $record->charity_id,
                    'order_id' => $record->id,
                    'reason' => $data['reason'],
                    'severity' => $data['severity'],
                    'notes' => $data['notes'] ?? null,
                ]);

                Notification::make()
                    ->title('تم تسجيل المخالفة بنجاح')
                    ->danger()
                    ->send();
            });
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDonationOrders::route('/'),
            'create' => Pages\CreateDonationOrder::route('/create'),
            'view' => Pages\ViewDonationOrder::route('/{record}'),
            'edit' => Pages\EditDonationOrder::route('/{record}/edit'),
        ];
    }
}
