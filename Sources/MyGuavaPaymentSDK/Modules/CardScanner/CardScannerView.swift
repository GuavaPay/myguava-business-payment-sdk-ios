//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation

#if canImport(UIKit)
#if canImport(AVFoundation)

import AVFoundation
import UIKit
import VideoToolbox

protocol CardScannerViewDelegate: AnyObject {
    func didCapture(image: CGImage)
    func didError(with: CardScannerError)
    func onBackButton()
}

@available(iOS 13, *)
final class CardScannerView: UIView {
    enum Constants {
        static let frameStrokeColor: UIColor = .white
        static let maskLayerColor: UIColor = .black
        static let maskLayerAlpha: CGFloat = 0.7
        static let maskCenterY: CGFloat = 150
        static let maskCenterX: CGFloat = 20.0
    }

    private lazy var headerLeadingButton: UIButton = {
        let view = UIButton()
        view.setTitle("", for: .normal)
        view.setImage(Icons.backArrow.withTintColor(.white), for: .normal)
        view.addTarget(self, action: #selector(leadingButtonTapped), for: .touchUpInside)
        return view
    }()

    private lazy var headerTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "Scan card"
        view.textColor = .foreground.onAccent
        view.font = .headlineSemibold
        view.textAlignment = .center
        return view
    }()

    private lazy var headerTrailingButton: UIButton = {
        let view = UIButton()
        view.setTitle("", for: .normal)
        view.tintColor = .white
        view.setImage(Icons.flash.withTintColor(.foreground.onAccent), for: .normal)
        view.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .fillProportionally
        return view
    }()

    weak var delegate: CardScannerViewDelegate?

    // MARK: - Capture related

    private let captureSessionQueue = DispatchQueue(
        label: "com.myguava.credit-card-scanner.captureSessionQueue"
    )

    // MARK: - Capture related

    private let sampleBufferQueue = DispatchQueue(
        label: "com.myguava.credit-card-scanner.sampleBufferQueue"
    )

    init(delegate: CardScannerViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let imageRatio: ImageRatio = .vga640x480

    // MARK: - Region of interest and text orientation

    /// Region of video data output buffer that recognition should be run on.
    /// Gets recalculated once the bounds of the preview layer are known.
    private var regionOfInterest: CGRect?

    func setupViews() {
        setupRegionOfInterest()
        configureLayout()
    }

    private func configureLayout() {
        addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubviews(
            headerLeadingButton,
            headerTitleLabel,
            headerTrailingButton
        )

        headerLeadingButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        headerTrailingButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        horizontalStackView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(32)
            $0.top.equalToSuperview().inset(75)
        }
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("AVCaptureVideoPreviewLayer")
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

    override static var layerClass: AnyClass {
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

    private func _setupCamera() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = imageRatio.preset

        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            delegate?.didError(with: CardScannerError(kind: .cameraSetup))
            return
        }

        do {
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            session.canAddInput(deviceInput)
            session.addInput(deviceInput)
        } catch {
            delegate?.didError(with: CardScannerError(kind: .cameraSetup, underlyingError: error))
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)

        guard session.canAddOutput(videoOutput) else {
            delegate?.didError(with: CardScannerError(kind: .cameraSetup))
            return
        }

        session.addOutput(videoOutput)
        session.connections.forEach {
            $0.videoOrientation = .portrait
        }
        session.commitConfiguration()

        DispatchQueue.main.async { [weak self] in
            self?.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self?.videoSession = session
            self?.startSession()
        }
    }

    private func setupRegionOfInterest() {
        guard regionOfInterest == nil else {
            return
        }
        let backLayer = CALayer()
        backLayer.frame = bounds
        backLayer.backgroundColor = Constants.maskLayerColor.withAlphaComponent(Constants.maskLayerAlpha)
            .cgColor

        let cuttedWidth: CGFloat = bounds.width - Constants.maskCenterX * 2
        let cuttedHeight: CGFloat = cuttedWidth * CardScannerModel.backLayerRatioAgainstWidth

        let cuttedY: CGFloat = Constants.maskCenterY
        let cuttedX: CGFloat = Constants.maskCenterX

        let cuttedRect = CGRect(
            x: cuttedX,
            y: cuttedY,
            width: cuttedWidth,
            height: cuttedHeight
        )

        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: cuttedRect, cornerRadius: 10.0)

        path.append(UIBezierPath(rect: bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        backLayer.mask = maskLayer
        layer.addSublayer(backLayer)

        let imageHeight: CGFloat = imageRatio.imageHeight
        let imageWidth: CGFloat = imageRatio.imageWidth

        let acutualImageRatioAgainstVisibleSize = imageWidth / bounds.width
        let interestX = cuttedRect.origin.x * acutualImageRatioAgainstVisibleSize
        let interestWidth = cuttedRect.width * acutualImageRatioAgainstVisibleSize
        let interestHeight = interestWidth * CardScannerModel.heightRatioAgainstWidth
        let interestY = (imageHeight / 2.0) - (interestHeight / 2.0)
        regionOfInterest = CGRect(
            x: interestX,
            y: interestY,
            width: interestWidth,
            height: interestHeight
        )
    }

    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        var isOn = false
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                isOn = !device.isTorchActive
                try device.setTorchModeOn(level: 1.0)
                device.torchMode = isOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    @objc
    private func leadingButtonTapped() {
        delegate?.onBackButton()
    }

    @objc
    private func trailingButtonTapped() {
        toggleFlash()
    }
}

@available(iOS 13, *)
extension CardScannerView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from _: AVCaptureConnection
    ) {
        semaphore.wait()
        defer { semaphore.signal() }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            delegate?.didError(with: CardScannerError(kind: .capture))
            delegate = nil
            return
        }

        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let regionOfInterest else {
            return
        }

        guard let fullCameraImage = cgImage,
              let croppedImage = fullCameraImage.cropping(to: regionOfInterest) else {
            delegate?.didError(with: CardScannerError(kind: .capture))
            delegate = nil
            return
        }

        delegate?.didCapture(image: croppedImage)
    }
}
#endif
#endif

extension CardScannerModel {
    /// The aspect ratio of credit-card is Golden-ratio
    static let heightRatioAgainstWidth: CGFloat = 0.6180469716
    static let backLayerRatioAgainstWidth: CGFloat = 0.628378
}
