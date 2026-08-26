<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'account_type' => ['required', 'in:donor,charity'],

            // Shared. Email must be free in both tables, otherwise login
            // (which checks donors first) could never reach the charity.
            'name'     => ['required', 'string', 'max:120'],
            'email'    => ['required', 'email', 'max:150', 'unique:donors,email', 'unique:charities,email'],
            'phone'    => ['required', 'string', 'max:20'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],

            // Donor only
            'type' => ['required_if:account_type,donor', 'in:individual,restaurant,hotel,company'],

            // Charity only
            'has_kitchen'      => ['required_if:account_type,charity', 'boolean'],
            'address'          => ['required_if:account_type,charity', 'string', 'max:255'],
            'work_start'       => ['required_if:account_type,charity', 'date_format:H:i'],
            'work_end'         => ['required_if:account_type,charity', 'date_format:H:i', 'after:work_start'],
            'license_document' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique'      => 'This email is already registered.',
            'work_end.after'    => 'Work end time must be after work start time.',
            'type.required_if'  => 'The donor type field is required.',
        ];
    }
}
