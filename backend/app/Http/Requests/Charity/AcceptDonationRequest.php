<?php

namespace App\Http\Requests\Charity;

use Illuminate\Foundation\Http\FormRequest;

class AcceptDonationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // How long the charity says it needs to reach the donor.
            // Capped at 8h so a typo cannot promise an absurd arrival time.
            'eta_minutes' => ['required', 'integer', 'between:5,480'],
        ];
    }

    public function messages(): array
    {
        return [
            'eta_minutes.between' => 'Estimated arrival must be between 5 and 480 minutes.',
        ];
    }
}
