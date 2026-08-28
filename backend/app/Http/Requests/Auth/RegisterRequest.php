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
            'name'         => ['required', 'string', 'max:120'],
            'type'         => ['required', Rule::in(array_map(fn ($type) => $type->value, DonorType::cases()))],
            'email'        => ['required', 'email', 'unique:donors,email'],
            'phone'        => ['required', 'string', 'max:20'],
            'password'     => ['required', 'string', 'min:8', 'confirmed'],
            'account_type' => ['sometimes', 'in:donor'],
        ];
    }
}