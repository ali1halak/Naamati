<?php

namespace App\Http\Requests\Charity;

use Illuminate\Foundation\Http\FormRequest;

class StoreDistributionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by auth:sanctum + type:charity
    }

    public function rules(): array
    {
        return [
            // At least one family and one person, otherwise nothing was
            // distributed and the report is meaningless. The ceilings are
            // sanity limits against a slipped digit, not policy.
            'families_count'    => ['required', 'integer', 'min:1', 'max:10000'],
            'individuals_count' => ['required', 'integer', 'min:1', 'max:100000'],

            'area'  => ['required', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:1000'],

            // Optional: lets a charity file yesterday's round today.
            'distributed_at' => ['nullable', 'date', 'before_or_equal:now'],
        ];
    }

    public function messages(): array
    {
        return [
            'families_count.min'             => 'يجب أن تكون عائلة واحدة على الأقل قد استلمت الطعام.',
            'individuals_count.min'          => 'يجب أن يكون شخص واحد على الأقل قد استلم الطعام.',
            'distributed_at.before_or_equal' => 'لا يمكن أن يكون تاريخ التوزيع في المستقبل.',
        ];
    }
}
