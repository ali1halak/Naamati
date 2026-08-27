<?php

namespace App\Http\Requests\Donor;

use Illuminate\Foundation\Http\FormRequest;

class ConfirmPickupRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // The exact token encoded in the QR the charity presents.
            'qr_token' => ['required', 'string', 'size:64'],
        ];
    }
}
