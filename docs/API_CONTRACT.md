# Food Surplus API — Contract (living document)

Base URL (local): `http://127.0.0.1:8000/api`
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

## Next up (not built yet)
Donor: create/list/show/cancel donation request · Charity: available requests + accept · QR confirm · distribute · no-show/strikes · admin · stats.
This section will be updated the moment each slice is done — this file is the single source of truth for the contract, matching the team plan's "API First" rule. Do not hand-build request shapes from memory; check here first.
