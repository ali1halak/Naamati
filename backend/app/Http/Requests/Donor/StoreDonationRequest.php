<?php

namespace App\Http\Requests\Donor;

use Illuminate\Foundation\Http\FormRequest;

class StoreDonationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by auth:sanctum + type:donor
    }

    public function rules(): array
    {
        return [
            'food_category_id' => ['required', 'integer', 'exists:food_categories,id'],

            // Optional: when omitted we fall back to the category's default.
            'needs_cooking' => ['sometimes', 'boolean'],

            'quantity_desc' => ['required', 'string', 'max:150'],
            'description'   => ['nullable', 'string', 'max:255'],

            // Food must still be edible in the future, and the donor cannot
            // offer a pickup window that outlives the food itself.
            'valid_until'  => ['required', 'date', 'after:now'],
            'pickup_until' => ['required', 'date', 'after:now', 'before_or_equal:valid_until'],

            // Written location is always required; the map pin is a bonus.
            'pickup_address' => ['required', 'string', 'max:255'],
            'latitude'       => ['nullable', 'numeric', 'between:-90,90', 'required_with:longitude'],
            'longitude'      => ['nullable', 'numeric', 'between:-180,180', 'required_with:latitude'],

            'contact_phone' => ['required', 'string', 'max:20'],
        ];
    }

    public function messages(): array
    {
        return [
            'valid_until.after'                => 'The food expiry time must be in the future.',
            'pickup_until.before_or_equal'     => 'Pickup time cannot be later than the food expiry time.',
            'latitude.required_with'           => 'Latitude is required when longitude is provided.',
            'longitude.required_with'          => 'Longitude is required when latitude is provided.',
        ];
    }
}
