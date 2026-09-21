# Home Screen Backend Integration Spec

## Scope
This document defines the backend requirements for the Home screen flow:
- main map with nearby active drivers
- route selection (`from` / `to`)
- ride/fare selection
- multi-driver offers (max 3 pending)
- driver accepted / arriving live tracking

---

## End-to-End Flow

1. Home opens.
2. App gets rider current location.
3. App shows nearby active drivers around rider.
4. Rider selects pickup and dropoff.
5. App obtains route distance/ETA and pricing recommendation.
6. Rider selects ride type and fare.
7. Rider submits ride request.
8. Backend sends incoming driver offers (can overlap in time, up to 3 shown in UI).
9. Rider accepts one offer (or declines offers).
10. After accept, backend provides live driver location updates.
11. UI shows driver approaching rider with live ETA/distance.

---

## Required Backend Data Models

## 1) RiderLocation
- `riderId` (string/uuid)
- `lat` (double)
- `lng` (double)
- `heading` (double, optional)
- `speed` (double, optional)
- `updatedAt` (ISO datetime)

## 2) Driver
- `driverId` (string/uuid)
- `name` (string)
- `rating` (double)
- `vehicleType` (enum: `bike`, `mini`, `ac`)
- `vehicleName` (string)
- `vehiclePlate` (string, optional)
- `isOnline` (bool)
- `isAvailable` (bool)
- `location.lat` (double)
- `location.lng` (double)
- `updatedAt` (ISO datetime)

## 3) FareQuote
- `rideType` (enum)
- `currency` (string, e.g. `USD`)
- `baseFare` (number)
- `minimumFare` (number)
- `recommendedFare` (number)
- `surgeMultiplier` (number, optional)
- `validUntil` (ISO datetime, optional)

## 4) RideRequest
- `requestId` (string/uuid)
- `riderId` (string/uuid)
- `pickup.lat` (double)
- `pickup.lng` (double)
- `dropoff.lat` (double)
- `dropoff.lng` (double)
- `rideType` (enum)
- `offeredFare` (number)
- `status` (enum: `searching`, `driver_offered`, `accepted`, `cancelled`, `expired`)
- `createdAt` (ISO datetime)

## 5) DriverOffer
- `offerId` (string/uuid)
- `requestId` (string/uuid)
- `driverId` (string/uuid)
- `driverName` (string)
- `driverRating` (number)
- `vehicleName` (string)
- `driverFare` (number)
- `expiresAt` (ISO datetime)
- `status` (enum: `pending`, `accepted`, `declined`, `expired`)

## 6) Ride
- `rideId` (string/uuid)
- `requestId` (string/uuid)
- `riderId` (string/uuid)
- `driverId` (string/uuid)
- `status` (enum: `driver_arriving`, `ongoing`, `completed`, `cancelled`)
- `driverLocation.lat` (double)
- `driverLocation.lng` (double)
- `etaToPickupSeconds` (int)
- `distanceToPickupMeters` (int)

---

## API Requirements

## A) Location + Nearby Drivers
1. `POST /rider/location`
- Purpose: update rider location.

2. `GET /drivers/nearby?lat={lat}&lng={lng}&radiusKm={radius}&rideType={type}`
- Purpose: fetch available nearby drivers.

## B) Route + Pricing
3. `POST /rides/quote`
- Body:
  - `pickup` (`lat`,`lng`)
  - `dropoff` (`lat`,`lng`)
  - `rideType`
- Response: `FareQuote` + optional distance/eta.

## C) Ride Request + Offer Actions
4. `POST /rides/requests`
- Body:
  - `pickup`, `dropoff`, `rideType`, `offeredFare`
- Response: `RideRequest`

5. `POST /rides/offers/{offerId}/accept`
- Response: accepted offer + created `Ride`.

6. `POST /rides/offers/{offerId}/decline`
- Response: success status.

7. `POST /rides/{rideId}/cancel`
- Response: success status.

---

## Realtime/Event Requirements (Recommended)

Use WebSocket or SSE for live UX.

## Channel: Nearby Drivers
Event: `drivers.nearby.updated`
- Payload:
  - `drivers[]` with `driverId`, availability, and live location
- Frequency: ~3 to 8 seconds, or on meaningful movement.

## Channel: Driver Offers for Request
Event: `ride.offer.created`
- Payload: `DriverOffer`
- Notes:
  - multiple offers may arrive before earlier ones expire
  - include `expiresAt` so client can run local countdown
  - UI supports max 3 pending offers

Event: `ride.offer.expired`
- Payload: `offerId`, `requestId`

## Channel: Ride State (After Accept)
Event: `ride.driver.location`
- Payload:
  - `rideId`
  - `driverLocation`
  - `etaToPickupSeconds`
  - `distanceToPickupMeters`
- Frequency: ~1 to 3 seconds.

Event: `ride.status.changed`
- Payload:
  - `rideId`
  - `status`
  - optional `reason`

---

## Streaming vs Polling Recommendation

Use realtime streaming for:
- nearby active drivers
- incoming driver offers
- offer expiry updates
- accepted driver live location + ride status

Use normal request/response (non-streaming) for:
- fare quotes
- initial ride request creation
- accept/decline/cancel mutations
- profile/payment/history reads

---

## Client Rules Backend Must Support

1. Fare adjustment:
- client can increase/decrease by `0.5`
- client should never go below `minimumFare`

2. Multi-offer behavior:
- offers can overlap in time
- each offer has independent expiry (`expiresAt`)
- client may accept one and decline others
- once accepted, request should lock and remaining offers become invalid

3. Location recenter:
- client may request latest rider location any time
- map should re-center to rider marker

---

## Suggested Error Cases

Provide explicit error codes for:
- `REQUEST_EXPIRED`
- `OFFER_EXPIRED`
- `OFFER_ALREADY_ACCEPTED`
- `DRIVER_UNAVAILABLE`
- `INVALID_FARE_BELOW_MINIMUM`
- `RIDE_ALREADY_CANCELLED`

---

## Minimal Example Event Payloads

```json
{
  "event": "ride.offer.created",
  "data": {
    "offerId": "off_123",
    "requestId": "req_001",
    "driverId": "drv_09",
    "driverName": "Sergio Ramasis",
    "driverRating": 4.9,
    "vehicleName": "Toyota Prius",
    "driverFare": 12.5,
    "expiresAt": "2026-02-25T12:30:15Z",
    "status": "pending"
  }
}
```

```json
{
  "event": "ride.driver.location",
  "data": {
    "rideId": "ride_771",
    "driverLocation": { "lat": 37.7782, "lng": -122.4221 },
    "etaToPickupSeconds": 185,
    "distanceToPickupMeters": 820
  }
}
```

---

## Summary
To support the current Home screen UX reliably, backend should provide:
- location-aware nearby driver feed
- quote endpoint with min/recommended/base fare
- ride request lifecycle
- multi-offer realtime events with per-offer expiry
- post-accept live driver tracking stream

