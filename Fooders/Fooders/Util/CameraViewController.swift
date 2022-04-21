//
//  CameraViewController.swift
//  Fooders
//
//  Created by junemp on 2022/04/15.
//

import Foundation
import SwiftUI
import CameraManager
import AVFoundation

struct CameraViewController: UIViewControllerRepresentable {
    @State var cameraManager: CameraManager
    @Binding var lux: Double
    
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        
        cameraManager.cameraDevice = UserDefaults.standard.integer(forKey: "device") == 1 ? CameraDevice.front : CameraDevice.back
        cameraManager.addPreviewLayerToView(controller.view)
        cameraManager.cameraOutputMode = CameraOutputMode.videoOnly
        
        let output = AVCaptureVideoDataOutput()
        if ((cameraManager.captureSession?.canAddOutput(output)) != nil) {
            cameraManager.captureSession?.addOutput(output)
            let videoQueue = DispatchQueue(label: "VideoQueue")
            output.setSampleBufferDelegate(context.coordinator, queue: videoQueue)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator{
        return Coordinator(lux: $lux)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        @Binding var lux: Double
        
        init(lux: Binding<Double>) {
            _lux = lux
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            if let metadata = CMGetAttachment(sampleBuffer, key: kCGImagePropertyExifDictionary, attachmentModeOut: nil) {
                if let fN = metadata["FNumber"] as? Double {
                    if let fT = metadata["ExposureTime"] as? Double {
                        if let speedArr = metadata["ISOSpeedRatings"] as? NSArray {
                            let calValue = UserDefaults.standard.double(forKey: "calvalue")
                            let fS = speedArr[0] as! Double
                            lux = (fN * fN) / (fT * fS) * calValue
                        }
                    }
                }
            }
        }
    }
}
