//
//  CameraView.swift
//  swift_scanner
//
//  Created by Anil Santo on 01/08/21.
//

#if canImport(UIKit)
#if canImport(AVFoundation)

import AVFoundation
import UIKit
import VideoToolbox

@objc protocol CameraViewOptionalDelegate: AnyObject {
    
    @objc  optional func didCaptureCard(image: CGImage)
    @objc  optional func didCaptureBarcode(barcodeData: String)
}

protocol CameraViewDelegate : CameraViewOptionalDelegate{
    func didError(with: ScannerError)
}

@available(iOS 13, *)
final class CameraView: UIView {
    weak var delegate: CameraViewDelegate?
    private let frameStrokeColor: UIColor
    private let maskLayerColor: UIColor
    private let maskLayerAlpha: CGFloat
    private let mode: ScannerMode
    // MARK: - Capture related
    private let captureSessionQueue = DispatchQueue(
        label: "com.santoanil.scanner.captureSessionQueue"
    )

    // MARK: - Capture related
    private let sampleBufferQueue = DispatchQueue(
        label: "com.santoanil.scanner.sampleBufferQueue"
    )

    init(
        delegate: CameraViewDelegate,
        frameStrokeColor: UIColor,
        maskLayerColor: UIColor,
        maskLayerAlpha: CGFloat,
        mode: ScannerMode
    ) {
        self.mode = mode
        self.delegate = delegate
        self.frameStrokeColor = frameStrokeColor
        self.maskLayerColor = maskLayerColor
        self.maskLayerAlpha = maskLayerAlpha
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let imageRatio: ImageRatio = .vga640x480

    // MARK: - Region of interest and text orientation
    /// Region of video data output buffer that recognition should be run on.
    /// Gets recalculated once the bounds of the preview layer are known.
    private var regionOfInterest: CGRect?

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }

        return layer
    }

    private var videoSession: AVCaptureSession? {
        get {
            videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }

    let semaphore = DispatchSemaphore(value: 1)

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    func stopSession() {
        videoSession?.stopRunning()
    }

    func startSession() {
        videoSession?.startRunning()
    }

    func setupCamera() {
        captureSessionQueue.async { [weak self] in
            self?._setupCamera()
        }
    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice?{
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInDualCamera,.builtInDualWideCamera],
                                                                              mediaType: .video,
                                                                              position: position)

        for device in deviceDescoverySession.devices {
            print(device)
        }
        return nil
    }

    private func _setupCamera() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = imageRatio.preset
        cameraWithPosition(.back)
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            delegate?.didError(with: ScannerError(kind: .cameraSetup))
            return
        }
        do {
            try videoDevice.lockForConfiguration()
        } catch {
            // handle error
            delegate?.didError(with: ScannerError(kind: .cameraSetup))
            return
        }
        
        
        videoDevice.exposureMode = .continuousAutoExposure
        videoDevice.focusMode = .continuousAutoFocus
        videoDevice.whiteBalanceMode = .continuousAutoWhiteBalance
//        videoDevice.flashMode = .on
        videoDevice.unlockForConfiguration()
        do {
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            session.canAddInput(deviceInput)
            session.addInput(deviceInput)
        } catch {
            delegate?.didError(with: ScannerError(kind: .cameraSetup, underlyingError: error))
        }
        switch  self.mode{
        case .card,.MRZcode:
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
            videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            guard session.canAddOutput(videoOutput) else {
                delegate?.didError(with: ScannerError(kind: .cameraSetup))
                return
            }

            session.addOutput(videoOutput)
            session.connections.forEach {
                $0.videoOrientation = .portrait
            }
        case .barcode:
            let captureMetadataOutput = AVCaptureMetadataOutput()
            guard session.canAddOutput(captureMetadataOutput) else {
                delegate?.didError(with: ScannerError(kind: .cameraSetup))
                return
            }
            session.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        
        }
        session.automaticallyConfiguresCaptureDeviceForWideColor = true
        session.commitConfiguration()

        DispatchQueue.main.async { [weak self] in
            self?.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self?.videoPreviewLayer.contentsGravity = .resizeAspectFill
            self?.videoSession = session
            self?.startSession()
        }
    }

    func setupRegionOfInterest() {
        guard regionOfInterest == nil else { return }
        /// Mask layer that covering area around camera view
        let backLayer = CALayer()
        backLayer.frame = bounds
        backLayer.backgroundColor = maskLayerColor.withAlphaComponent(maskLayerAlpha).cgColor

        //  culcurate cutoutted frame
        let cuttedWidth: CGFloat = bounds.width - 40.0
        let cuttedHeight: CGFloat = cuttedWidth * heightRatio()

        let centerVertical = (bounds.height / 2.0)
        let cuttedY: CGFloat = centerVertical - (cuttedHeight / 2.0)
        let cuttedX: CGFloat = 20.0

        let cuttedRect = CGRect(x: cuttedX,
                                y: cuttedY,
                                width: cuttedWidth,
                                height: cuttedHeight)

        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: cuttedRect, cornerRadius: 10.0)

        path.append(UIBezierPath(rect: bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        backLayer.mask = maskLayer
        layer.addSublayer(backLayer)

        let strokeLayer = CAShapeLayer()
        strokeLayer.lineWidth = 3.0
        strokeLayer.strokeColor = frameStrokeColor.cgColor
        strokeLayer.path = UIBezierPath(roundedRect: cuttedRect, cornerRadius: 10.0).cgPath
        strokeLayer.fillColor = nil
        layer.addSublayer(strokeLayer)

        let imageHeight: CGFloat = imageRatio.imageHeight
        let imageWidth: CGFloat = imageRatio.imageWidth

        let acutualImageRatioAgainstVisibleSize = imageWidth / bounds.width
        let interestX = cuttedRect.origin.x * acutualImageRatioAgainstVisibleSize
        let interestWidth = cuttedRect.width * acutualImageRatioAgainstVisibleSize
        let interestHeight = interestWidth * heightRatio()
        let interestY = (imageHeight / 2.0) - (interestHeight / 2.0)
        regionOfInterest = CGRect(x: interestX,
                                  y: interestY,
                                  width: interestWidth,
                                  height: interestHeight)
    }
    
    func heightRatio()->CGFloat{
        switch self.mode {
        case .card:
            return CreditCard.heightRatioAgainstWidth
        case .MRZcode:
            return 0.8
        default:
            return CreditCard.heightRatioAgainstWidth
        }
    }
}

@available(iOS 13, *)
extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        semaphore.wait()
        defer { semaphore.signal() }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            delegate?.didError(with: ScannerError(kind: .capture))
            delegate = nil
            return
        }

        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let regionOfInterest = regionOfInterest else {
            return
        }

        guard let fullCameraImage = cgImage,
            let croppedImage = fullCameraImage.cropping(to: regionOfInterest) else {
            delegate?.didError(with: ScannerError(kind: .capture))
            delegate = nil
            return
        }
        if let delegate = delegate,delegate.didCaptureCard != nil{
            delegate.didCaptureCard?(image: croppedImage)
        }
        else{
            delegate?.didError(with: ScannerError(kind: .capture))
            delegate = nil
        }
    }
}

@available(iOS 13, *)
extension CameraView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    //        let barCodeObject = vedioPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            if let barcodeData = metadataObj.stringValue {
                if let delegate = delegate,delegate.didCaptureBarcode != nil{
                    delegate.didCaptureBarcode?(barcodeData: barcodeData)
                }
                else{
                    delegate?.didError(with: ScannerError(kind: .capture))
                    delegate = nil
                }
            }
            else{
                delegate?.didError(with: ScannerError(kind: .capture))
                delegate = nil
            }
        }
    
}
#endif
#endif

extension CreditCard {
    // The aspect ratio of credit-card is Golden-ratio
    static let heightRatioAgainstWidth: CGFloat = 0.6180469716
}

