# ServisNow Veli Flutter UI Migration Instructions

## Project

This is the Flutter mobile app for `ServisNow Veli`.

The new UI design source is Stitch MCP:

- Project ID: `9754506999849106239`
- Project Name: `ServisNow Veli UI Redesign`

## Goal

Migrate the existing Flutter UI screen by screen to match the Stitch design as closely as possible.

## Global Rules

- Only change UI, layout, widget styling, typography, colors, spacing, cards, buttons, inputs, headers, bottom navigation, and screen composition.
- Do not change backend logic.
- Do not change API calls.
- Do not change auth logic.
- Do not change route names.
- Do not change data models.
- Do not change Provider / Bloc / Cubit / Riverpod / Controller logic.
- Do not change form submit behavior.
- Do not change validation behavior.
- Do not change navigation action behavior.
- Preserve the existing app flow.
- Font must remain Manrope.
- Brand name must remain `ServisNow Veli`.
- Login screen bus / directions_bus logo concept must remain.
- Colors must come from Stitch design system / AppColors.
- Do not invent a new color palette.
- Use SafeArea where appropriate.
- On bottom navigation screens, content must not be hidden under the nav.
- On fixed CTA screens, content must not be hidden under the CTA.
- Work one screen at a time.
- Do not modify unrelated screens.
- Run `flutter analyze` after implementation/refactor steps when requested.

## Stitch Screen Order

1. Ortak theme + component altyapısı
2. Giriş Yap
3. Şifremi Unuttum
4. Kodu Girin
5. Yeni Şifre Belirle
6. Şifre Güncellendi
7. Ana Sayfa
8. Harita
9. Bildirimler
10. Profil
11. Servis İptali / Bugün Servise Binmeyecek
12. Adres Değişikliği
13. Öğrenci Bilgileri / Öğrenci Detayı
14. Genel QA ve consistency kontrolü

## Expected Shared Flutter UI Layer

Create or reuse these shared UI utilities when appropriate:

- AppColors
- AppTextStyles or ThemeData typography
- AppSpacing
- AppRadius
- AppShadows
- PrimaryButton
- SecondaryButton
- SurfaceCard
- AppTopBar
- BottomNavBar
- FormInput
- ActionTile
- SectionTitle

## Per-Screen Workflow

For each screen:

1. Read the matching Stitch screen through MCP.
2. Extract layout, colors, typography, spacing, radius, shadows, components, states, nav behavior.
3. Locate the matching Flutter screen file.
4. Update only the UI layer.
5. Preserve all existing logic.
6. Refactor small UI duplication if needed.
7. Run `flutter analyze`.
8. Report files changed and confirm logic was preserved.
9. Wait for user approval before moving to the next screen.