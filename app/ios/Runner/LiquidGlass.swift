import Flutter
import UIKit

/// `dsh/liquid_glass`: the system's Liquid Glass (`UIGlassEffect`) behind a
/// Flutter `GlassSurface` (lib/ui/theme/liquid_glass.dart).
///
/// The view only draws: it takes no touches, and the Flutter content of the
/// surface is composited above it. Creation parameters:
///
/// - `shape`: `"capsule"` (radius = half the shorter side, so also a circle),
///   or `"rect"` (a continuous-corner rectangle).
/// - `corners`: for `"rect"`, the top-left, top-right, bottom-left and
///   bottom-right radii in points. A corner of 0 stays square; the others
///   share the largest radius (a layer has one corner radius).
/// - `dark`: the app's theme is dark, which may differ from the system's.
///
/// A change of any of these recreates the view (the Dart side keys it by them).
final class LiquidGlassFactory: NSObject, FlutterPlatformViewFactory {
  static let viewType = "dsh/liquid_glass"

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    LiquidGlassPlatformView(frame: frame, params: args as? [String: Any] ?? [:])
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

private final class LiquidGlassPlatformView: NSObject, FlutterPlatformView {
  private let glass: LiquidGlassView

  init(frame: CGRect, params: [String: Any]) {
    glass = LiquidGlassView(frame: frame, params: params)
    super.init()
  }

  func view() -> UIView { glass }
}

private final class LiquidGlassView: UIView {
  private static let allCorners: CACornerMask = [
    .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
  ]

  private let effectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
  private let capsule: Bool
  private let radius: CGFloat
  private let rounded: CACornerMask

  init(frame: CGRect, params: [String: Any]) {
    capsule = (params["shape"] as? String) != "rect"
    let corners = (params["corners"] as? [NSNumber])?.map { CGFloat($0.doubleValue) } ?? []
    radius = corners.max() ?? 0
    if corners.count == 4 {
      let order: [CACornerMask] = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      var mask: CACornerMask = []
      for (r, corner) in zip(corners, order) where r > 0 { mask.insert(corner) }
      rounded = mask
    } else {
      rounded = Self.allCorners
    }
    super.init(frame: frame)
    isUserInteractionEnabled = false
    backgroundColor = .clear
    overrideUserInterfaceStyle = (params["dark"] as? Bool) == true ? .dark : .light
    effectView.isUserInteractionEnabled = false
    effectView.frame = bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    effectView.layer.cornerCurve = .continuous
    effectView.clipsToBounds = true
    addSubview(effectView)
    applyCorners()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

  override func layoutSubviews() {
    super.layoutSubviews()
    effectView.frame = bounds
    applyCorners()
  }

  private func applyCorners() {
    let half = min(bounds.width, bounds.height) / 2
    effectView.layer.cornerRadius = capsule ? half : min(radius, half)
    effectView.layer.maskedCorners = capsule ? Self.allCorners : rounded
  }
}
