<?php

namespace App\Http\Requests\Admin;

use App\Enums\ViolationSeverity;
use App\Enums\ViolationType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreViolationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by the admin middleware
    }

    public function rules(): array
    {
        return [
            'reason' => ['required', Rule::in(ViolationType::values())],

            // Omit it and the type's own default applies.
            'severity' => ['nullable', Rule::in(ViolationSeverity::values())],

            // The charity reads this, so it should say what actually happened.
            'admin_note' => ['required', 'string', 'min:10', 'max:1000'],

            // Optional: ties the notice to the order it came from.
            'donation_request_id' => ['nullable', 'integer', 'exists:donation_requests,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'reason.required'     => 'نوع المخالفة مطلوب.',
            'reason.in'           => 'نوع المخالفة غير صحيح.',
            'severity.in'         => 'درجة الخطورة غير صحيحة.',
            'admin_note.required' => 'ملاحظة الإدارة مطلوبة — الجمعية سترى هذا النص.',
            'admin_note.min'      => 'ملاحظة الإدارة قصيرة جداً، اشرح سبب المخالفة.',
        ];
    }

    public function attributes(): array
    {
        return [
            'reason'              => 'نوع المخالفة',
            'severity'            => 'درجة الخطورة',
            'admin_note'          => 'ملاحظة الإدارة',
            'donation_request_id' => 'رقم الطلب',
        ];
    }
}
