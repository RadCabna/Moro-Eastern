import SwiftUI
import UIKit
import AVFoundation

/// UIImagePickerController wrapper for camera capture.
struct CameraImagePicker: UIViewControllerRepresentable {

    @Binding var images: [UIImage]
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType       = .camera
        picker.delegate         = context.coordinator
        picker.allowsEditing    = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker

        init(_ parent: CameraImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.images.append(img)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

/// Requests camera permission and calls the completion on the main queue.
/// Returns false immediately if the device has no camera (e.g. simulator).
func requestCameraAccess(completion: @escaping (Bool) -> Void) {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
        DispatchQueue.main.async { completion(false) }
        return
    }
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        completion(true)
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    default:
        completion(false)
    }
}
