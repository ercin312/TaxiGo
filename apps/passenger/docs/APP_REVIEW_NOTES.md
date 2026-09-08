# App Store Review Notes — TaxiGo 1.0 (13)

Paste into App Store Connect → App Review Information → Notes:

```
SIGN IN
Please do not use Sign in with Apple or Google on this build — those native flows crash on iPadOS 26. This build uses phone OTP only (no third-party login).

GOOGLE / APPLE
Not shown on iOS. Use the demo phone accounts below.

DEMO ACCOUNTS (phone OTP — no SMS required)
The verification code is shown on the OTP screen and is always:

Passenger (map, booking, wallet, trip history):
Phone: +905550000001
OTP: 123456
Name: App Review

Driver (driver home, go online):
Phone: +905550000002
OTP: 123456
Name: App Review Driver

Steps:
1) Choose language → Continue
2) Complete onboarding if shown
3) On Sign In: select Passenger or Driver (phones autofill)
4) Tap Send OTP → enter 123456 (also displayed on screen)
5) You will reach passenger home or driver home with sample content

API: https://alanyaproje.com/taxigo/v1
```

Sign-in field in App Review Information:
- User name: +905550000001
- Password: 123456
