<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfilePhotoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by auth:sanctum
    }

    public function rules(): array
    {
        return [
            'photo' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:3072'],
        ];
    }

    public function messages(): array
    {
        return [
            'photo.image' => 'الملف المرفق يجب أن يكون صورة.',
            'photo.mimes' => 'الصورة يجب أن تكون بصيغة jpg أو png أو webp.',
            'photo.max'   => 'حجم الصورة يجب ألا يزيد عن 3 ميغابايت.',
        ];
    }
}
