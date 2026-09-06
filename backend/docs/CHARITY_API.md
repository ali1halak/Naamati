# Naamaty — Charity App API Contract

Base URL (local): `http://127.0.0.1:8000/api/v1`
Postman: `postman/Naamaty_Charity.postman_collection.json` — self-contained, with
real recorded responses. The donor and admin endpoints live in the separate
`FoodSurplus` collection; nothing here overlaps with them.

Every response, success or failure, uses the same envelope:

```json
{ "success": true,  "data": { }, "message": "string|null", "errors": null }
{ "success": false, "data": null, "message": "string",      "errors": { "field": ["..."] } }
```

Messages arrive in Arabic and are meant to be displayed as they are.

Status codes: `200` OK · `201` Created · `401` Unauthenticated · `403` Forbidden ·
`404` Not found · `422` Validation error · `429` Too many requests.

---

## The workflow

```
pending      الطلب منشور وظاهر في "الطلبات المتاحة"
    │ POST /charity/requests/{id}/accept
    ▼
accepted     الجمعية أخذته — charity_id و accepted_at و eta_minutes مضبوطة
    │ POST /charity/requests/{id}/pickup      ← نصف الجمعية
    │ POST /donor/requests/{id}/confirm       ← نصف المتبرع
    ▼ (الاثنين معاً فقط)
picked_up    الطعام انتقل فعلاً — picked_up_at مضبوط
    │ POST /charity/requests/{id}/complete
    ▼
completed    انتهى الطلب — completed_at مضبوط
    │ POST /charity/requests/{id}/impact      ← اختياري، ومتى ما توفرت الأرقام
    ▼
             أرقام المستفيدين محفوظة
```

### The handover needs both sides

`pickup` is **only the charity's half**. The donor presses its own button on its
own app. The status changes to `picked_up` **only once both timestamps are set** —
that is what stops either party from recording a handover the other never agreed
to.

While you are waiting, the response tells you so:

| Situation | `data.status` | `message` |
|---|---|---|
| You confirmed first | `accepted` | `تم تسجيل تأكيدك، بانتظار تأكيد المتبرع` |
| The donor had already confirmed | `picked_up` | `تم تأكيد استلام الطعام` |

Draw the timeline from `data.donor_confirmed_at` and `data.charity_confirmed_at`.
Confirming twice returns `422`.

### Statuses you may see but never set

| Status | Meaning |
|---|---|
| `expired` | Nobody accepted it before `valid_until` |
| `cancelled` | The donor pulled it back |
| `no_show` | A charity accepted then never came |

`status_label` carries the Arabic wording for the badge; `status` stays the
machine value.

---

## Account

### `POST /register/charity`

Creates the account. It always starts as `status: "pending"` and **every charity
endpoint answers `403 حساب الجمعية غير مفعّل بعد`** until an admin approves it. A
pending charity can still log in and call `/me`, so the app can show a
"waiting for approval" screen.

| Field | Rule |
|---|---|
| `name` | required, max 120 |
| `email` | required, must not exist as a donor **or** a charity |
| `phone` | required, max 20 |
| `password` | required, min 8, with `password_confirmation` |
| `has_kitchen` | required, bool. `false` → this charity is never shown food that needs cooking |
| `address` | required, max 255 |
| `work_start` / `work_end` | required, `"HH:MM"`, end after start |
| `license_document` | optional **file** — pdf/jpg/png, max 5 MB |

To attach the licence, send the whole request as `multipart/form-data`. Without a
file, plain JSON works.

Returns `201` with a token usable immediately.

### `POST /login`

Shared with donors — `data.type` says which you are. Branch on
`data.user.status`: `pending` / `suspended` / `active`.

### `GET /me` · `POST /logout`

`/me` refreshes status and rating on app start. `/logout` revokes only the token
used for that call.

> **Rate limit:** register and login share **5 requests per minute per IP**.
> Over that returns `429 محاولات كثيرة جداً`. Nothing is broken — wait a minute.

### The charity object

| Field | Notes |
|---|---|
| `status` | `pending` · `active` · `suspended` — read-only |
| `has_kitchen` | drives which requests you are shown |
| `rating_avg` | `null` until the first rating — show "لا يوجد تقييمات", not `0` |
| `ratings_count` | how many ratings the average covers |
| `logo_url` | absolute URL, or `null` |

---

## Marketplace

### `GET /charity/requests/available`

Screen 1 — الطلبات المتاحة. Paginated 15/page; rows in `data.data`.

Already filtered for you: only `pending`, not past `valid_until`, food needing a
kitchen hidden when you have none, and any request you previously no-showed on is
never shown again.

| Field | Notes |
|---|---|
| `title` | the food category in Arabic |
| `description` | the donor's note, or the quantity when there is none |
| `image_url` | first photo, `null` when the donor uploaded none |
| `images` | every photo, ordered |
| `category_icon` | stable key for your own asset — `cooked_ready`, `fruits_vegetables`, `bakery_sweets`, `canned_dry`, `raw_meat`, `raw_grains`, `other` |
| `quantity_desc` | free text from the donor |
| `needs_cooking` | badge on the card |
| `expiry_date` | `"YYYY-MM-DD"` |
| `pickup_deadline` | ready to print, e.g. `"05:00 مساءً"` |
| `location_zone` | the pickup address as typed |
| `latitude` / `longitude` | map pin, `null` when skipped |
| `valid_until_iso` / `pickup_until_iso` | raw timestamps for sorting and countdowns |

The donor's phone number is **deliberately absent** here — it appears only after
you accept.

### `POST /charity/requests/{id}/accept`

Body: `{ "eta_minutes": 30 }` — 5 to 480, how long you need to arrive.

Moves `pending → accepted` and notifies the donor which charity is coming and
when. Two charities may press at the same moment; only the first wins.

`422` when: another charity got there first · the request expired · it needs
cooking and you have no kitchen · `eta_minutes` out of range.

---

## Tracking

### `GET /charity/requests` · `GET /charity/requests/{id}`

Your work queue and history, and the full detail of one request including the
donor and the contact phone. Paginated 15/page.

### `POST /charity/requests/{id}/pickup`

No body. Your half of the handover — see **The handover needs both sides** above.
`422` if you already confirmed, or if the request is not `accepted`.

### `POST /charity/requests/{id}/complete`

No body. تأكيد التوزيع — the food has been handed out. Closes the request:
`completed`, and `completed_at` is stamped.

Kept separate from the numbers below so **تعبئة لاحقاً** works: the request is
finished even when nobody has counted families yet.

`422` while the handover is not confirmed by both sides, or if already completed.

### `POST /charity/requests/{id}/impact`

حفظ البيانات. Send it right after `complete`, or any time later — skipping it is
exactly what the "تعبئة لاحقاً" button does.

| Field | Rule |
|---|---|
| `families_count` | required, integer, min 1 |
| `individuals_count` | required, integer, min 1 |
| `area` | required, max 100 — the distribution zone |
| `notes` | optional, max 1000 |
| `distributed_at` | optional, defaults to now, cannot be in the future |

Aggregate counts only — never send anything that identifies a beneficiary.

Accepted **once** per request; a second call returns `422`. Requires the request
to already be `completed`.

---

## History and audit

### `GET /charity/requests?status=all&page=1`
الطلبات السابقة — every request this charity has handled, newest first.

| Query | Notes |
|---|---|
| `status` | `all` (or omit) · `pending` · `accepted` · `picked_up` · `completed` · `cancelled` · `expired` · `no_show`. An unknown value returns `422` instead of being silently ignored. |
| `per_page` | 1–50, default 15 |
| `page` | |

Each row carries `title`, `description`, `status`, `status_label`
(`"مكتمل"` · `"تم قبوله"` · `"مأخوذ"` · `"ملغى"`), `created_at_label`
(`"6 سبتمبر 2026"`) and `image_url`.

### `GET /charity/requests/{id}/details`
تفاصيل الطلب — the full audit record, grouped the way the screen draws it:

```json
{
  "order_id": "REQ-2026-09-025",
  "status": "completed",
  "status_label": "مكتمل",
  "donor":        { "name": "...", "phone": "..." },
  "donation":     { "category", "food_condition", "quantity_desc", "description", "expiry_date", "created_at", "images" },
  "pickup":       { "accepted_at", "actual_pickup_at", "deadline", "location", "notes", "eta_minutes" },
  "distribution": { "beneficiary_families", "beneficiary_individuals", "distribution_zone", "notes" }
}
```

`pickup.notes` is the donor's own instruction, e.g. "الرجاء الاتصال قبل الوصول
بـ 15 دقيقة". `distribution` is `null` until the numbers are filed — hide the
card rather than render zeros. Every Arabic timestamp has an `*_iso` twin so the
app can build a timeline without parsing Arabic.

`404` for an order this charity never accepted; other charities' ids are neither
confirmed nor denied.

---

## Compliance

### `GET /charity/violations`
سجل المخالفات. Read-only — only an admin can file a notice.

Each card:

| Field | Notes |
|---|---|
| `reference` | `"VIO-0001"` — quote it when disputing a notice |
| `title` | What kind of violation, in Arabic |
| `severity` / `severity_label` | `low` · `medium` · `high` + Arabic label |
| `admin_note` | The admin's own words, shown as written |
| `date` | `"6 سبتمبر 2026"` |
| `donation_request_id` | The order it came from, `null` for a general notice |

`data.compliance` carries `total_weight`, `suspension_threshold` and
`account_status`. Severity is weighted — low 1, medium 2, high 3 — and reaching
the threshold (**6**) suspends the account automatically, after which every
charity endpoint returns `403`.

**Show the charity how close it is.** Being suspended without warning is worse
than the suspension. An admin reinstating the account clears the record, so
`total_weight` returns to `0`.

---

## Notifications

### `GET /notifications` · `POST /notifications/{id}/read`

Your own feed, paginated 15/page. Optional filters `?type=` and `?is_read=`.

| Type | When |
|---|---|
| `handover_confirmed` | a handover you took part in is now confirmed |

`payload` carries denormalised names, so an old notification still reads
correctly after a name changes. Another account's notification id returns `404`.

---

## Reference

### `GET /food-categories`

The fixed list. `icon` is the stable asset key; `default_needs_cooking` is what
pre-fills the donor's form and drives the kitchen rule.

---

## Pagination

```
Rows      → data.data
Page info → data.meta   (current_page, last_page, per_page, total)
Page URLs → data.links  (first, last, prev, next — null at the edges)
Next page → ?page=2
```

---

## Deliberate deviation from the phase 4 document

The spec writes these paths as `/charity/orders/...`. The API keeps
`/charity/requests/...` — three of the four endpoints already shipped on that
path and the underlying table is `donation_requests`, so renaming would break
working clients for no gain. Field names follow the same rule: the impact call
takes `families_count` / `individuals_count` / `area`, and the audit view renames
them to `beneficiary_families` / `beneficiary_individuals` / `distribution_zone`
for the donor's screen.

This file is the source of truth. Do not hand-build request shapes from the PDF.
