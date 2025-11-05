import UIKit
import Flutter

// Glass stili enum (Apple docs ga asoslanib, fallback bilan)
enum GlassStyle: String {
    case regular
    case prominent
    case ultraThin  // Qo'shimcha, agar kerak bo'lsa

    var blurStyle: UIBlurEffect.Style {
        switch self {
        case .prominent: return .systemThickMaterial  // Kuchliroq blur
        case .ultraThin: return .systemUltraThinMaterial  // Nozik
        default: return .systemMaterial  // Liquid Glass ga yaqin (iOS 13+)
        }
    }
}

class CupertinoContainerPlatformView: NSObject, FlutterPlatformView {
    private var effectView: UIVisualEffectView
    private var contentView: UIView

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) {
        // Args dan parametrlar olish
        let dict = args as? [String: Any] ?? [:]
        let styleStr = dict["style"] as? String ?? "regular"
        let radius = (dict["radius"] as? CGFloat) ?? 12
        let interactive = dict["interactive"] as? Bool ?? true

        let glassStyle = GlassStyle(rawValue: styleStr) ?? .regular

        // Liquid Glass simulyatsiyasi: UIBlurEffect (har doim mavjud)
        let blurEffect = UIBlurEffect(style: glassStyle.blurStyle)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = frame
        effectView.layer.cornerRadius = radius
        effectView.clipsToBounds = true
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Vibrancy qo'shish (Liquid Glass uchun – standart vibrancy)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = effectView.bounds
        effectView.contentView.addSubview(vibrancyView)

        // Ichki kontent (Flutter child ni embed qilish uchun placeholder)
        contentView = UIView(frame: vibrancyView.bounds)
        contentView.backgroundColor = .clear
        vibrancyView.contentView.addSubview(contentView)

        // Super.init ni shu yerda chaqirish – barcha properties initsializatsiya qilingan
        super.init()

        // Interaktiv: Gesture recognizer (super.init dan KEYIN qo'shish!)
        if interactive {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            effectView.addGestureRecognizer(tapGesture)
        }
    }

    func view() -> UIView {
        return effectView
    }

    @objc private func handleTap() {
        // Animatsiya: Scaling + opacity (Apple docs dagi interactive effekti, suyuqlik uchun)
        UIView.animate(withDuration: 0.2, animations: {
            self.effectView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.effectView.alpha = 0.9  // Qo'shimcha: Shaffoflik o'zgarishi (morphing ga yaqin)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.effectView.transform = .identity
                self.effectView.alpha = 1.0
            }
        }
        // Channel orqali Flutterga signal yuborish (ixtiyoriy)
        // self.channel?.invokeMethod("onTap", arguments: nil)
    }
}