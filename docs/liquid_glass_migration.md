# Liquid Glass Migration Guide

This guide collects the key steps for aligning the Flutter client and its iOS host project with the Liquid Glass design language that ships with Xcode 26 and iOS 26. Treat it as a working checklist during the rollout.

## 1. Update the iOS toolchain

1. Install **Xcode 26** from the Apple Developer website and point the global command line tools to it (`xcode-select --switch /Applications/Xcode26.app`).
2. Open `ios/Runner.xcworkspace` and accept Xcode’s upgrade prompts:
   - Confirm the **Base SDK** is set to *iOS 26* in the Runner target build settings.
   - Apply recommended settings so `LastUpgradeCheck`, the Swift toolchain version, and any new build flags align with Xcode 26 defaults.
   - Regenerate workspace schemes if Xcode suggests it.
3. Run a clean Flutter build to refresh derived data and surface new warnings:
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --simulator
   ```
4. Inspect `git diff ios/Runner.xcodeproj project.pbxproj` to review the migration changes (new build phases, updated Swift language version, device family settings, etc.).
5. Inside `ios/`, run `pod install` so CocoaPods regenerates its project with the updated deployment target and SDK settings.

## 2. Remove legacy chrome overrides

- Delete native `UIBarAppearance` or manual `backgroundColor` overrides that forced opaque navigation or tool bars. The Flutter layer now leaves bar backgrounds transparent so the system can render Liquid Glass.
- On the Flutter side, the shared `AppTheme` no longer sets `barBackgroundColor`, and each `CupertinoPageScaffold` resolves its background using `AppTheme.liquidGlassBackground`. Avoid reintroducing opaque fills on navigation, tab, or tool surfaces.

## 3. Floating tab bar & accessories

- `_HidableCupertinoTabBar` now mimics Liquid Glass through:
  - A layered blur (`sigmaX`/`sigmaY` 24) combined with highlight/lowlight gradients that emulate the frosted sheen.
  - Dynamic colors drawn from `AppTheme.liquidGlassTint`, `liquidGlassBorder`, and `liquidGlassShadow`, resolved per brightness.
  - Scroll-aware visibility driven by `UserScrollNotification`, matching `tabBarMinimizeBehavior(.onScrollDown)` in UIKit.
- The tab bar exposes `preferredSize` that budgets for the floating gap plus safe-area insets. Keep accessory content synchronized with the visibility flag (UIKit’s `UITabAccessory` equivalent).

## 4. Navigation stacks & toolbars

- Attach trailing buttons straight to each `navigationItem` so they group on a single glass sheet, mirroring the system behavior.
- Use spacing primitives (`CupertinoButton`, `SizedBox`, `Spacer`) that do not paint opaque backgrounds.
- When you need subtitles under large titles, add them as part of the scroll content (`SliverToBoxAdapter`) so they slide beneath the floating chrome just like UIKit’s `largeSubtitleView`.

## 5. Edge interactions

- UIKit 26 introduces `scrollEdgeElementContainerInteraction`. Flutter does not yet expose that API, but you can approximate it by:
  - Allowing content to extend underneath floating bars, then applying additional padding when the bar minimizes.
  - Layering a subtle gradient (`resolvedLowlight` in `_HidableCupertinoTabBar`) along the bottom edge to preserve contrast over scrolled content.

## 6. Presentations & gestures

- For full-screen modals, prefer `CupertinoPageRoute` and consider custom `PageRouteBuilder` animations that scale from the invoking control to mimic the native `.zoom` transition.
- Ensure custom gesture recognizers defer to `Navigator.popGesture` so the interactive swipe-back remains responsive.

## 7. Search & controls

- Relocate phone search affordances into navigation bars or toolbars (e.g., embed a `CupertinoSearchTextField` inside the sliver navigation bar’s trailing slot).
- Refresh button and slider styling:
  - Active states borrow the glass tint (`AppTheme.liquidGlassTint`) rather than opaque fills.
  - Sliders can expose discrete tick marks and a neutral indicator to match the updated HIG guidance.

## 8. Verification checklist

- [ ] Builds succeed in Xcode 26 with the iOS 26 SDK.
- [ ] Navigation, tab, and tool bars render without manual opaque backgrounds.
- [ ] The floating tab bar blurs and tints content correctly.
- [ ] Scroll gestures minimize the tab bar smoothly.
- [ ] Buttons and sliders fit the Liquid Glass aesthetic.
- [ ] Team documentation references this migration guide and the official resources.

## References

- Xcode 26 Release Notes – <https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes>
- iOS & iPadOS 26 Release Notes – <https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-26-release-notes>
- Adopting Liquid Glass – <https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass>
- WWDC25 Session 284 “Build a UIKit app with the new design”
- WWDC25 Session 356 “Get to know the new design system”
