<?php

namespace App\Http\Requests\Auth;

use App\Enums\DonorType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'     => ['required', 'string', 'max:120'],
            'type'     => ['required', Rule::in(array_map(fn ($type) => $type->value, DonorType::cases()))],
            'email'    => ['required', 'email', 'unique:donors,email', 'unique:charities,email'],
            'phone'    => ['required', 'string', 'max:20'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'هذا البريد الإلكتروني مسجّل مسبقاً.',
            'type.in'      => 'نوع المتبرع يجب أن يكون: فرد أو مطعم أو فندق أو شركة.',
        ];
    }
}
