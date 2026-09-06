<?php

namespace App\Http\Requests\Donor;

use App\Models\DonationRequest;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

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

            // A plain positive number (estimated people count) — free text
            // invited entries like "تكفي -5 أشخاص".
            'quantity_desc' => ['required', 'integer', 'min:1', 'max:99999'],
            'description'   => ['nullable', 'string', 'max:255'],

            // Required only when the donor files under "غير ذلك" (icon: other)
            // so the request is never stored as a meaningless "Other".
            'custom_category' => ['nullable', 'string', 'max:150'],

            // Food must still be edible in the future, and the donor cannot
            // offer a pickup window that outlives the food itself.
            // Food must still be edible in the future — within a month,
            // so nothing sits on the board for years — and the donor cannot
            // offer a pickup window that outlives the food itself.
            'valid_until'  => ['required', 'date', 'after:now', 'before_or_equal:'.now()->addDays(30)->format('Y-m-d H:i:s')],
            'pickup_until' => ['required', 'date', 'after:now', 'before_or_equal:valid_until'],

            // Written location is always required; the map pin is a bonus.
            'pickup_address' => ['required', 'string', 'max:255'],
            'latitude'       => ['nullable', 'numeric', 'between:-90,90', 'required_with:longitude'],
            'longitude'      => ['nullable', 'numeric', 'between:-180,180', 'required_with:latitude'],

            'contact_phone' => ['required', 'string', 'max:20', 'regex:/^\+?[0-9\s]{7,15}$/'],
        ];
    }

    /**
     * One live request per donor.
     *
     * The home screen shows a single "current request" card, and a charity
     * browsing the list should not have to guess which of a donor's duplicate
     * posts is the real one. The id is returned so the app can jump straight
     * to the request already in flight.
     */
    public function after(): array
    {
        return [
            function (Validator $validator) {
                // "غير ذلك" must say what it actually is.
                $category = \App\Models\FoodCategory::find($this->integer('food_category_id'));
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

                // Five posts per calendar day (any status counts — cancel-and-
                // repost does not dodge the cap). This replaces the old
                // one-request-at-a-time lock.
                $todaysCount = DonationRequest::query()
                    ->where('donor_id', $this->user()->id)
                    ->whereDate('created_at', today())
                    ->count();

                if ($todaysCount >= 5) {
                    $validator->errors()->add(
                        'daily_limit',
                        'وصلت إلى الحد الأقصى 5 طلبات في اليوم — يمكنك النشر مجدداً غداً.'
                    );
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
            'valid_until.before_or_equal'      => 'The food expiry must be within 30 days from now.',
            'valid_until.after'                => 'The food expiry time must be in the future.',
            'pickup_until.before_or_equal'     => 'Pickup time cannot be later than the food expiry time.',
            'latitude.required_with'           => 'Latitude is required when longitude is provided.',
            'longitude.required_with'          => 'Longitude is required when latitude is provided.',
        ];
    }
}
