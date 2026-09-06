<?php

namespace App\Http\Requests\Donor;

use App\Enums\RequestStatus;
use App\Models\DonationRequest;
use App\Models\FoodCategory;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

/**
 * Donor edit of an existing request. Allowed fields are exactly the ones the
 * donor authored at create time — never status, charity, or audit data — and
 * only while the request is still `pending` (enforced in the service too;
 * once a charity is on its way the only exit is cancel).
 */
class UpdateDonationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // route already guarded by auth:sanctum + type:donor
    }

    public function rules(): array
    {
        return [
            'food_category_id' => ['required', 'integer', 'exists:food_categories,id'],

            'needs_cooking' => ['sometimes', 'boolean'],

            // Same rule as create: a plain positive people count.
            'quantity_desc' => ['required', 'integer', 'min:1', 'max:99999'],
            'description'   => ['nullable', 'string', 'max:255'],

            'custom_category' => ['nullable', 'string', 'max:150'],

            // Food must still be edible in the future — within a month,
            // so nothing sits on the board for years — and the donor cannot
            // offer a pickup window that outlives the food itself.
            'valid_until'  => ['required', 'date', 'after:now', 'before_or_equal:'.now()->addDays(30)->format('Y-m-d H:i:s')],
            'pickup_until' => ['required', 'date', 'after:now', 'before_or_equal:valid_until'],

            'pickup_address' => ['required', 'string', 'max:255'],
            'latitude'       => ['nullable', 'numeric', 'between:-90,90', 'required_with:longitude'],
            'longitude'      => ['nullable', 'numeric', 'between:-180,180', 'required_with:latitude'],

            'contact_phone' => ['required', 'string', 'max:20', 'regex:/^\+?[0-9\s]{7,15}$/'],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator) {
                $request = DonationRequest::find($this->route('id'));

                if ($request !== null && $request->donor_id === $this->user()->id) {
                    if ($request->status !== RequestStatus::Pending) {
                        $validator->errors()->add(
                            'status',
                            'Only pending requests can be edited'
                        );
                    }

                    // Mirrors the store rule: "غير ذلك" must say what it is.
                    $category = FoodCategory::find($this->integer('food_category_id'));
                    if (
                        $category !== null
                        && $category->icon === 'other'
                        && trim((string) $this->input('custom_category')) === ''
                    ) {
                        $validator->errors()->add(
                            'custom_category',
                            'يرجى توضيح نوع الطعام عند اختيار "غير ذلك".'
                        );
                    }
                }
            },
        ];
    }

    public function messages(): array
    {
        return [
            'quantity_desc.integer' => 'The quantity must be a whole number (estimated people count).',
            'quantity_desc.min'     => 'The quantity must be at least 1.',
            'quantity_desc.max'     => 'The quantity is unrealistically large.',
            'contact_phone.regex'   => 'The contact phone must be a valid phone number.',
            'valid_until.before_or_equal' => 'The food expiry must be within 30 days from now.',
            'valid_until.after'            => 'The food expiry time must be in the future.',
            'pickup_until.before_or_equal' => 'Pickup time cannot be later than the food expiry time.',
            'latitude.required_with'       => 'Latitude is required when longitude is provided.',
            'longitude.required_with'      => 'Longitude is required when latitude is provided.',
        ];
    }
}
