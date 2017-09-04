import Foundation
import UIKit
import AVFoundation


class CameraController: NSObject {

    var captureSession: AVCaptureSession?
    
    var cameraDevice: AVCaptureDevice?
    var cameraInput: AVCaptureInput?
    
    var output: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            if let cameraDevice = AVCaptureDevice.default(for: .video) {
                self.cameraDevice = cameraDevice
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let cameraDevice = self.cameraDevice {
                self.cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
                if captureSession.canAddInput(self.cameraInput!) {
                    captureSession.addInput(self.cameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
            }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.output = AVCapturePhotoOutput()
            self.output!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.output!){
                captureSession.addOutput(self.output!) }
                captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.output?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }

}
extension CameraController: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            
            self.photoCaptureCompletionBlock?(image, nil)
        }
            
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

