<?php

namespace App\Filament\Resources\DonationOrderResource\Pages;

use App\Filament\Resources\DonationOrderResource;
use App\Models\CharityViolation;
use App\Models\DonationOrder;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;

class ViewDonationOrder extends ViewRecord
{
    protected static string $resource = DonationOrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('penalize_charity')
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
                ->action(function (array $data) {
                    /** @var DonationOrder $record */
                    $record = $this->getRecord();

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
                }),
            Actions\EditAction::make()->label('تعديل'),
        ];
    }
}
