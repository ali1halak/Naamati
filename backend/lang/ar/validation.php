<?php

/**
 * Arabic validation messages.
 *
 * The app is Arabic-only, so the API ships text the client can display as-is.
 * Field keys inside `errors` never change — only the sentence does — so a
 * client that reads errors.email[0] keeps working exactly as before.
 *
 * Anything missing here falls back to Laravel's built-in English, so an
 * untranslated rule degrades instead of breaking.
 */
return [

    'accepted'             => 'يجب قبول :attribute.',
    'active_url'           => ':attribute ليس رابطاً صحيحاً.',
    'after'                => 'يجب أن يكون :attribute بعد :date.',
    'after_or_equal'       => 'يجب أن يكون :attribute بعد أو يساوي :date.',
    'alpha'                => 'يجب أن يحتوي :attribute على أحرف فقط.',
    'alpha_dash'           => 'يجب أن يحتوي :attribute على أحرف وأرقام وشرطات فقط.',
    'alpha_num'            => 'يجب أن يحتوي :attribute على أحرف وأرقام فقط.',
    'array'                => 'يجب أن يكون :attribute مصفوفة.',
    'before'               => 'يجب أن يكون :attribute قبل :date.',
    'before_or_equal'      => 'يجب أن يكون :attribute قبل أو يساوي :date.',
    'boolean'              => 'يجب أن تكون قيمة :attribute إما صح أو خطأ.',
    'confirmed'            => 'تأكيد :attribute غير مطابق.',
    'current_password'     => 'كلمة المرور غير صحيحة.',
    'date'                 => ':attribute ليس تاريخاً صحيحاً.',
    'date_equals'          => 'يجب أن يكون :attribute مساوياً للتاريخ :date.',
    'date_format'          => 'صيغة :attribute غير مطابقة للصيغة :format.',
    'different'            => 'يجب أن يكون :attribute مختلفاً عن :other.',
    'digits'               => 'يجب أن يتكون :attribute من :digits رقماً.',
    'digits_between'       => 'يجب أن يتكون :attribute من :min إلى :max رقماً.',
    'email'                => 'يجب أن يكون :attribute بريداً إلكترونياً صحيحاً.',
    'ends_with'            => 'يجب أن ينتهي :attribute بأحد التالي: :values.',
    'exists'               => 'قيمة :attribute المحددة غير موجودة.',
    'file'                 => 'يجب أن يكون :attribute ملفاً.',
    'filled'               => 'حقل :attribute مطلوب.',
    'image'                => 'يجب أن يكون :attribute صورة.',
    'in'                   => 'قيمة :attribute المحددة غير صحيحة.',
    'integer'              => 'يجب أن يكون :attribute رقماً صحيحاً.',
    'ip'                   => 'يجب أن يكون :attribute عنوان IP صحيحاً.',
    'json'                 => 'يجب أن يكون :attribute نصاً بصيغة JSON.',
    'lowercase'            => 'يجب أن يكون :attribute بأحرف صغيرة.',
    'max_digits'           => 'يجب ألا يزيد :attribute عن :max رقماً.',
    'mimes'                => 'يجب أن يكون :attribute ملفاً من نوع: :values.',
    'mimetypes'            => 'يجب أن يكون :attribute ملفاً من نوع: :values.',
    'min_digits'           => 'يجب ألا يقل :attribute عن :min رقماً.',
    'not_in'               => 'قيمة :attribute المحددة غير صحيحة.',
    'numeric'              => 'يجب أن يكون :attribute رقماً.',
    'present'              => 'حقل :attribute يجب أن يكون موجوداً.',
    'prohibited'           => 'حقل :attribute غير مسموح به.',
    'regex'                => 'صيغة :attribute غير صحيحة.',
    'required'             => 'حقل :attribute مطلوب.',
    'required_if'          => 'حقل :attribute مطلوب عندما تكون قيمة :other هي :value.',
    'required_unless'      => 'حقل :attribute مطلوب ما لم تكن قيمة :other ضمن :values.',
    'required_with'        => 'حقل :attribute مطلوب عند إرسال :values.',
    'required_with_all'    => 'حقل :attribute مطلوب عند إرسال :values.',
    'required_without'     => 'حقل :attribute مطلوب عند عدم إرسال :values.',
    'required_without_all' => 'حقل :attribute مطلوب عند عدم إرسال أي من :values.',
    'same'                 => 'يجب أن يتطابق :attribute مع :other.',
    'starts_with'          => 'يجب أن يبدأ :attribute بأحد التالي: :values.',
    'string'               => 'يجب أن يكون :attribute نصاً.',
    'timezone'             => 'يجب أن يكون :attribute منطقة زمنية صحيحة.',
    'unique'               => 'قيمة :attribute مستخدمة من قبل.',
    'uploaded'             => 'فشل رفع :attribute.',
    'uppercase'            => 'يجب أن يكون :attribute بأحرف كبيرة.',
    'url'                  => 'يجب أن يكون :attribute رابطاً صحيحاً.',

    // Rules whose wording depends on the value's type.
    'between' => [
        'array'   => 'يجب أن يحتوي :attribute على عدد عناصر بين :min و :max.',
        'file'    => 'يجب أن يكون حجم :attribute بين :min و :max كيلوبايت.',
        'numeric' => 'يجب أن تكون قيمة :attribute بين :min و :max.',
        'string'  => 'يجب أن يكون طول :attribute بين :min و :max حرفاً.',
    ],
    'gt' => [
        'array'   => 'يجب أن يحتوي :attribute على أكثر من :value عنصراً.',
        'file'    => 'يجب أن يكون حجم :attribute أكبر من :value كيلوبايت.',
        'numeric' => 'يجب أن تكون قيمة :attribute أكبر من :value.',
        'string'  => 'يجب أن يكون طول :attribute أكبر من :value حرفاً.',
    ],
    'gte' => [
        'array'   => 'يجب أن يحتوي :attribute على :value عنصراً على الأقل.',
        'file'    => 'يجب ألا يقل حجم :attribute عن :value كيلوبايت.',
        'numeric' => 'يجب ألا تقل قيمة :attribute عن :value.',
        'string'  => 'يجب ألا يقل طول :attribute عن :value حرفاً.',
    ],
    'lt' => [
        'array'   => 'يجب أن يحتوي :attribute على أقل من :value عنصراً.',
        'file'    => 'يجب أن يكون حجم :attribute أقل من :value كيلوبايت.',
        'numeric' => 'يجب أن تكون قيمة :attribute أقل من :value.',
        'string'  => 'يجب أن يكون طول :attribute أقل من :value حرفاً.',
    ],
    'lte' => [
        'array'   => 'يجب ألا يحتوي :attribute على أكثر من :value عنصراً.',
        'file'    => 'يجب ألا يزيد حجم :attribute عن :value كيلوبايت.',
        'numeric' => 'يجب ألا تزيد قيمة :attribute عن :value.',
        'string'  => 'يجب ألا يزيد طول :attribute عن :value حرفاً.',
    ],
    'max' => [
        'array'   => 'يجب ألا يحتوي :attribute على أكثر من :max عنصراً.',
        'file'    => 'يجب ألا يزيد حجم :attribute عن :max كيلوبايت.',
        'numeric' => 'يجب ألا تزيد قيمة :attribute عن :max.',
        'string'  => 'يجب ألا يزيد طول :attribute عن :max حرفاً.',
    ],
    'min' => [
        'array'   => 'يجب أن يحتوي :attribute على :min عنصراً على الأقل.',
        'file'    => 'يجب ألا يقل حجم :attribute عن :min كيلوبايت.',
        'numeric' => 'يجب ألا تقل قيمة :attribute عن :min.',
        'string'  => 'يجب ألا يقل طول :attribute عن :min أحرف.',
    ],
    'size' => [
        'array'   => 'يجب أن يحتوي :attribute على :size عنصراً.',
        'file'    => 'يجب أن يكون حجم :attribute :size كيلوبايت.',
        'numeric' => 'يجب أن تكون قيمة :attribute :size.',
        'string'  => 'يجب أن يكون طول :attribute :size حرفاً.',
    ],

    'custom' => [],

    /**
     * Readable Arabic names substituted for :attribute. Without these the
     * messages would read "حقل food_category_id مطلوب".
     */
    'attributes' => [
        // Accounts
        'name'                  => 'الاسم',
        'email'                 => 'البريد الإلكتروني',
        'phone'                 => 'رقم الهاتف',
        'password'              => 'كلمة المرور',
        'password_confirmation' => 'تأكيد كلمة المرور',
        'type'                  => 'نوع المتبرع',
        'has_kitchen'           => 'توفر مطبخ',
        'address'               => 'العنوان',
        'work_start'            => 'بداية الدوام',
        'work_end'              => 'نهاية الدوام',
        'license_document'      => 'وثيقة الترخيص',

        // Donation request
        'food_category_id' => 'صنف الطعام',
        'needs_cooking'    => 'يحتاج طهي',
        'quantity_desc'    => 'وصف الكمية',
        'description'      => 'الوصف',
        'valid_until'      => 'مدة صلاحية الطعام',
        'pickup_until'     => 'آخر موعد للاستلام',
        'pickup_address'   => 'عنوان الاستلام',
        'latitude'         => 'خط العرض',
        'longitude'        => 'خط الطول',
        'contact_phone'    => 'هاتف التواصل',
        'reason'           => 'السبب',

        // Charity actions
        'eta_minutes'       => 'مدة الوصول بالدقائق',
        'families_count'    => 'عدد العائلات',
        'individuals_count' => 'عدد الأفراد',
        'area'              => 'منطقة التوزيع',
        'notes'             => 'الملاحظات',
        'distributed_at'    => 'تاريخ التوزيع',

        // Rating and filters
        'stars'    => 'عدد النجوم',
        'comment'  => 'التعليق',
        'status'   => 'الحالة',
        'per_page' => 'عدد العناصر في الصفحة',
        'is_read'  => 'حالة القراءة',
    ],
];
