<?php

namespace App\Filament\Resources;

use App\Enums\RequestStatus;
use App\Filament\Resources\DonationRequestResource\Pages;
use App\Models\DonationRequest;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * Every donation request on the platform, read-only.
 *
 * Deliberately no create or edit: a request belongs to the donor who posted it
 * and the charity that took it, and its status is driven by their actions
 * through DonationRequestService. An admin editing rows underneath them would
 * put the record out of step with what both sides were told.
 */
class DonationRequestResource extends Resource
{
    protected static ?string $model = DonationRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-gift';

    protected static ?string $navigationGroup = 'التبرعات';

    protected static ?string $navigationLabel = 'طلبات التبرع';

    protected static ?string $modelLabel = 'طلب تبرع';

    protected static ?string $pluralModelLabel = 'طلبات التبرع';

    protected static ?int $navigationSort = 1;

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->label('الرقم')->sortable(),

                Tables\Columns\TextColumn::make('foodCategory.name_ar')->label('الصنف')->searchable(),

                Tables\Columns\TextColumn::make('quantity')->label('الكمية (شخص)')->sortable(),

                Tables\Columns\TextColumn::make('donor.name')->label('المتبرع')->searchable()->limit(20),

                Tables\Columns\TextColumn::make('charity.name')
                    ->label('الجمعية')
                    ->searchable()
                    ->placeholder('لم تُقبل بعد')
                    ->limit(20),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn (RequestStatus $state) => $state->label())
                    ->color(fn (RequestStatus $state) => match ($state) {
                        RequestStatus::Pending   => 'warning',
                        RequestStatus::Accepted  => 'info',
                        RequestStatus::PickedUp  => 'primary',
                        RequestStatus::Completed => 'success',
                        RequestStatus::Cancelled,
                        RequestStatus::Expired   => 'gray',
                        RequestStatus::NoShow    => 'danger',
                    }),

                Tables\Columns\TextColumn::make('created_at')->label('أُنشئ')->date('Y-m-d')->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')->label('الحالة')->options(
                    collect(RequestStatus::cases())
                        ->mapWithKeys(fn (RequestStatus $s) => [$s->value => $s->label()])
                        ->all()
                ),
                Tables\Filters\SelectFilter::make('food_category_id')
                    ->label('الصنف')
                    ->relationship('foodCategory', 'name_ar'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()->label('التفاصيل'),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema([
            Section::make('التبرع')->schema([
                TextEntry::make('foodCategory.name_ar')->label('الصنف'),
                TextEntry::make('quantity')->label('الكمية (شخص)'),
                TextEntry::make('needs_cooking')
                    ->label('حالة الطعام')
                    ->formatStateUsing(fn (bool $state) => $state ? 'نيء — يحتاج طهياً' : 'جاهز للتوزيع'),
                TextEntry::make('description')->label('الوصف')->placeholder('لا يوجد')->columnSpanFull(),
            ])->columns(3),

            Section::make('الأطراف')->schema([
                TextEntry::make('donor.name')->label('المتبرع'),
                TextEntry::make('contact_phone')->label('هاتف التواصل'),
                TextEntry::make('charity.name')->label('الجمعية')->placeholder('لم تُقبل بعد'),
            ])->columns(3),

            Section::make('الاستلام')->schema([
                TextEntry::make('pickup_address')->label('العنوان'),
                TextEntry::make('pickup_notes')->label('تعليمات الوصول')->placeholder('لا يوجد'),
                TextEntry::make('accepted_at')->label('وقت القبول')->dateTime('Y-m-d H:i')->placeholder('—'),

                // Both halves, so an admin can see which side is holding things up.
                TextEntry::make('donor_confirmed_at')->label('تأكيد المتبرع')->dateTime('Y-m-d H:i')->placeholder('لم يؤكد'),
                TextEntry::make('charity_confirmed_at')->label('تأكيد الجمعية')->dateTime('Y-m-d H:i')->placeholder('لم تؤكد'),
                TextEntry::make('picked_up_at')->label('تم التسليم')->dateTime('Y-m-d H:i')->placeholder('—'),
            ])->columns(3),

            Section::make('التوزيع')
                ->description('الأرقام التي سجلتها الجمعية بعد التوزيع.')
                ->schema([
                    TextEntry::make('distribution.families_count')->label('عدد العائلات')->placeholder('لم تُسجل'),
                    TextEntry::make('distribution.individuals_count')->label('عدد الأفراد')->placeholder('لم تُسجل'),
                    TextEntry::make('distribution.area')->label('منطقة التوزيع')->placeholder('لم تُسجل'),
                    TextEntry::make('distribution.notes')->label('ملاحظات')->placeholder('لا يوجد')->columnSpanFull(),
                ])->columns(3),

            Section::make('التقييم')->schema([
                TextEntry::make('rating.stars')->label('النجوم')->placeholder('لم يُقيَّم'),
                TextEntry::make('rating.comment')->label('التعليق')->placeholder('لا يوجد')->columnSpan(2),
            ])->columns(3),
        ]);
    }

    public static function getEloquentQuery(): Builder
    {
        // The table and detail view both read these; loading them up front
        // keeps the list from firing a query per row.
        return parent::getEloquentQuery()
            ->with(['foodCategory', 'donor', 'charity', 'distribution', 'rating']);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDonationRequests::route('/'),
            'view'  => Pages\ViewDonationRequest::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
