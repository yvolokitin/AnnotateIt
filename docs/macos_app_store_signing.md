# macOS App Store signing: checklist and troubleshooting

If App Store Connect reports that your app is not signed with a production certificate, work through this checklist.

TL;DR checklist:
- Certificates:
  - Apple Distribution certificate (valid, not expired) in your login keychain.
  - Mac Installer Distribution certificate (Xcode can also manage this for you).
  - Remove expired/duplicate certificates from the keychain.
- Provisioning profiles:
  - A macOS "App Store" provisioning profile for your exact bundle ID (not Development, not Developer ID, not Ad Hoc).
  - Ensure the profile includes required capabilities.
- Xcode Signing (Release):
  - Target (macOS app) Signing & Capabilities -> Release:
    - Team: Your team
    - Signing Certificate: Apple Distribution
    - Provisioning Profile: Your macOS App Store profile
  - Do NOT use "Apple Development" or "Developer ID Application" for App Store.
  - Ensure the Bundle Identifier matches the App ID used by the provisioning profile.
- Build & Upload:
  - Product > Archive with the "Any Mac (Apple Silicon, Intel)" destination, using the Release configuration.
  - Distribute > App Store Connect > Upload.
- Entitlements (Release):
  - Sandbox on (required for Mac App Store).
  - Do not include `com.apple.security.get-task-allow` true in Release.
- Verify locally:
  - Verify the .app is signed with Apple Distribution and the profile name is your App Store profile.
  - Verify the .pkg is signed with the proper Installer certificate.

---

## 1) Prepare certificates and provisioning profiles

1. In Keychain Access:
   - Ensure you have a valid "Apple Distribution: Your Name (TeamID)" certificate.
   - Ensure you have a valid "Mac Installer Distribution: Your Name (TeamID)" certificate (Xcode can manage this automatically during Archive/Distribute).
   - Delete or revoke any expired/duplicate distribution certificates to avoid Xcode choosing the wrong one.
   - Keep these in the login keychain and unlocked.

2. In Apple Developer portal:
   - Create or confirm your App ID for macOS with the exact Bundle ID you will build with.
   - Create a "Mac App Store" provisioning profile (type "App Store") for that App ID.
   - Download and install the profile (double-click adds it to Xcode).

Tip: In Xcode > Settings > Accounts > (your Apple ID) > Manage Certificates, you can create/refresh "Apple Distribution" and "Mac Installer Distribution" if needed.

---

## 2) Configure Xcode Signing for Release

Open the macOS app target in Xcode:
- Targets > Your macOS app > Signing & Capabilities.
- For the Release configuration:
  - Team: your team.
  - Signing Certificate: Apple Distribution.
  - Provisioning Profile: your macOS App Store profile (not Development).
- Make sure the Bundle Identifier matches the App ID used when creating the profile.
- Capabilities: enable App Sandbox (Mac App Store requires it). Add other entitlements as needed (camera, photos, etc.). Do not enable `get-task-allow` for Release.

Avoid these mistakes:
- "Automatically manage signing" is fine only if Xcode has the Apple Distribution cert and an App Store profile; otherwise it may pick a Development identity.
- Do not select "Developer ID Application" — that is for outside-the-Mac-App-Store distribution.
- Ensure all relevant targets (main app, helper targets if you have any) use the same team and consistent Release signing.

---

## 3) Archive and upload the right way

1. Select "Any Mac (Apple Silicon, Intel)" as the destination.
2. Product > Archive (ensure you’re using Release configuration).
3. After Archive completes: Distribute App > App Store Connect > Upload.
   - Let Xcode manage the installer signing, or select your Mac Installer Distribution identity if prompted.

This path reliably applies correct production signing for the Mac App Store.

---

## 4) Verify the signature locally

Run these commands on the built archive (adjust paths):

Show available identities:
