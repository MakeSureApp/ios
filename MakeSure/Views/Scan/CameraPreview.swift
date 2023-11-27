//
//  CameraPreview.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.06.2023.
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewControllerRepresentable {
    let session: AVCaptureSession

    func makeUIViewController(context: Context) -> CameraPreviewController {
        let controller = CameraPreviewController()
        controller.session = session
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraPreviewController, context: Context) {}
}

final class CameraPreviewController: UIViewController {
    var session: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
}
