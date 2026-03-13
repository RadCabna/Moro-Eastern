import SwiftUI

struct TransparentBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        DispatchQueue.main.async {
            if let backdropLayer = view.layer.sublayers?.first {
                backdropLayer.filters?.removeAll {
                    String(describing: $0) != "gaussianBlur"
                }
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
