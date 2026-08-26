# Food Surplus API — Contract (living document)

Base URL (local): `http://127.0.0.1:8000/api/v1`

> ### ⚠️ Breaking change — 2026-08-26: every endpoint moved under `/v1`
>
> `POST /api/register` is now `POST /api/v1/register`, and so on for all eight
> endpoints. The old paths return `404` with the normal error envelope.
>
> **App fix:** change the one base-URL constant — nothing else. The Postman
> collection is already updated, so re-import it and its `base_url` variable
> carries the new path.
>
> Everything else in this release is additive: three new read-only fields on
> the charity object (`rating_avg`, `ratings_count`, `logo_url`), which older
> clients can safely ignore.
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

### `POST /api/register`
Creates a **donor** account (charities are created only by the admin — see roadmap below).

Body:
```json
{
  "name": "Test Donor",
  "type": "restaurant",           // individual | restaurant | hotel | company
  "email": "donor1@test.com",
  "phone": "0999999999",
  "password": "password123",
  "password_confirmation": "password123"
}
```
Success `201`:
```json
{ "success": true, "data": { "type": "donor", "user": { "id": 1, "name": "...", "type": "restaurant", "email": "...", "phone": "..." }, "token": "1|xxxxx..." }, "message": "Registered successfully" }
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
