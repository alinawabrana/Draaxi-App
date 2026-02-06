# 🚕 Application User Flow Documentation (Rider & Driver)

## 1️⃣ Sign Up (Both Roles)

Both **Rider** and **Driver** use the same Sign Up form.

**Sign Up Fields:**
- First Name
- Last Name
- Email
- Phone
- Password
- Role (Rider / Driver)

**Flow:**
1. User submits the form.
2. System sends an **OTP to the provided email**.
3. User enters OTP.
4. If OTP is valid → **Account is created**.

---

## 2️⃣ Login (Both Roles)

User logs in using **email + password**.

**Post-Login Behavior:**
| Role | Result |
|------|--------|
| Rider | Redirect to Rider Home (Full Access) |
| Driver | Show Document Verification Dialog |

---

## 3️⃣ Driver Verification Dialog

Message:
> To continue, please verify your identity and required documents.

**Options:**
| Option | Action |
|--------|--------|
| Verify at Branch | App stays limited until verification is done. |
| Upload Online | Redirects to Profile Completion / Document Upload screen. |

---

## 4️⃣ Driver Profile Completion

Driver must provide:

### Required Information
- Full Personal Details (Name, Address, ID/CNIC)
- Vehicle Details (Model, Number Plate, Color, etc.)
- Document Uploads:
    - National ID / CNIC
    - Driver License
    - Vehicle Registration
    - Profile Photo

### Verification Status
Driver status can be:
- **Pending Verification**
- **Approved** (Driver can accept rides)
- **Rejected** (Must re-upload documents)

---
lu
## 5️⃣ Rider Access Flow

Rider has immediate access to:
- Request a ride / delivery
- Track active ride
- View driver details
- Payment & Ride history
- Manage profile

---

## ✔ User Access Summary

| Account Status | Rider Access | Driver Access |
|----------------|--------------|---------------|
| Registered (Not Verified) | Full access | Limited (must verify) |
| Pending Document Approval | Full access | Cannot accept rides |
| Verified / Approved | Full access | Full access (can accept rides) |

---

## 📌 End of Documentation
