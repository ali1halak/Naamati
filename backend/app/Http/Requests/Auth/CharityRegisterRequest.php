<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class CharityRegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'            => ['required', 'string', 'max:120'],
            'email'           => ['required', 'email', 'unique:charities,email'],
            'phone'           => ['required', 'string', 'max:20'],
            'password'        => ['required', 'string', 'min:8', 'confirmed'],
            'has_kitchen'     => ['required', 'boolean'],
            'address'         => ['required', 'string', 'max:255'],
            'work_start'      => ['required', 'date_format:H:i'],
            'work_end'        => ['required', 'date_format:H:i'],
            'license_document' => ['nullable', 'string', 'max:255'],
            'account_type'    => ['sometimes', 'in:charity'],
        ];
    }
}
