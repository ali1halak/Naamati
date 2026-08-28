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

### `POST /api/register/donor`
Creates a donor account.

Body:
```json
{
  "account_type": "donor",
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

### `POST /api/register/charity`
Creates a charity account.

Body:
```json
{
  "account_type": "charity",
  "name": "Al-Birr Charity",
  "email": "charity@test.com",
  "phone": "0911111111",
  "password": "password123",
  "password_confirmation": "password123",
  "has_kitchen": true,
  "address": "Aleppo - Al-Furqan",
  "work_start": "08:00",
  "work_end": "16:00",
  "license_document": null
}
```
Success `201`:
```json
{ "success": true, "data": { "type": "charity", "user": { "id": 2, "name": "Al-Birr Charity", "email": "charity@test.com", "phone": "0911111111", "has_kitchen": true, "address": "Aleppo - Al-Furqan", "work_start": "08:00:00", "work_end": "16:00:00", "license_document": null }, "token": "2|xxxxx..." }, "message": "Registered successfully" }
```
Errors: `422` if email taken / fields invalid.

> Backward compatibility: `POST /api/register` still works as a donor registration alias.

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
