<?php

namespace App\Filament\Resources;

use App\Enums\CharityStatus;
use App\Filament\Resources\CharityResource\Pages;
use App\Models\Charity;
use App\Services\CharityService;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * Charity accounts, as the mobile app writes them.
 *
 * Approving here is the same call the API makes, routed through CharityService
 * so a charity reinstated from the panel gets its violations cleared exactly as
 * it would through the endpoint.
 */
class CharityResource extends Resource
{
    protected static ?string $model = Charity::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-office-2';

    protected static ?string $navigationGroup = 'الجمعيات';

    protected static ?string $navigationLabel = 'الجمعيات';

    protected static ?string $modelLabel = 'جمعية';

    protected static ?string $pluralModelLabel = 'الجمعيات';

    protected static ?int $navigationSort = 1;

    /** Charities waiting on a decision are the reason an admin opens this panel. */
    public static function getNavigationBadge(): ?string
    {
        $waiting = static::getModel()::where('status', CharityStatus::Pending)->count();

        return $waiting > 0 ? (string) $waiting : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Section::make('بيانات الجمعية')->schema([
                TextInput::make('name')->label('اسم الجمعية')->required()->maxLength(120),
                TextInput::make('email')->label('البريد الإلكتروني')->email()->required()->maxLength(150),
                TextInput::make('phone')->label('رقم الهاتف')->required()->maxLength(20),
                TextInput::make('address')->label('العنوان')->required()->maxLength(255),
            ])->columns(2),

            Section::make('التشغيل')->schema([
                Toggle::make('has_kitchen')
                    ->label('تمتلك مطبخاً')
                    ->helperText('الجمعيات بدون مطبخ لا تُعرض عليها الأطعمة التي تحتاج طهياً.'),
                TextInput::make('work_start')->label('بداية الدوام')->type('time')->required(),
                TextInput::make('work_end')->label('نهاية الدوام')->type('time')->required(),
            ])->columns(3),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('الجمعية')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('phone')->label('الهاتف')->searchable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn (CharityStatus $state) => match ($state) {
                        CharityStatus::Pending   => 'بانتظار الاعتماد',
                        CharityStatus::Active    => 'مفعّلة',
                        CharityStatus::Suspended => 'معلّقة',
                    })
                    ->color(fn (CharityStatus $state) => match ($state) {
                        CharityStatus::Pending   => 'warning',
                        CharityStatus::Active    => 'success',
                        CharityStatus::Suspended => 'danger',
                    }),

                Tables\Columns\IconColumn::make('has_kitchen')->label('مطبخ')->boolean(),

                Tables\Columns\TextColumn::make('rating_avg')
                    ->label('التقييم')
                    // null means nobody has rated yet — saying so beats showing 0.
                    ->formatStateUsing(fn (?float $state, Charity $record) => $state === null
                        ? 'لا يوجد'
                        : number_format($state, 1) . " ({$record->ratings_count})"),

                Tables\Columns\TextColumn::make('violations_count')
                    ->counts('violations')
                    ->label('المخالفات')
                    ->badge()
                    ->color(fn (int $state) => $state > 0 ? 'danger' : 'gray'),

                Tables\Columns\TextColumn::make('created_at')->label('تاريخ التسجيل')->date('Y-m-d')->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')->label('الحالة')->options([
                    'pending'   => 'بانتظار الاعتماد',
                    'active'    => 'مفعّلة',
                    'suspended' => 'معلّقة',
                ]),
                Tables\Filters\TernaryFilter::make('has_kitchen')->label('تمتلك مطبخاً'),
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('اعتماد')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (Charity $record) => $record->status !== CharityStatus::Active)
                    ->requiresConfirmation()
                    ->modalHeading('اعتماد الجمعية')
                    ->modalDescription('سيتم تفعيل الحساب، ومسح سجل المخالفات إن كان الحساب معلّقاً.')
                    ->action(function (Charity $record) {
                        app(CharityService::class)->approve($record);

                        Notification::make()->title('تم اعتماد الجمعية')->success()->send();
                    }),

                Tables\Actions\Action::make('suspend')
                    ->label('تعليق')
                    ->icon('heroicon-o-no-symbol')
                    ->color('danger')
                    ->visible(fn (Charity $record) => $record->status === CharityStatus::Active)
                    ->requiresConfirmation()
                    ->modalHeading('تعليق الجمعية')
                    ->modalDescription('لن تتمكن الجمعية من قبول أي طلب حتى يُعاد اعتمادها.')
                    ->action(function (Charity $record) {
                        app(CharityService::class)->suspend($record);

                        Notification::make()->title('تم تعليق الجمعية')->warning()->send();
                    }),

                Tables\Actions\EditAction::make()->label('تعديل'),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->withCount('violations');
    }

    public static function getRelations(): array
    {
        return [
            CharityResource\RelationManagers\ViolationsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCharities::route('/'),
            'edit'  => Pages\EditCharity::route('/{record}/edit'),
        ];
    }

    /** Accounts are created by the charities themselves through the app. */
    public static function canCreate(): bool
    {
        return false;
    }
}
