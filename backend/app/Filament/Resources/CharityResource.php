<?php

namespace App\Filament\Resources;

use App\Enums\CharityStatus;
use App\Filament\Resources\CharityResource\Pages;
use App\Models\Charity;
use App\Services\CharityService;
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Components\Section;
use Filament\Forms\Get;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\HtmlString;

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
                TextInput::make('email')->label('البريد الإلكتروني')->email()->required()->maxLength(150)
                    // Registration checks both tables (CharityRegisterRequest)
                    // — without this, saving a duplicate email here throws a
                    // raw DB unique-constraint error instead of a clean message.
                    ->unique(ignoreRecord: true)
                    ->rules(['unique:donors,email'])
                    ->validationMessages([
                        'unique' => 'هذا البريد الإلكتروني مستخدم من حساب آخر.',
                    ]),
                TextInput::make('phone')->label('رقم الهاتف')->tel()->required()->maxLength(20)
                    // Same pattern as the donor-side contact_phone rule
                    // (StoreDonationRequest) — a plain TextInput otherwise
                    // accepts any text, letters included.
                    ->rules(['regex:/^\+?[0-9\s]{7,15}$/'])
                    ->validationMessages([
                        'regex' => 'رقم الهاتف غير صحيح — أرقام فقط (يمكن أن يبدأ بـ +).',
                    ]),
                Placeholder::make('address_preview')
                    ->label('العنوان')
                    // The mobile app derives this text from the pin the
                    // charity drops on the map (latitude/longitude are the
                    // source of truth) — an editable TextInput here would let
                    // an admin change the address without moving the pin,
                    // desyncing the two. Location changes are the charity's
                    // own responsibility, from the app.
                    ->content(fn (?Charity $record) => static::addressPreviewHtml($record))
                    ->columnSpanFull(),
            ])->columns(2),

            Section::make('وثيقة الترخيص')
                ->description('راجع الوثيقة قبل الاعتماد — هي المستند الوحيد الذي يثبت أن الجمعية مرخّصة.')
                ->schema([
                    Placeholder::make('license_preview')
                        ->label('')
                        ->content(fn (?Charity $record) => static::licensePreviewHtml($record))
                        ->columnSpanFull(),
                ]),

            Section::make('التشغيل')->schema([
                Toggle::make('has_kitchen')
                    ->label('تمتلك مطبخاً')
                    ->helperText('الجمعيات بدون مطبخ لا تُعرض عليها الأطعمة التي تحتاج طهياً.'),
                TextInput::make('work_start')
                    ->label('بداية الدوام')
                    ->type('time')
                    ->required()
                    ->live(),
                TextInput::make('work_end')
                    ->label('نهاية الدوام')
                    ->type('time')
                    ->required()
                    // Registration already enforces this (CharityRegisterRequest)
                    // — the admin edit form was missing the same guard, letting
                    // an end time before the start time save silently. A
                    // Get-based closure (rather than the `after:work_start`
                    // string rule) reads the sibling field's live value
                    // directly, so it can't silently no-op if Filament's
                    // save-time data array ever shapes the key differently.
                    ->rules([
                        fn (Get $get): \Closure => function (string $attribute, $value, \Closure $fail) use ($get) {
                            $start = $get('work_start');
                            if ($start && $value && $value <= $start) {
                                $fail('يجب أن تكون نهاية الدوام بعد بدايتها.');
                            }
                        },
                    ]),
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

                Tables\Columns\IconColumn::make('license_document')
                    ->label('الترخيص')
                    ->boolean()
                    ->state(fn (Charity $record) => $record->license_document !== null)
                    ->trueIcon('heroicon-o-document-check')
                    ->falseIcon('heroicon-o-document-minus')
                    ->trueColor('success')
                    ->falseColor('danger')
                    ->tooltip(fn (Charity $record) => $record->license_document ? 'وثيقة مرفوعة' : 'لم تُرفع وثيقة'),

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

                Tables\Actions\Action::make('license')
                    ->label('الترخيص')
                    ->icon('heroicon-o-document-text')
                    ->color('gray')
                    ->visible(fn (Charity $record) => $record->license_document !== null)
                    ->modalHeading('وثيقة الترخيص')
                    ->modalContent(fn (Charity $record) => static::licensePreviewHtml($record))
                    ->modalSubmitAction(false)
                    ->modalCancelActionLabel('إغلاق'),

                Tables\Actions\EditAction::make()->label('مراجعة'),
            ])
            ->defaultSort('created_at', 'desc');
    }

    /**
     * Renders the license document inline (image or PDF) rather than as a
     * plain link — a bare `target="_blank"` navigation to a `.pdf` URL gets
     * grabbed by browser download-manager extensions (e.g. IDM) before the
     * browser's own viewer ever sees it. An `<iframe>`/`<img>` is not a
     * top-level navigation, so it renders undisturbed.
     */
    private static function licensePreviewHtml(?Charity $record): HtmlString
    {
        if (! $record?->license_document) {
            return new HtmlString(
                '<span class="fi-color-danger text-sm">لم ترفع الجمعية أي وثيقة ترخيص.</span>'
            );
        }

        $url = Storage::disk('public')->url($record->license_document);
        $isImage = (bool) preg_match('/\.(jpe?g|png|webp)$/i', $record->license_document);

        if ($isImage) {
            return new HtmlString(
                '<a href="' . e($url) . '" target="_blank" rel="noopener">'
                    . '<img src="' . e($url) . '" alt="وثيقة الترخيص" '
                    . 'style="max-height:22rem;border-radius:.75rem;border:1px solid rgb(214 211 209)">'
                    . '</a>'
            );
        }

        return new HtmlString(
            '<iframe src="' . e($url) . '" title="وثيقة الترخيص" '
                . 'style="width:100%;height:32rem;border:1px solid rgb(214 211 229);border-radius:.75rem"></iframe>'
                . '<div class="fi-mt-2"><a href="' . e($url) . '" target="_blank" rel="noopener" '
                . 'class="fi-link fi-size-sm">فتح في تبويب جديد</a></div>'
        );
    }

    /**
     * Read-only address + coordinates, with a Google Maps link when a pin
     * exists — mirrors the mobile app's "فتح في الخرائط" affordance so an
     * admin can verify the location without being able to edit the text out
     * of sync with the actual pin.
     */
    private static function addressPreviewHtml(?Charity $record): HtmlString
    {
        if (! $record) {
            return new HtmlString('<span class="text-sm">—</span>');
        }

        $address = e($record->address);

        if ($record->latitude === null || $record->longitude === null) {
            return new HtmlString("<span class=\"text-sm\">{$address}</span>");
        }

        $mapsUrl = "https://www.google.com/maps/search/?api=1&query={$record->latitude},{$record->longitude}";

        return new HtmlString(
            "<div class=\"text-sm\">{$address}</div>"
                . '<div class="fi-mt-1"><a href="' . e($mapsUrl) . '" target="_blank" rel="noopener" '
                . 'class="fi-link fi-size-sm">فتح الموقع على خرائط جوجل</a></div>'
        );
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
