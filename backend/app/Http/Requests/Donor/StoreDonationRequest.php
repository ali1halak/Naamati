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

            // Optional: when omitted we fall back to the category's default.
            'needs_cooking' => ['sometimes', 'boolean'],

            // A plain positive number (estimated people count, 1–99999).
            'quantity'      => ['required', 'integer', 'min:1', 'max:99999'],
            'description'   => ['nullable', 'string', 'max:255'],

            // Required only when the donor files under "غير ذلك" (icon: other)
            // so the request is never stored as a meaningless "Other".
            'custom_category' => ['nullable', 'string', 'max:150'],

            // Food must still be edible in the future — within a month,
            // so nothing sits on the board for years — and the donor cannot
            // offer a pickup window that outlives the food itself.
            'valid_until'  => ['required', 'date', 'after:now', 'before_or_equal:'.now()->addDays(30)->format('Y-m-d H:i:s')],
            'pickup_until' => ['required', 'date', 'after:now', 'before_or_equal:valid_until'],

            // Written location is always required; the map pin is a bonus.
            'pickup_address' => ['required', 'string', 'max:255'],

            // How to actually find the donor: "call before arriving".
            'pickup_notes' => ['nullable', 'string', 'max:255'],
            'latitude'       => ['nullable', 'numeric', 'between:-90,90', 'required_with:longitude'],
            'longitude'      => ['nullable', 'numeric', 'between:-180,180', 'required_with:latitude'],

            'contact_phone' => ['required', 'string', 'max:20', 'regex:/^\+?[0-9\s]{7,15}$/'],

            // Photos of the food. Optional, but they are what a charity looks
            // at first when deciding whether to drive out for a request.
            // Sent as multipart: images[0], images[1], ...
            'images'   => ['sometimes', 'array', 'max:4'],
            'images.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:3072'],
        ];
    }

    /**
     * Daily posting cap.
     *
     * Five posts per calendar day (any status counts — cancel-and-repost does
     * not dodge the cap). This replaces the old one-request-at-a-time lock.
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
            'quantity.integer' => 'يجب أن تكون الكمية رقماً صحيحاً (عدد الأشخاص التقديري).',
            'quantity.min'     => 'يجب أن تكون الكمية 1 على الأقل.',
            'quantity.max'     => 'الكمية كبيرة بشكل غير واقعي.',
            'contact_phone.regex'   => 'رقم التواصل غير صحيح.',
            'valid_until.before_or_equal'      => 'يجب ألا يتجاوز وقت انتهاء الصلاحية 30 يوماً من الآن.',
            'valid_until.after'            => 'يجب أن يكون وقت انتهاء صلاحية الطعام في المستقبل.',
            'pickup_until.before_or_equal' => 'لا يمكن أن يكون موعد الاستلام بعد انتهاء صلاحية الطعام.',
            'latitude.required_with'       => 'خط العرض مطلوب عند إرسال خط الطول.',
            'longitude.required_with'      => 'خط الطول مطلوب عند إرسال خط العرض.',
            'images.max'                   => 'لا يمكن إرفاق أكثر من 4 صور.',
            'images.*.image'               => 'الملف المرفق يجب أن يكون صورة.',
            'images.*.mimes'               => 'الصورة يجب أن تكون بصيغة jpg أو png أو webp.',
            'images.*.max'                 => 'حجم الصورة يجب ألا يزيد عن 3 ميغابايت.',
        ];
    }
}
