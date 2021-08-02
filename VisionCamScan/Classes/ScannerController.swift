#if canImport(UIKit)
#if canImport(AVFoundation)
import AVFoundation
import UIKit

@available(iOS 13, *)
public protocol VisionCamScanViewControllerDelegate: AnyObject {
    func scannerViewControllerDidCancel(_viewController: VisionCamScanViewController)
    
    func scannerViewController(_ viewController: VisionCamScanViewController, didErrorWith error: ScannerError)

    func scannerViewController<T>(_ viewController: VisionCamScanViewController, didFinishWith card: T)
}

@available(iOS 13, *)
open class VisionCamScanViewController : UIViewController{
    fileprivate var scannerMode: ScannerMode?
    fileprivate var delegate: VisionCamScanViewControllerDelegate?
    private var cameraView: CameraView?
    
    public var textBackgroundColor: UIColor = .black
    public var cameraViewCreditCardFrameStrokeColor: UIColor = .white
    public var cameraViewMaskLayerColor: UIColor = .black
    public var cameraViewMaskAlpha: CGFloat = 0.7
    
    private var analyzer: ImageAnalyzer?
    
    convenience public init(with delegate: VisionCamScanViewControllerDelegate,mode: ScannerMode,title: String) {
        self.init(nibName:nil, bundle:nil)
        self.scannerMode = mode
        self.delegate = delegate
        self.title = title
        self.cameraView = CameraView(
            delegate: self,
            frameStrokeColor: self.cameraViewCreditCardFrameStrokeColor,
            maskLayerColor: self.cameraViewMaskLayerColor,
            maskLayerAlpha: self.cameraViewMaskAlpha,
            mode: mode
        )
        self.analyzer = ImageAnalyzer(mode: mode, delegate: self)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        self.scannerMode = .card
        super.init(coder: coder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        layoutSubView()
        
        AVCaptureDevice.authorize { [weak self] authoriazed in
            // This is on the main thread.
            guard let strongSelf = self else {
                return
            }
            guard authoriazed else {
                strongSelf.delegate?.scannerViewController(strongSelf, didErrorWith: ScannerError(kind: .authorizationDenied, underlyingError: nil))
                return
            }
            strongSelf.cameraView?.setupCamera()
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView?.setupRegionOfInterest()
    }
}

@available(iOS 13, *)
private extension VisionCamScanViewController {
    @objc func cancel(){
        self.delegate?.scannerViewControllerDidCancel(_viewController: self)
    }
    
    func layoutSubView(){
        guard let cameraView = cameraView else {
            self.delegate?.scannerViewController(self, didErrorWith: ScannerError(kind: .cameraSetup, underlyingError: nil))
            return
        }
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

@available(iOS 13, *)
extension VisionCamScanViewController : CameraViewDelegate {
    func didCaptureCard(image: CGImage) {
        guard let analyzer = self.analyzer else {
            self.delegate?.scannerViewController(self, didErrorWith: ScannerError(kind: .analyzerSetup, underlyingError: nil))
            return
        }
        analyzer.analyze(image: image)
    }
    
    func didCaptureBarcode(barcodeData: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cameraView?.stopSession()
            strongSelf.delegate?.scannerViewController(strongSelf, didFinishWith: barcodeData)
        }
    }
    
    func didError(with error : ScannerError) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.scannerViewController(strongSelf, didErrorWith: error)
            strongSelf.cameraView?.stopSession()
        }
    }
}

@available(iOS 13, *)
extension VisionCamScanViewController : ImageAnalyzerProtocol{
    func didFinishSuccess<T>(with result: T) {
        if let card = result as? CreditCard {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.cameraView?.stopSession()
                strongSelf.delegate?.scannerViewController(strongSelf, didFinishWith: card)
            }
        }
    }
    
    func didFinishFailure(with result: ScannerError) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cameraView?.stopSession()
            strongSelf.delegate?.scannerViewController(strongSelf, didErrorWith: result)
        }
    }
}


@available(iOS 13, *)
extension AVCaptureDevice {
    static func authorize(authorizedHandler: @escaping ((Bool) -> Void)) {
        let mainThreadHandler: ((Bool) -> Void) = { isAuthorized in
            DispatchQueue.main.async {
                authorizedHandler(isAuthorized)
            }
        }
        
        switch authorizationStatus(for: .video) {
        case .authorized:
            mainThreadHandler(true)
        case .notDetermined:
            requestAccess(for: .video, completionHandler: { granted in
                mainThreadHandler(granted)
            })
        default:
            mainThreadHandler(false)
        }
    }
}
#endif
#endif
