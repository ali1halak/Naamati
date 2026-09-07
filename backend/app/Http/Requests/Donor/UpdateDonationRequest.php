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

    /**
     * Multipart clients send booleans as the strings "true"/"false", which
     * the boolean rule rejects — normalise before validating.
     */
    protected function prepareForValidation(): void
    {
        $raw = $this->input('needs_cooking');
        if (is_string($raw)) {
            $this->merge([
                'needs_cooking' => in_array(strtolower($raw), ['true', '1'], true),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'food_category_id' => ['required', 'integer', 'exists:food_categories,id'],

            'needs_cooking' => ['sometimes', 'boolean'],

            // Same rule as create: a plain positive people count (1–99999).
            'quantity'      => ['required', 'integer', 'min:1', 'max:99999'],
            'description'   => ['nullable', 'string', 'max:255'],

            'custom_category' => ['nullable', 'string', 'max:150'],

            // Food must still be edible in the future — within a month,
            // so nothing sits on the board for years — and the donor cannot
            // offer a pickup window that outlives the food itself.
            'valid_until'  => ['required', 'date', 'after:now', 'before_or_equal:'.now()->addDays(30)->format('Y-m-d H:i:s')],
            'pickup_until' => ['required', 'date', 'after:now', 'before_or_equal:valid_until'],

            'pickup_address' => ['required', 'string', 'max:255'],

            'pickup_notes' => ['nullable', 'string', 'max:255'],
            'latitude'       => ['nullable', 'numeric', 'between:-90,90', 'required_with:longitude'],
            'longitude'      => ['nullable', 'numeric', 'between:-180,180', 'required_with:latitude'],

            'contact_phone' => ['required', 'string', 'max:20', 'regex:/^\+?[0-9\s]{7,15}$/'],

            // Photo editing mirrors create: `images` are newly added files
            // (multipart, images[] parts) and `removed_image_ids` are ids of
            // this request's existing photos to drop. Ownership and the
            // combined ≤4 cap are checked in after().
            'images'             => ['sometimes', 'array', 'max:4'],
            'images.*'           => ['image', 'mimes:jpg,jpeg,png,webp', 'max:3072'],
            'removed_image_ids'  => ['sometimes', 'array'],
            'removed_image_ids.*' => ['integer'],
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

                    $removed = collect($this->input('removed_image_ids', []))
                        ->map(fn ($id) => (int) $id)
                        ->unique();

                    // Removal targets must be photos of THIS request — a
                    // foreign id is rejected outright, never silently ignored.
                    $owned = $request->images()->pluck('id');
                    if ($removed->diff($owned)->isNotEmpty()) {
                        $validator->errors()->add(
                            'removed_image_ids',
                            'إحدى الصور المحددة للحذف لا تنتمي إلى هذا الطلب.'
                        );
                    }

                    $kept = $owned->diff($removed)->count();
                    $added = count($this->file('images', []));
                    if ($kept + $added > 4) {
                        $validator->errors()->add(
                            'images',
                            'لا يمكن إرفاق أكثر من 4 صور.'
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
            'quantity.integer' => 'The quantity must be a whole number (estimated people count).',
            'quantity.min'     => 'The quantity must be at least 1.',
            'quantity.max'     => 'The quantity is unrealistically large.',
            'contact_phone.regex'   => 'The contact phone must be a valid phone number.',
            'valid_until.before_or_equal' => 'The food expiry must be within 30 days from now.',
            'valid_until.after'            => 'The food expiry time must be in the future.',
            'pickup_until.before_or_equal' => 'Pickup time cannot be later than the food expiry time.',
            'latitude.required_with'       => 'Latitude is required when longitude is provided.',
            'longitude.required_with'      => 'Longitude is required when latitude is provided.',
        ];
    }
}
