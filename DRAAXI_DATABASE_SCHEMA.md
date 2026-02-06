# Ride-Sharing App Database Schema

## Comprehensive Database Design for DRAAXI Client-

## Admin App

## Overview

This document outlines the complete database schema for a ride-sharing appli-
cation similar to Uber, including all necessary tables, relationships, indexes, and
constraints.

## Database Design Principles

- **Normalization** : Third Normal Form (3NF) to minimize redundancy
- **Scalability** : Designed to handle high-volume transactions
- **Performance** : Optimized indexes for frequent queries
- **Security** : Encrypted sensitive data fields
- **Audit Trail** : Timestamps and soft deletes for all critical tables

## Core Tables

**1. Users Table
Purpose** : Store all user accounts (Riders, Drivers, Admins)
**CREATETABLE** users (
    **id** BIGSERIAL **PRIMARYKEY** ,
    uuidVARCHAR( 36 ) **UNIQUENOTNULL** ,
    emailVARCHAR( 255 ) **UNIQUE NOTNULL** ,
    phone_numberVARCHAR( 20 ) **UNIQUE NOTNULL** ,
    password_hashVARCHAR( 255 ) **NOTNULL** ,
    user_type ENUM('rider','driver', 'admin') **NOTNULL** ,
    first_nameVARCHAR( 100 ),
    last_nameVARCHAR( 100 ),
    profile_image_url TEXT,
    date_of_birthDATE,
    gender ENUM('male','female', 'other', 'prefer_not_to_say'),

```
-- Verification
email_verifiedBOOLEAN DEFAULTFALSE ,
phone_verifiedBOOLEAN DEFAULTFALSE ,
is_activeBOOLEAN DEFAULTTRUE ,
```

```
is_approvedBOOLEAN DEFAULTFALSE , -- For drivers
```
```
-- Location
current_latitudeDECIMAL( 10 , 8 ),
current_longitudeDECIMAL( 11 , 8 ),
current_address TEXT,
last_location_updateTIMESTAMP,
```
```
-- Rating
average_ratingDECIMAL( 3 , 2 ) DEFAULT 0.00,
total_ratingsINT DEFAULT 0 ,
```
```
-- Financial
wallet_balanceDECIMAL( 10 , 2 ) DEFAULT 0.00,
currencyVARCHAR( 3 ) DEFAULT 'USD',
```
```
-- Status
is_onlineBOOLEAN DEFAULTFALSE , -- For drivers
last_active_atTIMESTAMP,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
deleted_atTIMESTAMP NULL ,
```
_-- Indexes_
**INDEX** idx_user_type (user_type),
**INDEX** idx_email (email),
**INDEX** idx_phone (phone_number),
**INDEX** idx_uuid (uuid),
**INDEX** idx_is_active (is_active),
**INDEX** idx_location (current_latitude, current_longitude)
);

**2. Drivers Table**

**Purpose** : Extended information for drivers only

**CREATETABLE** drivers (
**id** BIGSERIAL **PRIMARYKEY** ,
user_id BIGINT **UNIQUE NOTNULL** ,
driver_license_numberVARCHAR( 100 ) **UNIQUENOTNULL** ,
license_expiry_dateDATE **NOTNULL** ,
license_stateVARCHAR( 50 ),
license_image_url TEXT,


```
-- Background Check
background_check_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
background_check_dateTIMESTAMP,
criminal_record_clearBOOLEAN DEFAULTFALSE ,
```
```
-- Documents
insurance_document_url TEXT,
registration_document_url TEXT,
```
```
-- Vehicle Assignment
current_vehicle_id BIGINT,
```
```
-- Status
driver_status ENUM('offline', 'available', 'busy','on_ride','suspended') DEFAULT 'offline',
is_approvedBOOLEAN DEFAULTFALSE ,
approval_dateTIMESTAMP,
rejection_reason TEXT,
```
```
-- Earnings
total_earningsDECIMAL( 10 , 2 ) DEFAULT 0.00,
total_ridesINT DEFAULT 0 ,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE CASCADE ,
FOREIGNKEY (current_vehicle_id) REFERENCES vehicles( id ) ON DELETESETNULL ,
```
**INDEX** idx_user_id (user_id),
**INDEX** idx_driver_status (driver_status),
**INDEX** idx_is_approved (is_approved)
);

**3. Vehicles Table**

**Purpose** : Store vehicle information for drivers

**CREATETABLE** vehicles (
**id** BIGSERIAL **PRIMARYKEY** ,
driver_id BIGINT **NOTNULL** ,

```
-- Vehicle Details
makeVARCHAR( 100 ) NOTNULL ,
```

```
modelVARCHAR( 100 ) NOTNULL ,
yearINT NOTNULL ,
colorVARCHAR( 50 ),
license_plateVARCHAR( 20 ) UNIQUENOTNULL ,
vehicle_type ENUM('economy','comfort', 'premium','luxury', 'xl','suv') NOTNULL ,
```
```
-- Documentation
registration_numberVARCHAR( 100 ),
registration_expiryDATE,
insurance_numberVARCHAR( 100 ),
insurance_expiryDATE,
insurance_providerVARCHAR( 100 ),
```
```
-- Images
vehicle_image_url TEXT,
registration_image_url TEXT,
insurance_image_url TEXT,
```
```
-- Status
is_verifiedBOOLEAN DEFAULTFALSE ,
is_activeBOOLEAN DEFAULTTRUE ,
verification_dateTIMESTAMP,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (driver_id) REFERENCES drivers( id ) ONDELETE CASCADE ,
```
**INDEX** idx_driver_id (driver_id),
**INDEX** idx_vehicle_type (vehicle_type),
**INDEX** idx_is_active (is_active)
);

**4. Rides Table**

**Purpose** : Store all ride bookings and their details

**CREATETABLE** rides (
**id** BIGSERIAL **PRIMARYKEY** ,
ride_uuidVARCHAR( 36 ) **UNIQUENOTNULL** ,

```
-- Participants
rider_id BIGINT NOTNULL ,
driver_id BIGINT,
```

_-- Vehicle_
vehicle_id BIGINT,

_-- Pickup Location_
pickup_latitudeDECIMAL( 10 , 8 ) **NOTNULL** ,
pickup_longitudeDECIMAL( 11 , 8 ) **NOTNULL** ,
pickup_address TEXT **NOTNULL** ,
pickup_instructions TEXT,

_-- Dropoff Location_
dropoff_latitudeDECIMAL( 10 , 8 ) **NOTNULL** ,
dropoff_longitudeDECIMAL( 11 , 8 ) **NOTNULL** ,
dropoff_address TEXT **NOTNULL** ,
dropoff_instructions TEXT,

_-- Route_
estimated_distanceDECIMAL( 10 , 2 ), _-- in kilometers_
actual_distanceDECIMAL( 10 , 2 ),
estimated_durationINT, _-- in minutes_
actual_durationINT,
route_polyline TEXT, _-- Encoded polyline for route_

_-- Pricing_
base_fareDECIMAL( 10 , 2 ) **NOTNULL** ,
distance_fareDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
time_fareDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
surge_multiplierDECIMAL( 3 , 2 ) **DEFAULT** 1.00,
toll_feeDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
waiting_feeDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
cancellation_feeDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
tip_amountDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
total_fareDECIMAL( 10 , 2 ) **NOTNULL** ,
platform_feeDECIMAL( 10 , 2 ) **NOTNULL** ,
driver_earningsDECIMAL( 10 , 2 ) **NOTNULL** ,
currencyVARCHAR( 3 ) **DEFAULT** 'USD',

_-- Payment_
payment_method ENUM('cash','card','wallet','corporate') **NOTNULL** ,
payment_status ENUM('pending', 'completed', 'failed','refunded') **DEFAULT** 'pending',
payment_id BIGINT,

_-- Status_
ride_status ENUM(
'pending', _-- Ride requested, waiting for driver_
'accepted', _-- Driver accepted the ride_


```
'driver_arrived', -- Driver arrived at pickup
'in_progress', -- Ride in progress
'completed', -- Ride completed
'cancelled', -- Ride cancelled
'no_show' -- Driver or rider didn't show up
) DEFAULT 'pending',
```
```
-- Timestamps
requested_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
accepted_atTIMESTAMP,
driver_arrived_atTIMESTAMP,
started_atTIMESTAMP,
completed_atTIMESTAMP,
cancelled_atTIMESTAMP,
cancellation_reason TEXT,
```
```
-- Ratings
rider_ratingINT CHECK (rider_rating>= 1 AND rider_rating<= 5 ),
driver_ratingINT CHECK (driver_rating >= 1 AND driver_rating<= 5 ),
rider_review TEXT,
driver_review TEXT,
```
```
-- Additional Info
ride_type ENUM('economy', 'comfort','premium', 'luxury','xl','suv') NOTNULL ,
special_requests TEXT,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (rider_id) REFERENCES users( id ) ON DELETERESTRICT ,
FOREIGNKEY (driver_id) REFERENCES drivers( id ) ONDELETE SETNULL ,
FOREIGNKEY (vehicle_id) REFERENCES vehicles( id ) ON DELETESETNULL ,
FOREIGNKEY (payment_id) REFERENCES payments( id ) ON DELETESETNULL ,
```
**INDEX** idx_rider_id (rider_id),
**INDEX** idx_driver_id (driver_id),
**INDEX** idx_ride_status (ride_status),
**INDEX** idx_requested_at (requested_at),
**INDEX** idx_ride_uuid (ride_uuid),
**INDEX** idx_payment_status (payment_status)
);


**5. Ride Requests Table**

**Purpose** : Track ride requests and driver matching

**CREATETABLE** ride_requests (
**id** BIGSERIAL **PRIMARYKEY** ,
ride_id BIGINT **NOTNULL** ,

```
-- Request Details
requested_vehicle_type ENUM('economy', 'comfort','premium', 'luxury','xl','suv'),
surge_multiplierDECIMAL( 3 , 2 ) DEFAULT 1.00,
```
```
-- Driver Matching
matched_driver_id BIGINT,
driver_assigned_atTIMESTAMP,
driver_etaINT, -- Estimated time of arrival in minutes
```
```
-- Status
status ENUM('searching','matched','accepted', 'expired','cancelled') DEFAULT 'searching',
expires_atTIMESTAMP,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE CASCADE ,
FOREIGNKEY (matched_driver_id) REFERENCES drivers( id ) ON DELETE SETNULL ,
```
**INDEX** idx_ride_id (ride_id),
**INDEX** idx_status (status),
**INDEX** idx_matched_driver (matched_driver_id)
);

**6. Deliveries Table**

**Purpose** : Store all delivery bookings and their details

**CREATETABLE** deliveries (
**id** BIGSERIAL **PRIMARYKEY** ,
delivery_uuidVARCHAR( 36 ) **UNIQUENOTNULL** ,

```
-- Participants
sender_id BIGINT NOTNULL , -- User who requested the delivery
driver_id BIGINT,
```

_-- Vehicle_
vehicle_id BIGINT,

_-- Pickup Location_
pickup_latitudeDECIMAL( 10 , 8 ) **NOTNULL** ,
pickup_longitudeDECIMAL( 11 , 8 ) **NOTNULL** ,
pickup_address TEXT **NOTNULL** ,
pickup_instructions TEXT,
pickup_contact_nameVARCHAR( 100 ),
pickup_contact_phoneVARCHAR( 20 ),

_-- Delivery Location_
delivery_latitudeDECIMAL( 10 , 8 ) **NOTNULL** ,
delivery_longitudeDECIMAL( 11 , 8 ) **NOTNULL** ,
delivery_address TEXT **NOTNULL** ,
delivery_instructions TEXT,
recipient_nameVARCHAR( 100 ) **NOTNULL** ,
recipient_phoneVARCHAR( 20 ) **NOTNULL** ,

_-- Item Details_
item_description TEXT,
item_category ENUM('food', 'groceries', 'documents', 'parcel', 'medicine', 'other') **NOTNULL** ,
item_weightDECIMAL( 5 , 2 ), -- in kilograms
item_valueDECIMAL( 10 , 2 ), -- declared value for insurance
fragileBOOLEAN DEFAULTFALSE ,
requires_signatureBOOLEAN DEFAULTFALSE ,

_-- Route_
estimated_distanceDECIMAL( 10 , 2 ), _-- in kilometers_
actual_distanceDECIMAL( 10 , 2 ),
estimated_durationINT, _-- in minutes_
actual_durationINT,
route_polyline TEXT, _-- Encoded polyline for route_

_-- Pricing_
base_fareDECIMAL( 10 , 2 ) **NOTNULL** ,
distance_fareDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
time_fareDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
weight_fareDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
surge_multiplierDECIMAL( 3 , 2 ) **DEFAULT** 1.00,
insurance_feeDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
waiting_feeDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
cancellation_feeDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
tip_amountDECIMAL( 10 , 2 ) **DEFAULT** 0.00,
total_fareDECIMAL( 10 , 2 ) **NOTNULL** ,
platform_feeDECIMAL( 10 , 2 ) **NOTNULL** ,
driver_earningsDECIMAL( 10 , 2 ) **NOTNULL** ,
currencyVARCHAR( 3 ) **DEFAULT** 'USD',

_-- Payment_
payment_method ENUM('cash','card','wallet','corporate') **NOTNULL** ,
payment_status ENUM('pending', 'completed', 'failed','refunded') **DEFAULT** 'pending',
payment_id BIGINT,

_-- Status_
delivery_status ENUM(
'pending', _-- Delivery requested, waiting for driver_
'accepted', _-- Driver accepted the delivery_
'driver_arrived_pickup', -- Driver arrived at pickup location
'picked_up', -- Item picked up from sender
'in_transit', -- Delivery in progress
'driver_arrived_delivery', -- Driver arrived at delivery location
'completed', -- Delivery completed
'cancelled', -- Delivery cancelled
'failed' -- Delivery failed (item lost, damaged, etc.)
) DEFAULT 'pending',
```

_-- Timestamps_
requested_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
accepted_atTIMESTAMP,
driver_arrived_pickup_atTIMESTAMP,
picked_up_atTIMESTAMP,
in_transit_atTIMESTAMP,
driver_arrived_delivery_atTIMESTAMP,
completed_atTIMESTAMP,
cancelled_atTIMESTAMP,
```

_-- Ratings_
sender_ratingINT CHECK (sender_rating>= 1 AND sender_rating<= 5 ),
recipient_ratingINT CHECK (recipient_rating >= 1 AND recipient_rating<= 5 ),
driver_ratingINT CHECK (driver_rating >= 1 AND driver_rating<= 5 ),
sender_review TEXT,
recipient_review TEXT,
driver_review TEXT,
```

_-- Additional Info_
delivery_type ENUM('standard', 'express', 'scheduled') **NOTNULL** DEFAULT 'standard',
scheduled_pickup_timeTIMESTAMP,
scheduled_delivery_timeTIMESTAMP,
special_requests TEXT,
delivery_proof_url TEXT, -- Photo of delivered item
signature_url TEXT, -- Digital signature if required
```

_-- Metadata_
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```

```
FOREIGNKEY (sender_id) REFERENCES users( id ) ON DELETERESTRICT ,
FOREIGNKEY (driver_id) REFERENCES drivers( id ) ONDELETE SETNULL ,
FOREIGNKEY (vehicle_id) REFERENCES vehicles( id ) ON DELETESETNULL ,
FOREIGNKEY (payment_id) REFERENCES payments( id ) ON DELETESETNULL ,
```
**INDEX** idx_sender_id (sender_id),
**INDEX** idx_driver_id (driver_id),
**INDEX** idx_delivery_status (delivery_status),
**INDEX** idx_requested_at (requested_at),
**INDEX** idx_delivery_uuid (delivery_uuid),
**INDEX** idx_payment_status (payment_status),
**INDEX** idx_item_category (item_category),
**INDEX** idx_delivery_type (delivery_type)
);


**7. Delivery Requests Table**

**Purpose** : Track delivery requests and driver matching

**CREATETABLE** delivery_requests (
**id** BIGSERIAL **PRIMARYKEY** ,
delivery_id BIGINT **NOTNULL** ,

```
-- Request Details
requested_vehicle_type ENUM('economy', 'comfort','premium', 'luxury','xl','suv'),
surge_multiplierDECIMAL( 3 , 2 ) DEFAULT 1.00,
```

```
-- Driver Matching
matched_driver_id BIGINT,
driver_assigned_atTIMESTAMP,
driver_etaINT, -- Estimated time of arrival in minutes
```

```
-- Status
status ENUM('searching','matched','accepted', 'expired','cancelled') DEFAULT 'searching',
expires_atTIMESTAMP,
```

```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```

```
FOREIGNKEY (delivery_id) REFERENCES deliveries( id ) ONDELETE CASCADE ,
FOREIGNKEY (matched_driver_id) REFERENCES drivers( id ) ON DELETE SETNULL ,
```
**INDEX** idx_delivery_id (delivery_id),
**INDEX** idx_status (status),
**INDEX** idx_matched_driver (matched_driver_id)
);

**8. Payments Table**

**Purpose** : Store all payment transactions

**CREATETABLE** payments (
**id** BIGSERIAL **PRIMARYKEY** ,
payment_uuidVARCHAR( 36 ) **UNIQUE NOTNULL** ,
ride_id BIGINT, _-- NULL if payment is for delivery_
delivery_id BIGINT, _-- NULL if payment is for ride_
user_id BIGINT **NOTNULL** , _-- User who made payment (rider or sender)_

```
-- Payment Details
amountDECIMAL( 10 , 2 ) NOTNULL ,
currencyVARCHAR( 3 ) DEFAULT 'USD',
```

```
payment_method ENUM('cash','card','wallet','corporate') NOTNULL ,
```
```
-- Card Payment
card_last_fourVARCHAR( 4 ),
card_brandVARCHAR( 50 ), -- visa, mastercard, etc.
card_tokenVARCHAR( 255 ), -- Encrypted token
```
```
-- Payment Gateway
gateway_transaction_idVARCHAR( 255 ),
gateway_nameVARCHAR( 50 ), -- stripe, paypal, etc.
gateway_response TEXT, -- JSON response from gateway
```
```
-- Status
payment_status ENUM('pending', 'processing','completed','failed','refunded','cancelled') DEFAULT 'pending',
failure_reason TEXT,
```
```
-- Refund
refund_amountDECIMAL( 10 , 2 ) DEFAULT 0.00,
refund_reason TEXT,
refunded_atTIMESTAMP,
```
```
-- Timestamps
processed_atTIMESTAMP,
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE RESTRICT ,
FOREIGNKEY (delivery_id) REFERENCES deliveries( id ) ONDELETE RESTRICT ,
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE RESTRICT ,
```
**INDEX** idx_ride_id (ride_id),
**INDEX** idx_delivery_id (delivery_id),
**INDEX** idx_user_id (user_id),
**INDEX** idx_payment_status (payment_status),
**INDEX** idx_gateway_transaction_id (gateway_transaction_id)
);

**9. Addresses Table**

**Purpose** : Store saved addresses for users (home, work, etc.)

**CREATETABLE** addresses (
**id** BIGSERIAL **PRIMARYKEY** ,
user_id BIGINT **NOTNULL** ,

```
-- Address Details
address_type ENUM('home', 'work', 'other', 'favorite') NOTNULL ,
```

```
label VARCHAR( 100 ), -- e.g., "Home", "Office", "Mom's House"
address_line1 TEXT NOTNULL ,
address_line2 TEXT,
cityVARCHAR( 100 ) NOTNULL ,
stateVARCHAR( 100 ),
postal_codeVARCHAR( 20 ),
countryVARCHAR( 100 ) NOTNULL ,
```
```
-- Coordinates
latitudeDECIMAL( 10 , 8 ) NOTNULL ,
longitudeDECIMAL( 11 , 8 ) NOTNULL ,
```
```
-- Additional Info
instructions TEXT, -- Gate code, building name, etc.
is_defaultBOOLEAN DEFAULTFALSE ,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
deleted_atTIMESTAMP NULL ,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE CASCADE ,
```
**INDEX** idx_user_id (user_id),
**INDEX** idx_address_type (address_type),
**INDEX** idx_location (latitude, longitude)
);

**10. Ratings Table**

**Purpose** : Store detailed ratings and reviews

**CREATETABLE** ratings (
**id** BIGSERIAL **PRIMARYKEY** ,
ride_id BIGINT, _-- NULL if rating is for delivery_
delivery_id BIGINT, _-- NULL if rating is for ride_
rated_by_user_id BIGINT **NOTNULL** , _-- User who gave the rating_
rated_user_id BIGINT **NOTNULL** , _-- User who received the rating (driver, rider, sender, or recipient)_

```
-- Rating Details
ratingINT NOTNULLCHECK (rating>= 1 AND rating<= 5 ),
review_text TEXT,
```
```
-- Detailed Ratings (for drivers)
punctuality_ratingINT CHECK (punctuality_rating >= 1 AND punctuality_rating<= 5 ),
cleanliness_ratingINT CHECK (cleanliness_rating >= 1 AND cleanliness_rating<= 5 ),
```

```
driving_ratingINT CHECK (driving_rating >= 1 AND driving_rating <= 5 ),
communication_ratingINT CHECK (communication_rating>= 1 AND communication_rating<= 5 ),
```
```
-- Tags
tags TEXT, -- JSON array of tags like ["polite", "fast", "clean"]
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE CASCADE ,
FOREIGNKEY (delivery_id) REFERENCES deliveries( id ) ONDELETE CASCADE ,
FOREIGNKEY (rated_by_user_id) REFERENCES users( id ) ONDELETE RESTRICT ,
FOREIGNKEY (rated_user_id) REFERENCES users( id ) ON DELETERESTRICT ,
```
**UNIQUEKEY** unique_rating_ride (ride_id, rated_by_user_id, rated_user_id),
**UNIQUEKEY** unique_rating_delivery (delivery_id, rated_by_user_id, rated_user_id),
**INDEX** idx_rated_user_id (rated_user_id),
**INDEX** idx_rating (rating)
);

**11. Promotions Table**

**Purpose** : Store promotional codes and discounts

**CREATETABLE** promotions (
**id** BIGSERIAL **PRIMARYKEY** ,
codeVARCHAR( 50 ) **UNIQUENOTNULL** ,
titleVARCHAR( 255 ) **NOTNULL** ,
description TEXT,

```
-- Discount Details
discount_type ENUM('percentage','fixed_amount','free_ride') NOTNULL ,
discount_valueDECIMAL( 10 , 2 ) NOTNULL ,
max_discount_amountDECIMAL( 10 , 2 ), -- For percentage discounts
min_ride_amountDECIMAL( 10 , 2 ) DEFAULT 0.00,
```
```
-- Usage Limits
max_usesINT, -- Total number of times this promo can be used
max_uses_per_userINT DEFAULT 1 ,
current_usesINT DEFAULT 0 ,
```
```
-- Validity
valid_fromTIMESTAMP NOTNULL ,
valid_untilTIMESTAMP NOTNULL ,
is_activeBOOLEAN DEFAULTTRUE ,
```

```
-- Applicability
applicable_vehicle_types TEXT, -- JSON array
applicable_ride_types TEXT, -- JSON array
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
**INDEX** idx_code (code),
**INDEX** idx_validity (valid_from, valid_until),
**INDEX** idx_is_active (is_active)
);

**12. User Promotions Table**

**Purpose** : Track which users have used which promotions

**CREATETABLE** user_promotions (
**id** BIGSERIAL **PRIMARYKEY** ,
user_id BIGINT **NOTNULL** ,
promotion_id BIGINT **NOTNULL** ,
ride_id BIGINT,

```
discount_amountDECIMAL( 10 , 2 ) NOTNULL ,
used_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE CASCADE ,
FOREIGNKEY (promotion_id) REFERENCES promotions( id ) ON DELETERESTRICT ,
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE SETNULL ,
```
**UNIQUEKEY** unique_user_promo_ride (user_id, promotion_id, ride_id),
**INDEX** idx_user_id (user_id),
**INDEX** idx_promotion_id (promotion_id)
);

**13. Notifications Table**

**Purpose** : Store all notifications for users

**CREATETABLE** notifications (
**id** BIGSERIAL **PRIMARYKEY** ,
user_id BIGINT **NOTNULL** ,

```
-- Notification Details
```

```
notification_type ENUM(
'ride_requested',
'ride_accepted',
'driver_arrived',
'ride_started',
'ride_completed',
'ride_cancelled',
'payment_received',
'payment_failed',
'promotion',
'system',
'driver_approval',
'document_verification'
) NOTNULL ,
```
```
titleVARCHAR( 255 ) NOTNULL ,
message TEXT NOTNULL ,
```
```
-- Related Entity
related_entity_type ENUM('ride','payment', 'promotion', 'driver','vehicle') NULL ,
related_entity_id BIGINT NULL ,
```
```
-- Status
is_readBOOLEAN DEFAULTFALSE ,
read_atTIMESTAMP,
```
```
-- Push Notification
push_sentBOOLEAN DEFAULTFALSE ,
push_sent_atTIMESTAMP,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE CASCADE ,
```
**INDEX** idx_user_id (user_id),
**INDEX** idx_is_read (is_read),
**INDEX** idx_notification_type (notification_type),
**INDEX** idx_created_at (created_at)
);

**14. Documents Table**

**Purpose** : Store uploaded documents (driver licenses, vehicle documents, etc.)


**CREATETABLE** documents (
**id** BIGSERIAL **PRIMARYKEY** ,
user_id BIGINT **NOTNULL** ,
driver_id BIGINT, _-- NULL if document is for rider_

```
-- Document Details
document_type ENUM(
'driver_license',
'vehicle_registration',
'insurance',
'profile_photo',
'vehicle_photo',
'identity_proof',
'other'
) NOTNULL ,
```
```
document_nameVARCHAR( 255 ) NOTNULL ,
document_url TEXT NOTNULL ,
file_size BIGINT, -- in bytes
mime_typeVARCHAR( 100 ),
```
```
-- Verification
verification_status ENUM('pending','approved', 'rejected') DEFAULT 'pending',
verified_by BIGINT, -- Admin user ID
verified_atTIMESTAMP,
rejection_reason TEXT,
```
```
-- Expiry
expiry_dateDATE,
```
```
-- Metadata
uploaded_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE CASCADE ,
FOREIGNKEY (driver_id) REFERENCES drivers( id ) ONDELETE CASCADE ,
FOREIGNKEY (verified_by) REFERENCES users( id ) ONDELETE SETNULL ,
```
**INDEX** idx_user_id (user_id),
**INDEX** idx_driver_id (driver_id),
**INDEX** idx_document_type (document_type),
**INDEX** idx_verification_status (verification_status)
);


**15. Ride Locations Table**

**Purpose** : Track real-time location updates during a ride

**CREATETABLE** ride_locations (
**id** BIGSERIAL **PRIMARYKEY** ,
ride_id BIGINT **NOTNULL** ,

```
-- Location
latitudeDECIMAL( 10 , 8 ) NOTNULL ,
longitudeDECIMAL( 11 , 8 ) NOTNULL ,
accuracyDECIMAL( 10 , 2 ), -- in meters
headingDECIMAL( 5 , 2 ), -- compass direction in degrees
speedDECIMAL( 5 , 2 ), -- in km/h
```
```
-- Timestamp
recorded_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE CASCADE ,
```
**INDEX** idx_ride_id (ride_id),
**INDEX** idx_recorded_at (recorded_at)
);

**16. Cancellations Table**

**Purpose** : Track cancellation details and reasons for rides and deliveries

**CREATETABLE** cancellations (
**id** BIGSERIAL **PRIMARYKEY** ,
ride_id BIGINT, _-- NULL if cancellation is for delivery_
delivery_id BIGINT, _-- NULL if cancellation is for ride_

```
-- Cancellation Details
cancelled_by ENUM('rider', 'sender', 'driver','system') NOTNULL ,
cancelled_by_user_id BIGINT NOTNULL ,
```
```
cancellation_reason ENUM(
'driver_not_found',
'driver_too_far',
'rider_not_found',
'sender_not_found',
'recipient_not_found',
'changed_mind',
'wrong_destination',
'wrong_delivery_address',
'item_not_ready',
'item_damaged',
'emergency',
'payment_failed',
'vehicle_issue',
'other'
```

### ) NOTNULL ,

```
cancellation_note TEXT,
```
```
-- Penalty
penalty_appliedBOOLEAN DEFAULTFALSE ,
penalty_amountDECIMAL( 10 , 2 ) DEFAULT 0.00,
```
```
-- Timestamps
cancelled_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE CASCADE ,
FOREIGNKEY (delivery_id) REFERENCES deliveries( id ) ONDELETE CASCADE ,
FOREIGNKEY (cancelled_by_user_id) REFERENCES users( id ) ONDELETE RESTRICT ,
```
**INDEX** idx_ride_id (ride_id),
**INDEX** idx_delivery_id (delivery_id),
**INDEX** idx_cancelled_by (cancelled_by),
**INDEX** idx_cancelled_at (cancelled_at)
);

**17. Wallet Transactions Table**

**Purpose** : Track all wallet transactions (top-ups, withdrawals, ride payments, delivery payments)

**CREATETABLE** wallet_transactions (
**id** BIGSERIAL **PRIMARYKEY** ,
user_id BIGINT **NOTNULL** ,

```
-- Transaction Details
transaction_type ENUM('credit','debit') NOTNULL ,
transaction_category ENUM(
'top_up',
'ride_payment',
'delivery_payment',
'refund',
'withdrawal',
'bonus',
'penalty',
'adjustment'
) NOTNULL ,
```
```
amountDECIMAL( 10 , 2 ) NOTNULL ,
currencyVARCHAR( 3 ) DEFAULT 'USD',
balance_beforeDECIMAL( 10 , 2 ) NOTNULL ,
balance_afterDECIMAL( 10 , 2 ) NOTNULL ,
```
```
-- Related Entity
```

```
related_ride_id BIGINT,
related_delivery_id BIGINT,
related_payment_id BIGINT,
```
```
-- Description
description TEXT,
```
```
-- Status
status ENUM('pending','completed','failed','cancelled') DEFAULT 'pending',
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE RESTRICT ,
FOREIGNKEY (related_ride_id) REFERENCES rides( id ) ON DELETE SETNULL ,
FOREIGNKEY (related_delivery_id) REFERENCES deliveries( id ) ON DELETE SETNULL ,
FOREIGNKEY (related_payment_id) REFERENCES payments( id ) ON DELETESETNULL ,
```
**INDEX** idx_user_id (user_id),
**INDEX** idx_transaction_type (transaction_type),
**INDEX** idx_created_at (created_at)
);

**18. Driver Earnings Table**

**Purpose** : Track driver earnings per ride/delivery and daily/weekly summaries

**CREATETABLE** driver_earnings (
**id** BIGSERIAL **PRIMARYKEY** ,
driver_id BIGINT **NOTNULL** ,
ride_id BIGINT, _-- NULL if earnings are for delivery_
delivery_id BIGINT, _-- NULL if earnings are for ride_

```
-- Earnings Breakdown
service_fareDECIMAL( 10 , 2 ) NOTNULL , -- Ride or delivery fare
ride_fareDECIMAL( 10 , 2 ), -- Deprecated, use service_fare
platform_commissionDECIMAL( 10 , 2 ) NOTNULL ,
driver_earningsDECIMAL( 10 , 2 ) NOTNULL ,
tip_amountDECIMAL( 10 , 2 ) DEFAULT 0.00,
total_earningsDECIMAL( 10 , 2 ) NOTNULL ,
currencyVARCHAR( 3 ) DEFAULT 'USD',
```
```
-- Payment Status
payment_status ENUM('pending', 'processing','paid', 'failed') DEFAULT 'pending',
paid_atTIMESTAMP,
payment_method ENUM('bank_transfer','cash','wallet') DEFAULT 'wallet',
```
```
-- Metadata
```

```
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (driver_id) REFERENCES drivers( id ) ONDELETE RESTRICT ,
FOREIGNKEY (ride_id) REFERENCES rides( id ) ONDELETE RESTRICT ,
FOREIGNKEY (delivery_id) REFERENCES deliveries( id ) ONDELETE RESTRICT ,
```
**INDEX** idx_driver_id (driver_id),
**INDEX** idx_ride_id (ride_id),
**INDEX** idx_delivery_id (delivery_id),
**INDEX** idx_payment_status (payment_status),
**INDEX** idx_created_at (created_at)
);

**19. Support Tickets Table**

**Purpose** : Customer support and issue tracking

**CREATETABLE** support_tickets (
**id** BIGSERIAL **PRIMARYKEY** ,
ticket_numberVARCHAR( 50 ) **UNIQUENOTNULL** ,
user_id BIGINT **NOTNULL** ,

```
-- Ticket Details
ticket_type ENUM(
'ride_issue',
'delivery_issue',
'payment_issue',
'driver_complaint',
'rider_complaint',
'sender_complaint',
'recipient_complaint',
'technical_issue',
'account_issue',
'refund_request',
'other'
) NOTNULL ,
```
```
subjectVARCHAR( 255 ) NOTNULL ,
description TEXT NOTNULL ,
```
```
-- Related Entities
related_ride_id BIGINT,
related_delivery_id BIGINT,
related_payment_id BIGINT,
```
```
-- Status
status ENUM('open','in_progress', 'resolved', 'closed') DEFAULT 'open',
priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
```
```
-- Assignment
```

```
assigned_to BIGINT, -- Admin or support staff
assigned_atTIMESTAMP,
```
```
-- Resolution
resolved_atTIMESTAMP,
resolution_notes TEXT,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (user_id) REFERENCES users( id ) ONDELETE RESTRICT ,
FOREIGNKEY (related_ride_id) REFERENCES rides( id ) ON DELETE SETNULL ,
FOREIGNKEY (related_delivery_id) REFERENCES deliveries( id ) ON DELETE SETNULL ,
FOREIGNKEY (related_payment_id) REFERENCES payments( id ) ON DELETESETNULL ,
FOREIGNKEY (assigned_to) REFERENCES users( id ) ONDELETE SETNULL ,
```
**INDEX** idx_user_id (user_id),
**INDEX** idx_status (status),
**INDEX** idx_ticket_number (ticket_number)
);

**20. Support Messages Table**

**Purpose** : Messages within support tickets

**CREATETABLE** support_messages (
**id** BIGSERIAL **PRIMARYKEY** ,
ticket_id BIGINT **NOTNULL** ,
sender_id BIGINT **NOTNULL** , _-- User who sent the message_
sender_type ENUM('user','admin', 'system') **NOTNULL** ,

```
message_text TEXT NOTNULL ,
attachments TEXT, -- JSON array of attachment URLs
```
```
-- Status
is_readBOOLEAN DEFAULTFALSE ,
read_atTIMESTAMP,
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (ticket_id) REFERENCES support_tickets( id ) ON DELETE CASCADE ,
FOREIGNKEY (sender_id) REFERENCES users( id ) ON DELETERESTRICT ,
```
```
INDEX idx_ticket_id (ticket_id),
```

**INDEX** idx_created_at (created_at)
);

**21. Admin Actions Table**

**Purpose** : Audit log for admin actions

**CREATETABLE** admin_actions (
**id** BIGSERIAL **PRIMARYKEY** ,
admin_id BIGINT **NOTNULL** ,

```
-- Action Details
action_type ENUM(
'user_approval',
'user_suspension',
'user_deletion',
'driver_approval',
'driver_rejection',
'document_verification',
'refund_processing',
'promotion_creation',
'settings_update',
'other'
) NOTNULL ,
```
```
action_description TEXT NOTNULL ,
```
```
-- Related Entity
related_entity_typeVARCHAR( 50 ),
related_entity_id BIGINT,
```
```
-- Changes
changes_made TEXT, -- JSON of changes
```
```
-- Metadata
created_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (admin_id) REFERENCES users( id ) ON DELETERESTRICT ,
```
**INDEX** idx_admin_id (admin_id),
**INDEX** idx_action_type (action_type),
**INDEX** idx_created_at (created_at)
);


**22. Settings Table**

**Purpose** : Store application-wide settings

**CREATETABLE** settings (
**id** BIGSERIAL **PRIMARYKEY** ,
setting_keyVARCHAR( 100 ) **UNIQUE NOTNULL** ,
setting_value TEXT **NOTNULL** ,
setting_type ENUM('string','number','boolean','json') **DEFAULT** 'string',
description TEXT,
**category** VARCHAR( 50 ), _-- 'pricing', 'commission', 'limits', etc._

```
-- Metadata
updated_by BIGINT, -- Admin user ID
updated_atTIMESTAMP DEFAULT CURRENT_TIMESTAMP ONUPDATE CURRENT_TIMESTAMP,
```
```
FOREIGNKEY (updated_by) REFERENCES users( id ) ON DELETE SETNULL ,
```
**INDEX** idx_setting_key (setting_key),
**INDEX** idx_category ( **category** )
);

## Relationships Summary

**Primary Relationships:**

1. **Users → Drivers** (One-to-One)
    - One user can be one driver
2. **Drivers → Vehicles** (One-to-Many)
    - One driver can have multiple vehicles
3. **Users → Rides** (One-to-Many)
    - One rider can have many rides
    - One driver can have many rides
4. **Users → Deliveries** (One-to-Many)
    - One sender can have many deliveries
    - One driver can have many deliveries
5. **Rides → Payments** (One-to-One)
    - One ride has one payment
6. **Deliveries → Payments** (One-to-One)
    - One delivery has one payment
7. **Rides → Ratings** (One-to-Many)
    - One ride can have ratings from both rider and driver
8. **Deliveries → Ratings** (One-to-Many)
    - One delivery can have ratings from sender, recipient, and driver
9. **Users → Addresses** (One-to-Many)
    - One user can have multiple saved addresses
10. **Rides → Ride Locations** (One-to-Many)
    - One ride can have many location updates
11. **Users → Notifications** (One-to-Many)
    - One user can have many notifications
12. **Drivers → Documents** (One-to-Many)
    - One driver can have multiple documents
13. **Users → Wallet Transactions** (One-to-Many)


- One user can have many wallet transactions

## Indexes for Performance

**Critical Indexes:**

1. **Users Table:**
    - idx_user_type- Filter by user type
    - idx_location- Find nearby drivers
    - idx_email,idx_phone- Quick lookups
2. **Rides Table:**
    - idx_ride_status- Filter active rides
    - idx_rider_id,idx_driver_id- User ride history
    - idx_requested_at- Time-based queries
3. **Deliveries Table:**
    - idx_delivery_status- Filter active deliveries
    - idx_sender_id,idx_driver_id- User delivery history
    - idx_requested_at- Time-based queries
    - idx_item_category- Filter by delivery type
4. **Payments Table:**
    - idx_payment_status- Payment processing
    - idx_gateway_transaction_id- Gateway reconciliation
5. **Notifications Table:**
    - idx_user_id,idx_is_read- Unread notifications

## Database Views

**1. Active Drivers View**

**CREATEVIEW** active_drivers **AS
SELECT**
d. **id** ,
d.user_id,
u.first_name,
u.last_name,
u.phone_number,
u.current_latitude,
u.current_longitude,
v.vehicle_type,
d.driver_status,
u.average_rating
**FROM** drivers d
**JOIN** users u **ON** d.user_id =u. **id
LEFTJOIN** vehicles v **ON** d.current_vehicle_id= v. **id
WHERE** u.is_active= **TRUE
AND** d.is_approved= **TRUE
AND** d.driver_status **IN** ('available', 'busy');


**2. Ride Statistics View**

**CREATEVIEW** ride_statistics **AS
SELECT**
DATE(created_at) **as** ride_date,
COUNT(*) **as** total_rides,
COUNT( **CASEWHEN** ride_status= 'completed' **THEN** 1 **END** ) **as** completed_rides,
SUM(total_fare) **as** total_revenue,
AVG(total_fare) **as** average_fare,
AVG(actual_distance) **as** average_distance
**FROM** rides
**GROUPBY** DATE(created_at);

## Stored Procedures

**1. Calculate Ride Fare**

DELIMITER//
**CREATEPROCEDURE** CalculateRideFare(
**IN** p_distance DECIMAL( 10 , 2 ),
**IN** p_duration INT,
**IN** p_vehicle_type VARCHAR( 50 ),
**IN** p_surge_multiplier DECIMAL( 3 , 2 ),
**OUT** p_base_fareDECIMAL( 10 , 2 ),
**OUT** p_distance_fareDECIMAL( 10 , 2 ),
**OUT** p_time_fareDECIMAL( 10 , 2 ),
**OUT** p_total_fareDECIMAL( 10 , 2 )
)
**BEGIN**
_-- Get pricing settings based on vehicle type_
**SELECT** base_fare, per_km_rate, per_minute_rate
**INTO** @base, @per_km, @per_min
**FROM** pricing_settings
**WHERE** vehicle_type= p_vehicle_type;

**SET** p_base_fare= @base;
**SET** p_distance_fare= p_distance* @per_km;
**SET** p_time_fare= p_duration* @per_min;
**SET** p_total_fare=(p_base_fare+ p_distance_fare+ p_time_fare)*p_surge_multiplier;
**END** //
DELIMITER ;


## Security Considerations

1. **Data Encryption:**
    - Encrypt sensitive fields: SSN, credit card tokens, passwords
    - Use AES-256 encryption for stored sensitive data
2. **Access Control:**
    - Implement row-level security based on user roles
    - Use database views for role-based data access
3. **Audit Trail:**
    - All critical tables havecreated_at,updated_at
    - Soft deletes usingdeleted_atfor data retention
4. **PII Protection:**
    - Mask sensitive data in logs
    - Implement data retention policies

## Migration Scripts

**Initial Migration**

_-- Create database_
**CREATEDATABASE** ride_sharing_appCHARACTER **SET** utf8mb4 COLLATE utf8mb4_unicode_ci;

_-- Use database_
**USE** ride_sharing_app;

_-- Create ENUM types (if using PostgreSQL)
-- Note: MySQL doesn't support CREATE TYPE, use ENUM directly in table definition_

_-- Create all tables in order (respecting foreign key dependencies)
-- 1. users
-- 2. drivers
-- 3. vehicles
-- 4. addresses
-- 5. rides
-- 6. ride_requests
-- 7. payments
-- ... (continue with all tables)_

## Sample Data

**Insert Sample Users**

_-- Sample Rider_
**INSERTINTO** users (uuid, email, phone_number, password_hash, user_type, first_name, last_name, is_active)


**VALUES** (UUID(),'rider@example.com','+1234567890', 'hashed_password','rider','John','Doe', **TRUE** );

_-- Sample Driver_
**INSERTINTO** users (uuid, email, phone_number, password_hash, user_type, first_name, last_name, is_active)
**VALUES** (UUID(),'driver@example.com', '+1234567891','hashed_password','driver', 'Jane', 'Smith', **TRUE** );

## Notes

1. **UUIDs** : Use UUIDs for public-facing IDs to prevent enumeration attacks
2. **Soft Deletes** : Usedeleted_atinstead of hard deletes for data retention
3. **Timestamps** : All tables includecreated_atandupdated_atfor audit
    trails
4. **Indexes** : Add indexes based on actual query patterns after monitoring
5. **Partitioning** : Consider partitioning large tables (rides, payments) by
    date for performance
6. **Caching** : Use Redis for frequently accessed data (active drivers, pricing)
7. **Backup Strategy** : Implement daily backups with point-in-time recovery

**Document Version:** 1.0
**Last Updated:** [Current Date]
**Status:** Ready for Implementation


