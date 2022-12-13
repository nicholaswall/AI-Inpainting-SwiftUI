//
//  CameraViewModel.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/6/22.
//

import Foundation
import AVFoundation
import SwiftUI

final class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var captureSession = AVCaptureSession()
    @Published var photoHasBeenTaken: Bool = false
    @Published var output = AVCapturePhotoOutput()
    @Published var frame: CGImage?
    
    private let context = CIContext()
    private let sessionQueue = DispatchQueue(label: "captureSessionQueue", qos: .background)
    private var permissionToUseCameraStream = false
    
    override init() {
        super.init()
        
        self.checkPermissionsAuthorized()
        sessionQueue.async { [unowned self] in
            self.initializeCaptureSession()
            self.captureSession.startRunning()
            print("Initializing capture session")
            
        }
    }
    
    func checkPermissionsAuthorized() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionToUseCameraStream = true
        case .notDetermined:
            requestPermissionToUseCameraStream()
        default:
            permissionToUseCameraStream = false
        }
        
    }
    
    func requestPermissionToUseCameraStream() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionToUseCameraStream = granted
        }
    }
    
    func initializeCaptureSession() {
        let videoStreamOutput = AVCaptureVideoDataOutput()
        
        guard permissionToUseCameraStream else { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        guard captureSession.canAddOutput(videoStreamOutput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoStreamOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "outputStreamSampleBufferQueue"))
        captureSession.addOutput(videoStreamOutput)
        captureSession.addOutput(output)
        
        videoStreamOutput.connection(with: .video)?.videoOrientation = .portrait
    }
    
    func saveCurrentFrameFromVideoFeed() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.captureSession.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.photoHasBeenTaken.toggle()
                }
            }
        }
    }
    
    func disardCurrentFrameAndReenableCapture() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.photoHasBeenTaken.toggle()}
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let cgImage = photo.cgImageRepresentation() else { return }
        self.frame = cgImage
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil}
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil}
        return cgImage
    }
}

