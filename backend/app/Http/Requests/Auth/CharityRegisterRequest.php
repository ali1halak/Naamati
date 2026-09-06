<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class CharityRegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'has_kitchen' => filter_var(
                $this->input('has_kitchen'),
                FILTER_VALIDATE_BOOL,
                FILTER_NULL_ON_FAILURE
            ),
        ]);
    }

    public function rules(): array
    {
        return [
            'name'             => ['required', 'string', 'max:120'],
            'email'            => ['required', 'email', 'unique:charities,email', 'unique:donors,email'],
            'phone'            => ['required', 'string', 'max:20'],
            'password'         => ['required', 'string', 'min:8', 'confirmed'],
            'has_kitchen'      => ['required', 'boolean'],
            'address'          => ['required', 'string', 'max:255'],
            'work_start'       => ['required', 'date_format:H:i'],
            'work_end'         => ['required', 'date_format:H:i', 'after:work_start'],
            'license_document' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique'   => 'هذا البريد الإلكتروني مسجّل مسبقاً.',
            'work_end.after' => 'يجب أن تكون نهاية الدوام بعد بدايتها.',
        ];
    }
}
