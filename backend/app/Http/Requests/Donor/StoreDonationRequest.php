<?php

namespace App\Http\Requests\Donor;

use App\Enums\RequestStatus;
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
                $active = DonationRequest::query()
                    ->where('donor_id', $this->user()->id)
                    ->whereIn('status', RequestStatus::blockingNewRequestValues())
                    ->latest('id')
                    ->first();

                if ($active) {
                    $validator->errors()->add(
                        'active_request_id',
                        "لديك طلب نشط بالفعل (رقم {$active->id}). أنهِه أو ألغِه قبل إنشاء طلب جديد."
                    );
                }
            },
        ];
    }

    public function messages(): array
    {
        return [
            'valid_until.after'            => 'يجب أن يكون وقت انتهاء صلاحية الطعام في المستقبل.',
            'pickup_until.before_or_equal' => 'لا يمكن أن يكون موعد الاستلام بعد انتهاء صلاحية الطعام.',
            'latitude.required_with'       => 'خط العرض مطلوب عند إرسال خط الطول.',
            'longitude.required_with'      => 'خط الطول مطلوب عند إرسال خط العرض.',
        ];
    }
}
