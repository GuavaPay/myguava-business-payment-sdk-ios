//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

#if canImport(UIKit)
#if canImport(AVFoundation)
import AVFoundation
import UIKit

@available(iOS 13, *)
protocol CardScannerDelegate: AnyObject {
    func cardScannerViewControllerDidCancel(_ viewController: CardScannerViewController)
    func cardScannerViewController(
        _ viewController: CardScannerViewController,
        didErrorWith error: CardScannerError
    )
    func cardScannerViewController(
        _ viewController: CardScannerViewController,
        didFinishWith card: CardScannerModel
    )
}

@available(iOS 13, *)
extension CardScannerDelegate where Self: UIViewController {
    func cardScannerViewControllerDidCancel(_ viewController: CardScannerViewController) {
        viewController.dismiss(animated: true)
    }
}

@available(iOS 13, *)
class CardScannerViewController: UIViewController {
    // MARK: - Subviews and layers

    private lazy var cameraView = CardScannerView(delegate: self)

    private lazy var analyzer = ImageAnalyzer(delegate: self)

    private weak var delegate: CardScannerDelegate?

    // MARK: - Vision-related

    init(delegate: CardScannerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()

        AVCaptureDevice.authorize { [weak self] authoriazed in
            guard let self else {
                return
            }

            guard authoriazed else {
                delegate?.cardScannerViewController(
                    self,
                    didErrorWith: CardScannerError(kind: .authorizationDenied, underlyingError: nil)
                )
                return
            }

            cameraView.setupCamera()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.setupViews()
    }

    func layoutSubviews() {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)

        cameraView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

@available(iOS 13, *)
extension CardScannerViewController: CardScannerViewDelegate {
    func onBackButton() {
        delegate?.cardScannerViewControllerDidCancel(self)
    }

    func didCapture(image: CGImage) {
        analyzer.analyze(image: image)
    }

    func didError(with error: CardScannerError) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            delegate?.cardScannerViewController(self, didErrorWith: error)
            cameraView.stopSession()
        }
    }
}

@available(iOS 13, *)
extension CardScannerViewController: ImageAnalyzerProtocol {
    func didFinishAnalyzation(with result: Result<CardScannerModel, CardScannerError>) {
        switch result {
        case let .success(Card):
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                cameraView.stopSession()
                delegate?.cardScannerViewController(self, didFinishWith: Card)
            }

        case let .failure(error):
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                cameraView.stopSession()
                delegate?.cardScannerViewController(self, didErrorWith: error)
            }
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
            requestAccess(for: .video) { granted in
                mainThreadHandler(granted)
            }
        default:
            mainThreadHandler(false)
        }
    }
}
#endif
#endif
