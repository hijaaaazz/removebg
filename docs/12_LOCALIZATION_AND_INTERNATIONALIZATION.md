# 12. Localization & Internationalization (i18n / l10n)

RemoveIt is built for a global audience spanning North America, Europe, Latin America, India, East Asia, and the Middle East. Complete internationalization and Bidirectional (RTL) support are foundational requirements.

---

## 1. Flutter `l10n` Configuration (`l10n.yaml`)

```yaml
# l10n.yaml in root directory
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

---

## 2. Supported Locales Matrix

| Language | Locale Code | Script / Direction | Market Relevance |
| :--- | :--- | :--- | :--- |
| **English** | `en` | LTR | Global baseline |
| **Spanish** | `es` | LTR | Latin America & Spain |
| **Hindi** | `hi` | Devanagari (LTR) | India (High mobile Android user base) |
| **Arabic** | `ar` | RTL (Right-to-Left) | Middle East & North Africa |
| **French** | `fr` | LTR | Western Europe & Africa |
| **German** | `de` | LTR | Central Europe |
| **Japanese**| `ja` | LTR | Japan (High iOS ARPU market) |
| **Portuguese**| `pt` | LTR | Brazil & Portugal |

---

## 3. ARB Template Specification (`lib/l10n/app_en.arb`)

```json
{
  "@@locale": "en",
  "appTitle": "RemoveIt",
  "@appTitle": { "description": "The title of the application" },

  "homeUploadTitle": "Remove Background Instantly",
  "homeUploadSubtitle": "Select any photo to isolate subjects with studio-grade precision",
  "buttonSelectPhoto": "Select Photo from Gallery",
  "buttonTakePhoto": "Take Photo with Camera",

  "quotaRemaining": "{count, plural, =0{No free removals left} =1{1 free removal left today} other{{count} free removals left today}}",
  "@quotaRemaining": {
    "description": "Daily quota counter with pluralization",
    "placeholders": {
      "count": { "type": "int", "example": "1" }
    }
  },

  "buttonWatchAdBonus": "Watch Video (+1 Bonus Use)",
  "buttonUnlockPro": "Upgrade to Pro Unlimited",
  "canvasCompareTooltip": "Drag slider to compare cutout with original photo",
  "canvasSaveToGallery": "Save to Camera Roll",
  "canvasSavedSuccess": "Cutout saved successfully!",

  "errorQuotaExhausted": "You've used today's free removals! Watch a quick video to unlock a bonus or switch to Pro.",
  "errorNetwork": "No internet connection detected. Please check your network.",
  "errorImageTooLarge": "The photo dimensions are too large to process safely. Please resize it slightly."
}
```

---

## 4. Right-to-Left (RTL) Layout Architecture

When rendering in Arabic (`ar`), Flutter automatically mirrors horizontal layouts:
1. **Never use hardcoded `EdgeInsets.left` or `EdgeInsets.right`.** Always use directional insets:
   - `EdgeInsetsDirectional.only(start: 16, end: 16)`
   - `EdgeInsetsDirectional.symmetric(horizontal: 16)`
2. **Icons with directional meaning** (e.g. back arrows, forward chevrons) must use `Icons.arrow_back_ios_new` or wrap with `Transform.scale(scaleX: -1)` when `Directionality.of(context) == TextDirection.rtl`.
3. **Split Comparison Slider:** Automatically respects start-to-end directionality so Arabic users intuitively pull from right to left.
