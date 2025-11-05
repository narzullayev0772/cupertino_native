import UIKit
import Flutter

class CupertinoContainerPlatformView: NSObject, FlutterPlatformView {
    private var effectView: UIVisualEffectView
    private var contentView: UIView

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) {
        // Args dan parametrlar olish
        let dict = args as? [String: Any] ?? [:]
        let styleStr = dict["style"] as? String ?? "regular"
        let radius = (dict["radius"] as? CGFloat) ?? 12
        let interactive = dict["interactive"] as? Bool ?? true

        // Liquid Glass effekti: UIBlurEffect + vibrancy
        let blurStyle: UIBlurEffect.Style = styleStr == "prominent" ? .systemThickMaterial : .systemUltraThinMaterial
        let blurEffect = UIBlurEffect(style: blurStyle)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = frame
        effectView.layer.cornerRadius = radius
        effectView.clipsToBounds = true
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Vibrancy qo'shish (Liquid Glass uchun)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = effectView.bounds
        effectView.contentView.addSubview(vibrancyView)

        // Ichki kontent (Flutter child ni embed qilish uchun placeholder)
        contentView = UIView(frame: vibrancyView.bounds)
        contentView.backgroundColor = .clear
        vibrancyView.contentView.addSubview(contentView)

        // Interaktiv: Gesture recognizer
        if interactive {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            effectView.addGestureRecognizer(tapGesture)
        }

        super.init()
    }

    func view() -> UIView {
        return effectView
    }

    @objc private func handleTap() {
        // Animatsiya: Scaling (Apple dokumentatsiyasidagi interactive effekti)
        UIView.animate(withDuration: 0.2, animations: {
            self.effectView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.effectView.transform = .identity
            }
        }
        // Channel orqali Flutterga signal yuborish (ixtiyoriy)
        // self.channel?.invokeMethod("onTap", arguments: nil)
    }
}