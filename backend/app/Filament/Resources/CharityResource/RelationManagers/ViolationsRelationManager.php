<?php

namespace App\Filament\Resources\CharityResource\RelationManagers;

use App\Enums\ViolationSeverity;
use App\Enums\ViolationType;
use App\Models\Violation;
use App\Services\ViolationService;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

/**
 * Compliance notices, filed from inside the charity's own page.
 *
 * Writing goes through ViolationService rather than straight to the model, so
 * the weighted total and the automatic suspension behave exactly as they do
 * through the API. Notices are deliberately not editable or deletable: the
 * charity has already read them, and a record that can be rewritten afterwards
 * is not a record. Reinstating the account is what clears them.
 */
class ViolationsRelationManager extends RelationManager
{
    protected static string $relationship = 'violations';

    protected static ?string $title = 'سجل المخالفات';

    protected static ?string $modelLabel = 'مخالفة';

    public function form(Form $form): Form
    {
        return $form->schema([
            Select::make('reason')
                ->label('نوع المخالفة')
                ->required()
                ->live()
                ->options(collect(ViolationType::cases())
                    ->mapWithKeys(fn (ViolationType $type) => [$type->value => $type->label()])
                    ->all()),

            Select::make('severity')
                ->label('درجة الخطورة')
                ->helperText('اتركها فارغة لاستخدام الدرجة الافتراضية لنوع المخالفة.')
                ->options(collect(ViolationSeverity::cases())
                    ->mapWithKeys(fn (ViolationSeverity $s) => [$s->value => $s->label() . ' (' . $s->weight() . ')'])
                    ->all()),

            Textarea::make('admin_note')
                ->label('ملاحظة الإدارة')
                ->helperText('الجمعية تقرأ هذا النص كما هو — اشرح ما حدث بوضوح.')
                ->required()
                ->minLength(10)
                ->maxLength(1000)
                ->rows(4)
                ->columnSpanFull(),

            Select::make('donation_request_id')
                ->label('الطلب المرتبط')
                ->helperText('اختياري — اربط المخالفة بالطلب الذي نتجت عنه.')
                ->options(fn () => $this->getOwnerRecord()
                    ->donationRequests()
                    ->latest()
                    ->limit(100)
                    ->get()
                    ->mapWithKeys(fn ($request) => [
                        $request->id => sprintf(
                            '#%d — %s',
                            $request->id,
                            $request->created_at?->format('Y-m-d') ?? ''
                        ),
                    ]))
                ->searchable()
                ->columnSpanFull(),
        ])->columns(2);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('admin_note')
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('الرقم')
                    ->formatStateUsing(fn (int $state) => 'VIO-' . str_pad((string) $state, 4, '0', STR_PAD_LEFT)),

                Tables\Columns\TextColumn::make('reason')
                    ->label('النوع')
                    ->formatStateUsing(fn (ViolationType $state) => $state->label()),

                Tables\Columns\TextColumn::make('severity')
                    ->label('الخطورة')
                    ->badge()
                    ->formatStateUsing(fn (ViolationSeverity $state) => $state->label())
                    ->color(fn (ViolationSeverity $state) => match ($state) {
                        ViolationSeverity::Low    => 'gray',
                        ViolationSeverity::Medium => 'warning',
                        ViolationSeverity::High   => 'danger',
                    }),

                Tables\Columns\TextColumn::make('admin_note')->label('الملاحظة')->wrap()->limit(80),

                Tables\Columns\TextColumn::make('donation_request_id')
                    ->label('الطلب')
                    ->placeholder('غير مرتبطة بطلب'),

                Tables\Columns\TextColumn::make('created_at')->label('التاريخ')->date('Y-m-d'),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->label('تسجيل مخالفة')
                    ->modalHeading('تسجيل مخالفة')
                    ->using(function (array $data): Violation {
                        $violation = app(ViolationService::class)
                            ->record($this->getOwnerRecord(), $data);

                        $charity = $this->getOwnerRecord()->refresh();
                        $weight  = app(ViolationService::class)->weightFor($charity);

                        if ($weight >= ViolationService::SUSPENSION_THRESHOLD) {
                            Notification::make()
                                ->title('تم تعليق الجمعية تلقائياً')
                                ->body("بلغ مجموع المخالفات {$weight} وهو عند حد التعليق.")
                                ->warning()
                                ->persistent()
                                ->send();
                        }

                        return $violation;
                    }),
            ])
            ->actions([])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('سجل نظيف')
            ->emptyStateDescription('لا توجد مخالفات مسجلة على هذه الجمعية.');
    }
}
