<?php

namespace App\Http\Requests\Profile;

use App\Enums\DonorType;
use App\Models\Donor;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by auth:sanctum
    }

    /**
     * Multipart/form clients send booleans as the strings "true"/"false",
     * which the boolean rule rejects — normalise before validating.
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('has_kitchen')) {
            $raw = $this->input('has_kitchen');
            $this->merge([
                'has_kitchen' => is_string($raw)
                    ? in_array(strtolower($raw), ['true', '1'], true)
                    : $raw,
            ]);
        }
    }

    public function rules(): array
    {
        $common = [
            'name'  => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:20', 'regex:/^\+?[0-9\s]{7,15}$/'],
        ];

        if ($this->user() instanceof Donor) {
            return $common + [
                'type' => ['required', Rule::in(array_map(fn ($type) => $type->value, DonorType::cases()))],
            ];
        }

        return $common + [
            'address'     => ['required', 'string', 'max:255'],
            'work_start'  => ['required', 'date_format:H:i'],
            'work_end'    => ['required', 'date_format:H:i', 'after:work_start'],
            'has_kitchen' => ['required', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'type.in'         => 'نوع المتبرع يجب أن يكون: فرد أو مطعم أو فندق أو شركة.',
            'work_end.after'  => 'يجب أن تكون نهاية الدوام بعد بدايتها.',
            'phone.regex'     => 'رقم الهاتف غير صحيح.',
        ];
    }
}
