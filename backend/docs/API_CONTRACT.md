# Food Surplus API — Contract (living document)

Base URL (local): `http://127.0.0.1:8000/api/v1`

> ### ⚠️ Breaking changes so far — read once, then re-import the Postman collection
>
> **Every endpoint moved under `/v1`.** `POST /api/register` is now
> `POST /api/v1/...`. Old paths return `404` in the normal error envelope.
> Change the one base-URL constant in the app — nothing else.
>
> **Registration was split in two.** There is no `POST /register` and no
> `account_type` field any more:
>
> | Old | New |
> |---|---|
> | `POST /register` + `"account_type": "donor"` | `POST /register/donor` |
> | `POST /register` + `"account_type": "charity"` | `POST /register/charity` |
>
> `POST /register/charity` takes **multipart/form-data**, because
> `license_document` is an uploaded file (pdf/jpg/jpeg/png, max 5 MB). Plain
> JSON still works when no file is attached.
>
> **QR handover is gone.** `accept` no longer returns a `qr_token` and
> `confirm` no longer takes one — the donor confirms with an empty body, and
> every confirmation is recorded as a notification instead.
>
> Additive only: `rating_avg`, `ratings_count` and `logo_url` on the charity
> object, and the notification feed below. Older clients can ignore them.
>
> Also fixed: a request without an `Accept: application/json` header used to
> get a `500` when its token was missing or expired. It now returns the same
> clean `401` envelope as every other client.

Every response — success or error — uses this envelope:

```json
// success
{ "success": true,  "data": { }, "message": "optional string or null" }
// error
{ "success": false, "data": null, "message": "human readable", "errors": { "field": ["..."] } }
```

HTTP status codes: `200` OK · `201` Created · `401` Unauthenticated · `403` Forbidden · `404` Not found · `422` Validation error · `500` Server error.

> Frontend responsibility: read `success`, show `message` (and `errors` per field on 422) as a toast/snackbar/inline text. The backend never renders UI — it only guarantees the shape above on **every** endpoint, including crashes and 404s.

---

## Status: ✅ Done & tested (Auth slice)

### `POST /api/v1/register/donor`
Creates a donor account.

Body:
```json
{
  "name": "Ahmad",
  "type": "restaurant",           // individual | restaurant | hotel | company
  "email": "donor@test.com",
  "phone": "0999999999",
  "password": "password123",
  "password_confirmation": "password123"
}
```
Success `201`:
```json
{ "success": true, "data": { "type": "donor", "user": { "id": 1, "name": "Ahmad", "type": "restaurant", "email": "donor@test.com", "phone": "0999999999" }, "token": "1|xxxxx..." }, "message": "Registered successfully" }
```
Errors: `422` if email taken / fields invalid.

### `POST /api/v1/register/charity`
Creates a charity account.

Body:
```json
{
  "name": "Al-Birr Charity",
  "email": "charity@test.com",
  "phone": "0911111111",
  "password": "password123",
  "password_confirmation": "password123",
  "has_kitchen": true,
  "address": "Aleppo - Al-Furqan",
  "work_start": "08:00",
  "work_end": "16:00",
  "license_document": null   // optional uploaded file (pdf/jpg/png) or omitted
}
```
Success `201`:
```json
{ "success": true, "data": { "type": "charity", "user": { "id": 2, "name": "Al-Birr Charity", "email": "charity@test.com", "phone": "0911111111", "status": "pending", "has_kitchen": true, "address": "Aleppo - Al-Furqan", "work_start": "08:00:00", "work_end": "16:00:00", "license_document": null }, "token": "2|xxxxx..." }, "message": "Registered successfully" }
```
Errors: `422` if email taken / fields invalid.

### `POST /api/login`
Body: `{ "email": "...", "password": "..." }`
Checks the `donors` table, then `charities`. Success `200`:
```json
{ "success": true, "data": { "type": "donor" | "charity", "user": { ... }, "token": "2|xxxxx..." }, "message": null }
```
Errors: `401 { "message": "Invalid credentials" }` on bad email/password (does not reveal which one, on purpose).

### `GET /api/me`  — requires `Authorization: Bearer {token}`
Success `200`: `{ "success": true, "data": { "type": "donor"|"charity", "user": {...} } }`
Errors: `401` if token missing/invalid/revoked.

### `POST /api/logout` — requires `Authorization: Bearer {token}`
Revokes the current token only (other devices/sessions stay logged in). Success `200`: `{ "success": true, "data": null, "message": "Logged out" }`

---

---

## Charity lifecycle (important for the app)

`pending` → (admin approves) → `active` → (admin suspends) → `suspended` → (admin approves) → `active`

A charity can **always log in**, whatever its status — that is deliberate, so it can see where it stands. But every charity-only endpoint returns `403 "Charity account is not active"` unless the status is `active`.

**Frontend:** after login, if `data.type === "charity"`, branch on `data.user.status`:
- `pending` → "waiting for admin approval" screen
- `suspended` → "account suspended" screen
- `active` → normal charity home

### The charity object

Returned by `login`, `register`, `me`, and every admin endpoint.

| Field | Type | Notes |
|---|---|---|
| `id` | int | |
| `name` | string | |
| `email` / `phone` | string | |
| `has_kitchen` | bool | `true` = can cook raw food. A charity with `false` is never offered food that needs cooking. |
| `status` | enum | `pending` · `active` · `suspended` |
| `license_document` | string \| null | |
| `rating_avg` | float \| null | Average stars, 2 decimals. `null` until the first rating arrives — show "no ratings yet", not `0`. |
| `ratings_count` | int | How many ratings the average is built from. |
| `address` | string | |
| `work_start` / `work_end` | string | `"HH:MM:SS"` |
| `logo_url` | string \| null | Absolute URL, ready to load. `null` while no logo is set. |

`rating_avg`, `ratings_count` and `logo_url` are **read-only** — no endpoint accepts them as input.

---

## Admin endpoints — `/api/admin/*`

Admin does **not** use a Bearer token. Every admin request must send:
```
X-Admin-Token: {ADMIN_TOKEN from backend .env}
```
Wrong or missing token → `401 "Invalid admin token"`.

### `GET /api/admin/charities`
Optional `?status=pending|active|suspended`. Paginated 15/page, newest first, each row carries `strikes_count`.
`data` is Laravel's paginator: rows live in `data.data`, with `data.current_page`, `data.last_page`, `data.total`.
Errors: `422` if `status` is not one of the three values.

### `POST /api/admin/charities/{id}/approve`
Sets status to `active`. If the charity was `suspended`, its strikes are cleared too — otherwise one later no-show would instantly re-suspend it.
Success `200`: `{ "success": true, "data": { ...charity, "status": "active" }, "message": "Charity approved" }`

### `POST /api/admin/charities/{id}/suspend`
Sets status to `suspended`. Success `200`, message `"Charity suspended"`.

Both return `404` if the charity id does not exist.

---

---

## Donation request status — the full list

Phase 2 endpoints are being built now. The schema is already in place, so the
app can code against these values today.

| Status | Meaning | Who moves it here |
|---|---|---|
| `pending` | Posted, waiting for a charity to take it | donor (on create) |
| `accepted` | A charity claimed it and is on the way | charity |
| `picked_up` | Handover confirmed — **reserved, not used yet** | later phase (QR) |
| `completed` | Delivered and closed. The rating prompt fires here. | donor |
| `expired` | Nobody accepted it before `valid_until` | system |
| `cancelled` | Donor pulled it back before a charity accepted | donor |
| `no_show` | Charity accepted then never showed up | system / admin |

Terminal states — `completed`, `expired`, `cancelled`, `no_show` — never change
again. `picked_up` is returned by the API only once the QR handover ships; treat
it as valid input anyway so the app does not break when it does.

> Note for anyone holding the Phase 2 PDF: that document lists only four
> statuses and calls the first one `pending`. The name matches; the list does
> not. The extra three (`expired`, `no_show`, `picked_up`) exist because the
> app has to handle food going stale, charities failing to collect, and the
> strike system that suspends them. Build the app against **this** table.

---

## Next up (not built yet)
Donor: create/list/show/cancel donation request · Charity: available requests + accept · rating · QR confirm · distribute · no-show/strikes · stats.
This section will be updated the moment each slice is done — this file is the single source of truth for the contract, matching the team plan's "API First" rule. Do not hand-build request shapes from memory; check here first.

---

# Phase 2 — Donation lifecycle

## The state machine

```
pending ──charity accepts──> accepted ──donor scans QR──> picked_up ──charity files numbers──> completed
   │                            │
   ├──donor cancels──────────> cancelled <──donor cancels──┘
   └──valid_until passes────> expired
```

`pending` on a **request** means "waiting for a charity". `pending` on a **charity account** means "waiting for admin approval". Different fields, same word.

## Donor — `/api/v1/donor/*` (Bearer token, donor)

| Method | Path | Notes |
|---|---|---|
| POST | `/requests` | Publish. Starts `pending`. |
| GET | `/requests` | Own requests, paginated. Optional `?status=`. |
| GET | `/requests/{id}` | Own request only, else `404`. |
| POST | `/requests/{id}/cancel` | Only from `pending` or `accepted`. |
| POST | `/requests/{id}/confirm` | Empty body. `accepted` → `picked_up`. |
| POST | `/requests/{id}/rate` | From `picked_up` onward. Once only. |

**Create validation:** `food_category_id` exists · `quantity_desc` required, max 150 · `needs_cooking` optional (falls back to the category default) · `valid_until` after now · `pickup_until` after now and `before_or_equal:valid_until` · `pickup_address` required · `latitude`/`longitude` optional but required together · `contact_phone` required.

**One request at a time.** A donor may only hold one request in `pending` or `accepted`. A second create returns `422` with `errors.active_request_id`, whose message carries the id already in flight so the app can route straight to it. Confirming the handover releases the lock — the donor is free again even though the charity has yet to file its distribution numbers.

## Notifications — `/api/v1/notifications` (Bearer token, donor **or** charity)

| Method | Path | Notes |
|---|---|---|
| GET | `/notifications` | Own feed, 15/page, newest first. Filters `?is_read=` and `?type=`. |
| POST | `/notifications/{id}/read` | Own notification only, else `404`. |

The same two endpoints serve both account types — the API works out who you are from the token. Donor and charity ids are numbered separately, so a notification is matched on **type + id**, never on id alone.

| Type | Goes to | Fires when | Payload |
|---|---|---|---|
| `request_accepted` | donor | a charity accepts | `charity_name`, `eta_minutes` |
| `handover_confirmed` | charity | the donor confirms handover | `donor_name`, `charity_name`, `donor_id`, `charity_id` |

The admin has a separate feed at `/api/v1/admin/notifications` (also receives `handover_confirmed`). Poll `?is_read=false` for the unread badge.

## Charity — `/api/v1/charity/*` (Bearer token, **active** charity)

| Method | Path | Notes |
|---|---|---|
| GET | `/requests/available` | Eligible open requests. |
| GET | `/requests` | Ones this charity took. |
| GET | `/requests/{id}` | Must be assigned to it, else `404`. |
| POST | `/requests/{id}/accept` | Body `eta_minutes` (5–480). Notifies the donor. |

**Available filter:** `status = pending` AND `valid_until > now` AND (charity has a kitchen OR the food does not need cooking) AND the charity has no strike on that request.

## Decisions worth knowing

- **Accept is locked** (`lockForUpdate`) so two charities racing on one request cannot both win.
- **The kitchen rule is enforced twice** — in the available filter and again on accept.
- **Ownership violations return `404`, not `403`**, so ids cannot be probed.
- **Rating is allowed from `picked_up`**, not `completed` — the donor's part ends at handover.
- **`rating_avg` is recomputed from the rows**, never incremented, so it cannot drift.

## Not built yet (phase 3)
Charity distribution numbers (`picked_up` → `completed`), no-show reporting + strikes, auto-expiry job, stats dashboard.
