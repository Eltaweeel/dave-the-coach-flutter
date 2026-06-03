# Dave the COACH Flutter App

Installable Flutter web / PWA foundation for the separate Dave the COACH SaaS v1.

## Product intent
- Keep `abdo-workout--hunter-agent.netlify.app` as the public Hunter Agent showcase.
- Move the real app surface into a separate repo and separate URL.
- Give Dave a mobile-friendly athlete + coach experience that feels futuristic, energetic, and calisthenics-focused.

## Current state
- Flutter web app scaffolded
- Responsive premium UI in place
- Athlete preview surface
- Coach preview surface
- PWA manifest configured
- Ready for GitHub Pages deployment

## Local commands
```bash
export PATH=/opt/flutter/bin:$PATH
flutter pub get
flutter test
flutter build web --release --base-href "/dave-the-coach-flutter/"
```

## Next implementation steps
1. Add Supabase auth and role-aware sessions
2. Add athlete profiles, plan data, and check-in persistence
3. Add Hermes reporting bridge to Dave
4. Add native packaging pipeline if App Store / Play Store distribution is needed
