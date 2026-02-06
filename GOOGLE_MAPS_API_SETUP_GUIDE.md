# Google Maps API & Distance Matrix API Setup Guide

This guide will help you set up Google Maps API and Distance Matrix API from Google Cloud Console. Follow these steps carefully to enable the required services and generate API keys.

---

## Prerequisites

1. **Google Account**: You need a Google account (Gmail account works)
2. **Billing Account**: Google requires a billing account to be linked (even though there's a free tier)
3. **Access to Google Cloud Console**: You'll need to access [Google Cloud Console](https://console.cloud.google.com/)

---

## Step-by-Step Setup Guide

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Click on the project dropdown at the top of the page (next to "Google Cloud")
4. Click **"NEW PROJECT"** button
5. Fill in the project details:
   - **Project name**: `draaxi-maps` (or any name you prefer)
   - **Organization**: Select your organization (if applicable)
   - **Location**: Select your location
6. Click **"CREATE"**
7. Wait for the project to be created, then select it from the project dropdown

---

### Step 2: Enable Billing Account

**Important**: Google requires a billing account even though they offer free credits and a free tier.

1. In the Google Cloud Console, go to **"Billing"** from the left sidebar (hamburger menu ☰)
2. Click **"LINK A BILLING ACCOUNT"**
3. If you don't have a billing account:
   - Click **"CREATE BILLING ACCOUNT"**
   - Fill in your billing information (credit/debit card)
   - Note: Google provides $200 free credits for new accounts
4. Link the billing account to your project
5. You'll see a confirmation that billing is enabled

**Note**: Even with billing enabled, Google Maps has a generous free tier ($200/month free credits).

---

### Step 3: Enable Google Maps SDK for Android

1. In the Google Cloud Console, make sure your project is selected
2. Go to **"APIs & Services"** → **"Library"** from the left sidebar
3. In the search bar, type: **"Maps SDK for Android"**
4. Click on **"Maps SDK for Android"** from the results
5. Click the **"ENABLE"** button
6. Wait for the API to be enabled (you'll see a green checkmark)

---

### Step 4: Enable Google Maps SDK for iOS

1. Stay in the **"APIs & Services"** → **"Library"** section
2. In the search bar, type: **"Maps SDK for iOS"**
3. Click on **"Maps SDK for iOS"** from the results
4. Click the **"ENABLE"** button
5. Wait for the API to be enabled

---

### Step 5: Enable Distance Matrix API

1. Still in the **"APIs & Services"** → **"Library"** section
2. In the search bar, type: **"Distance Matrix API"**
3. Click on **"Distance Matrix API"** from the results
4. Click the **"ENABLE"** button
5. Wait for the API to be enabled

---

### Step 6: Create API Keys

You can create separate keys for Android, iOS, and Server (for Distance Matrix), or use one key with restrictions.

#### Option A: Create Separate API Keys (Recommended)

**For Android:**

1. Go to **"APIs & Services"** → **"Credentials"** from the left sidebar
2. Click **"+ CREATE CREDENTIALS"** at the top
3. Select **"API key"**
4. A new API key will be generated
5. Copy this key immediately (you won't see it again)
6. Click **"RESTRICT KEY"** to set restrictions (recommended)
7. Give it a name: `Android Maps Key` or `draaxi-android-maps-key`
8. Under **"API restrictions"**, select **"Restrict key"**
9. Check only:
   - ✅ Maps SDK for Android
10. Under **"Application restrictions"**, select **"Android apps"**
11. Click **"ADD AN ITEM"**
    - **Package name**: `com.example.draaxi` ✅ (Confirmed from project)
    - **SHA-1 certificate fingerprint**: Ask developer for this, or leave blank temporarily
12. Click **"SAVE"**

**For iOS:**

1. Go back to **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** → **"API key"**
3. Copy the new API key
4. Click **"RESTRICT KEY"**
5. Give it a name: `iOS Maps Key` or `draaxi-ios-maps-key`
6. Under **"API restrictions"**, select **"Restrict key"**
7. Check only:
   - ✅ Maps SDK for iOS
8. Under **"Application restrictions"**, select **"iOS apps"**
9. Click **"ADD AN ITEM"**
    - **Bundle ID**: `com.example.draaxi` ✅ (Confirmed from project)
10. Click **"SAVE"**

**For Distance Matrix API (Server Key):**

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** → **"API key"**
3. Copy the new API key
4. Click **"RESTRICT KEY"**
5. Give it a name: `Distance Matrix API Key` or `draaxi-distance-matrix-key`
6. Under **"API restrictions"**, select **"Restrict key"**
7. Check only:
   - ✅ Distance Matrix API
8. Under **"Application restrictions"**, you can select:
   - **"None"** (if using from app)
   - **"IP addresses"** (if you have a server IP)
   - **"HTTP referrers"** (for web usage)
9. Click **"SAVE"**

#### Option B: Create One Universal API Key (Simpler, Less Secure)

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** → **"API key"**
3. Copy the API key
4. Click **"RESTRICT KEY"** (highly recommended)
5. Give it a name: `Draaxi Universal Key`
6. Under **"API restrictions"**, select **"Restrict key"**
7. Check all required APIs:
   - ✅ Maps SDK for Android
   - ✅ Maps SDK for iOS
   - ✅ Distance Matrix API
8. Under **"Application restrictions"**, you can choose:
   - **"None"** (not recommended for production)
   - Set restrictions per platform (recommended)
9. Click **"SAVE"**

---

### Step 7: Note Down Important Information

After creating the API keys, please provide the following information:

```
✅ Android API Key: [Your Android API Key]
✅ iOS API Key: [Your iOS API Key]
✅ Distance Matrix API Key: [Your Distance Matrix API Key]
   (OR)
✅ Universal API Key: [Your Universal API Key]

📱 Android Package Name: com.example.draaxi ✅ (Already confirmed)
🍎 iOS Bundle ID: com.example.draaxi ✅ (Already confirmed)
📝 Android SHA-1 Fingerprint: [Ask developer - optional but recommended]
```

---

## Important Notes & Best Practices

### Security Recommendations:

1. **Always restrict your API keys** - Never use unrestricted keys in production
2. **Set application restrictions** - Limit which apps can use the keys
3. **Set API restrictions** - Only enable the APIs you need
4. **Monitor usage** - Regularly check your API usage in Google Cloud Console

### Billing & Quotas:

1. **Free Tier**: Google provides $200/month in free credits
2. **Pricing**: Check current pricing at [Google Maps Platform Pricing](https://mapsplatform.google.com/pricing/)
3. **Set Budget Alerts**: 
   - Go to **"Billing"** → **"Budgets & alerts"**
   - Create a budget to get notified of spending

### Finding Your App Information:

**For Android Package Name:**
- Check `android/app/build.gradle` → `applicationId`
- Or ask the developer

**For iOS Bundle ID:**
- Check `ios/Runner/Info.plist` → `CFBundleIdentifier`
- Or check Xcode project settings
- Or ask the developer

**For Android SHA-1 Fingerprint:**
- Developer needs to run: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
- Or provide the debug keystore path

---

## What to Provide to Your Developer

Once you've completed the setup, provide the following:

1. ✅ **API Keys** (the actual key strings)
2. ✅ **Package Name** (Android) - confirm with developer
3. ✅ **Bundle ID** (iOS) - confirm with developer
4. ✅ **SHA-1 Fingerprint** (Android) - optional but recommended

**Format Example:**
```
Android API Key: AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567
iOS API Key: AIzaSyXyZaBcDeFgHiJkLmNoPqRsTuVwXyZ1234567
Distance Matrix API Key: AIzaSy1234567890AbCdEfGhIjKlMnOpQrStUvWxYz
Package Name: com.example.draaxi ✅
Bundle ID: com.example.draaxi ✅
SHA-1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

---

## Troubleshooting

### If you can't enable an API:
- Make sure billing is enabled
- Check if you have the necessary permissions
- Try refreshing the page

### If API keys don't work:
- Verify the APIs are enabled
- Check API key restrictions
- Ensure package name/bundle ID matches
- Verify billing account is active

### Getting help:
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Google Cloud Support](https://cloud.google.com/support)

---

## Quick Checklist

- [ ] Google Cloud Project created
- [ ] Billing account linked
- [ ] Maps SDK for Android enabled
- [ ] Maps SDK for iOS enabled
- [ ] Distance Matrix API enabled
- [ ] API keys created
- [ ] API keys restricted (recommended)
- [ ] Package name/Bundle ID confirmed
- [ ] Information provided to developer

---

**Last Updated**: [Date when you complete this]
**Project Name**: draaxi
**Contact**: [Your contact information]

