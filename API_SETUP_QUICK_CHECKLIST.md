# Google Maps API Setup - Quick Checklist

A simplified checklist for enabling Google Maps APIs and generating API keys.

---

## Quick Steps

### 1. ☁️ Create Google Cloud Project
- Go to [console.cloud.google.com](https://console.cloud.google.com/)
- Click "NEW PROJECT"
- Name: `draaxi-maps` (or any name)
- Click "CREATE"

### 2. 💳 Enable Billing
- Go to "Billing" in left menu
- Link or create a billing account
- ⚠️ Required even with free tier ($200/month free credits)

### 3. 🔌 Enable APIs
Go to **"APIs & Services" → "Library"** and enable:
- ✅ Maps SDK for Android
- ✅ Maps SDK for iOS  
- ✅ Distance Matrix API

### 4. 🔑 Create API Keys
Go to **"APIs & Services" → "Credentials"**:

**Option A: Separate Keys (Recommended)**
- Create 3 keys: Android, iOS, and Distance Matrix
- Restrict each key to its specific API
- Set app restrictions (package name/bundle ID)

**Option B: One Universal Key**
- Create 1 key
- Enable all 3 APIs
- Set restrictions

### 5. 📝 Provide Information
Send these details:

```
✅ Android API Key: [paste key here]
✅ iOS API Key: [paste key here]
✅ Distance Matrix API Key: [paste key here]

📱 Package Name: com.example.draaxi ✅
🍎 Bundle ID: com.example.draaxi ✅
📝 SHA-1: [optional - ask developer if needed]
```

---

## Your App Details (Already Confirmed)

- **Android Package Name**: `com.example.draaxi`
- **iOS Bundle ID**: `com.example.draaxi`

---

## Important Reminders

⚠️ **Always restrict API keys** - Never use unrestricted keys  
💰 **Free tier**: $200/month free credits  
📊 **Monitor usage**: Set up budget alerts  
🔒 **Keep keys secure**: Don't commit to public repositories

---

## Need Detailed Steps?

See the complete guide: `GOOGLE_MAPS_API_SETUP_GUIDE.md`

---

## Help & Resources

- [Google Maps Platform](https://mapsplatform.google.com/)
- [Pricing Information](https://mapsplatform.google.com/pricing/)
- [API Documentation](https://developers.google.com/maps/documentation)




