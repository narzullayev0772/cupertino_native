import UIKit
import Flutter

// Glass stili enum (Apple docs ga asoslanib)
enum GlassStyle: String {
    case regular
    case prominent
    case ultraThin  // Qo'shimcha, agar kerak bo'lsa

    var uiStyle: Any {  // UIKit ga moslashtirish
        switch self {
        case .prominent: return UIGlassEffect.Style.prominent  // iOS 18+
        case .ultraThin: return UIGlassEffect.Style.ultraThin
        default: return UIGlassEffect.Style.regular
        }
    }

    var fallbackBlurStyle: UIBlurEffect.Style {
        switch self {
        case .prominent: return .systemThickMaterial
        case .ultraThin: return .systemUltraThinMaterial
        default: return .systemMaterial  // Liquid Glass ga yaqin
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

        // Liquid Glass effekti: iOS 18+ da UIGlassEffect, aks holda fallback
        if #available(iOS 18.0, *) {
            let glassEffectStyle = glassStyle.uiStyle as! UIGlassEffect.Style
            let glassEffect = UIGlassEffect(style: glassEffectStyle)
            effectView = UIVisualEffectView(effect: glassEffect)
        } else {
            let blurEffect = UIBlurEffect(style: glassStyle.fallbackBlurStyle)
            effectView = UIVisualEffectView(effect: blurEffect)
        }

        effectView.frame = frame
        effectView.layer.cornerRadius = radius
        effectView.clipsToBounds = true
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Vibrancy qo'shish (Liquid Glass uchun – container effect bilan)
        if #available(iOS 18.0, *) {
            // UIGlassContainerEffect: Ichki elementlarni Liquid Glass bilan bog'lash
            let containerEffect = UIGlassContainerEffect(style: .regular)  // Custom views uchun
            let vibrancyEffect = UIVibrancyEffect(glassEffect: containerEffect)  // Yangi vibrancy
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyView.frame = effectView.bounds
            effectView.contentView.addSubview(vibrancyView)
        } else {
            // Eski vibrancy
            if let blurEffect = effectView.effect as? UIBlurEffect {
                let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
                vibrancyView.frame = effectView.bounds
                effectView.contentView.addSubview(vibrancyView)
            }
        }

        // Ichki kontent (Flutter child ni embed qilish uchun placeholder)
        contentView = UIView(frame: effectView.bounds)  // vibrancyView o'rniga effectView
        contentView.backgroundColor = .clear
        effectView.contentView.addSubview(contentView)  // To'g'ridan contentView ga

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