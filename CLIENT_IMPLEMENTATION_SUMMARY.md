# Draaxi Home Flow Implementation Summary (Rider + Driver)

This document summarizes what was implemented in the Flutter apps and what is expected from the backend to complete the end-to-end Home booking experience.

## Scope

We implemented the rider Home screen flow with a map-first UI, bottom-sheet booking steps, live backend integration, and multi-offer handling. We also fixed a driver-side filtering issue that was preventing backend requests from appearing in the driver app UI.

## Rider App: Implemented UX Flow

UI flow:

Main UI -> Choose To and From -> Choose Ride + Fare -> Search/Select Driver Offers -> Accept Driver -> Driver Coming (bottom sheet)

Back navigation:

- Top-left back arrow and Android system back follow the same state machine:
  - Select Driver -> back to Choose Ride/Fare
  - Choose Ride/Fare -> back to Main UI
  - Driver Coming -> exits to Main UI (current behavior)

## Rider App: Map Behavior

- Map displays only backend-provided active nearby drivers around the rider when in the main/original state.
- If backend returns no nearby drivers, UI shows a small chip: "No active drivers nearby".
- Custom rider marker remains pinned to the rider location (not forced to the map center).
- Recenter button recenters the map to the rider marker.

## Rider App: Bottom Sheets and Overlays

- Booking steps are presented in a bottom sheet (ride type, fare selection, searching state).
- Driver offers are presented as floating cards (supports up to 3 concurrent offers).
- After confirming/accepting a driver, the "driver coming" UI is shown in a collapsible bottom sheet (car marker + route line on map + driver details).

## Rider App: Backend Integration (API-First)

All rider API calls are implemented with detailed logging:

- request headers/body (token masked)
- response status/body

Primary endpoints used:

- `POST /rider/location`
- `GET /rider/location/current`
- `GET /rider/drivers/nearby`
- `POST /rides/quote`
- `POST /rides/requests`
- `GET /rides/requests/{requestId}/status`
- `POST /rides/offers/{offerId}/accept`
- `POST /rides/offers/{offerId}/decline`
- `POST /rides/requests/{requestId}/cancel`
- `POST /rides/{rideId}/cancel`

Key behavior:

- Ride requests are created only when the user presses "Request ride" (not on route selection).
- The app polls request status every ~3 seconds while searching for offers.
- Stale server-side "active request exists" cases are handled:
  - if the server returns an already-expired `expires_at`, the client cancels and retries once
  - otherwise it continues polling the existing request id

## Rider App: Offer Handling Rules

- Incoming offers from the backend are parsed using UUID/string ids (request/offer/ride).
- The rider UI shows floating driver-offer cards only for offers intended to be rider-selectable.
  - We treat these as "driver accepted/offered/confirmed" style statuses (backend contract dependent).
- Pending offers can still exist on the backend but are not displayed as selectable cards unless the backend marks them as rider-selectable.

Accept flow:

- On accept, the app uses the accept API response immediately to open the accepted-driver bottom sheet.
- This avoids reliance on `accepted_offer` being present in the next status polling response.

Cancel flow:

- Cancel request uses `POST /rides/requests/{requestId}/cancel`.
- Client handles empty bodies / non-JSON success responses safely.
- If request is already cancelled, UI still resets cleanly.

## Rider App: Driver Approaching Pickup

Current behavior:

- The app uses real driver coordinates if the backend provides them (in accept/status payloads).
- If live coordinates are not provided, the app uses the driver's last known backend location (from nearby drivers) and periodically refreshes positions from backend instead of simulating a fake movement path.

## Driver App: Fix Applied

Fix:

- Requests are no longer filtered out by a narrow 2-3 km dropoff rule.
- Pending backend requests can now appear in the driver UI (up to 3 visible cards as designed).

## Files Updated (Flutter)

Rider app:

- `lib/src/features/home/home_screen.dart`
- `lib/src/features/home/rider_api_repository.dart`

Driver app:

- `/Users/alinawab/Flutter Tasks/DRAAXI_DRIVER/lib/src/features/home/screens/home_screen.dart`

## Backend Requirements / Remaining Work

To complete the full "driver coming" live tracking experience (without fallbacks), backend should provide one of:

1. A ride-tracking endpoint/event after accept that streams:
   - `driver_location.lat`
   - `driver_location.lng`
   - `eta_to_pickup_seconds`
   - `distance_to_pickup_meters`

2. Or include the same fields in:
   - `POST /rides/offers/{offerId}/accept` response, and/or
   - `GET /rides/requests/{requestId}/status` when `status=accepted`

Additionally recommended:

- When request `status=accepted`, return `accepted_offer` in request status so the client can restore state on app restart without relying on the immediate accept response.

## Remaining Milestones (Not Implemented Yet)

These are the major remaining product milestones after the current "driver coming" state.

- Start ride + pickup reached
  - Driver taps "Reached pickup" / "Start ride"
  - Rider UI updates to trip-in-progress state
  - Backend must expose ride phase transitions (pickup reached, ride started)
- Trip to destination (live tracking)
  - Driver live location updates during the ride
  - Rider map shows route + remaining ETA/distance to dropoff
  - Ride status updates: `ongoing` -> `completed` (and cancellation handling)
- Ride completion + receipt
  - Final fare/receipt payload on completion (base + adjustments + promotions + fees if any)
  - Post-ride rating/review flow (rider rates driver; optional feedback)
- Wallet / payment methods
  - Store and manage payment methods (card list/add/remove/default)
  - Wallet balance (if supported) and transaction ledger
  - Refunds/adjustments for cancelled rides (if required)
- Ride history
  - Rider trip history list with filters/status
  - Trip details screen (route, fare breakdown, timestamps, driver info)
  - Support re-booking from previous trips (optional)
- Notifications + realtime robustness (polish)
  - Push/in-app notifications for ride status changes
  - Background/foreground handling: resume state from backend after app restart
  - Offline/retry strategy for polling/streaming failures

## Current Assumptions

- IDs can be UUID strings for `request_id`, `offer_id`, `ride_id`.
- Nearby drivers API returns fields such as `latitude`, `longitude`, `driver_name`, `vehicle_type`, `vehicle_no`, `vehicle_description`.
- Offer status values and request status values must match what the client expects for:
  - "selectable driver offer" vs "pending offer"
  - accepted vs cancelled vs expired
