<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Validator;

class ChangePasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by auth:sanctum
    }

    public function rules(): array
    {
        return [
            'current_password' => ['required', 'string'],
            'password'         => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator) {
                if (
                    $this->filled('current_password')
                    && ! Hash::check($this->input('current_password'), $this->user()->password)
                ) {
                    $validator->errors()->add(
                        'current_password',
                        'كلمة المرور الحالية غير صحيحة.'
                    );
                }
            },
        ];
    }
}
