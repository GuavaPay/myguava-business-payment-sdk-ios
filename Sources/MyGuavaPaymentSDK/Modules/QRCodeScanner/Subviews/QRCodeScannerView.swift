//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import AVFoundation
import UIKit
import VideoToolbox

private enum Constants {
    static let frameStrokeColor: UIColor = .white
    static let maskLayerColor: UIColor = .black
    static let maskLayerAlpha: CGFloat = 0.7
    static let heightRatioAgainstWidth: CGFloat = 0.9
    static let cornerRadius: CGFloat = 20
}

final class QRCodeScannerView: UIView {
    var onBack: (() -> Void)?
    var onFlash: (() -> Void)?
    var onFound: ((String) -> Void)?

    private let imageRatio: ImageRatio = .vga640x480

    // MARK: - Region of interest and text orientation

    /// Region of video data output buffer that recognition should be run on.
    /// Gets recalculated once the bounds of the preview layer are known.
    private var regionOfInterest: CGRect?

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("AVCaptureVideoPreviewLayer")
        }
        return layer
    }

    private var videoSession: AVCaptureSession? {
        didSet {
            videoPreviewLayer.session = videoSession
        }
    }

    override static var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupView()
        setupLayout()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let headerTitleLabel = UILabel()
    private let backButton = ExtendedTapAreaButton(type: .system)
    private let flashButton = ExtendedTapAreaButton(type: .system)
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()

    private func setupView() {
        backgroundColor = .black

        backButton.tintColor = .white
        backButton
            .setImage(Icons.backArrow.withRenderingMode(.alwaysTemplate), for: .normal)

        flashButton.tintColor = .white
        flashButton.setImage(Icons.flash, for: .normal)

        headerTitleLabel.font = .headlineSemibold
        headerTitleLabel.textColor = .white
        headerTitleLabel.textAlignment = .center
    }

    func setupLayout() {
        addSubview(headerStackView)
        headerStackView.addArrangedSubviews(
            backButton,
            headerTitleLabel,
            flashButton
        )

        backButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        flashButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        headerStackView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(32)
            $0.top.equalToSuperview().inset(75)
        }
    }

    private func bindActions() {
        flashButton.addTarget(self, action: #selector(flastButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    func startSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = imageRatio.preset

        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            return
        }

        do {
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            session.canAddInput(deviceInput)
            session.addInput(deviceInput)
        } catch {
            debugPrint(error)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true

        guard session.canAddOutput(videoOutput) else {
            return
        }

        session.addOutput(videoOutput)
        session.connections.forEach {
            $0.videoOrientation = .portrait
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        session.commitConfiguration()

        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoSession = session
        DispatchQueue.global().async { [weak self] in
            self?.videoSession?.startRunning()
        }
    }

    func stopSession() {
        videoSession?.stopRunning()
    }

    func viewDidLayoutSubviews() {
        setupRegionOfInterest()
    }

    func updateFlash(_ isOn: Bool) {
        flashButton.setImage(
            isOn ? Icons.flashOn : Icons.flash,
            for: .normal
        )
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            return
        }

        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: 1.0)
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func updateTitle(_ title: String) {
        headerTitleLabel.text = title
    }

    private func setupRegionOfInterest() {
        guard regionOfInterest == nil else {
            return
        }
        let backLayer = CALayer()
        backLayer.frame = bounds
        backLayer.backgroundColor = Constants.maskLayerColor.withAlphaComponent(Constants.maskLayerAlpha)
            .cgColor

        let cuttedWidth = bounds.width - 20 * 2
        let cuttedHeight = cuttedWidth

        let cuttedY = (frame.size.height - cuttedWidth) / 2
        let cuttedX: CGFloat = 20

        let cuttedRect = CGRect(
            x: cuttedX,
            y: cuttedY,
            width: cuttedWidth,
            height: cuttedHeight
        )

        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: cuttedRect, cornerRadius: Constants.cornerRadius)

        path.append(UIBezierPath(rect: bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        backLayer.mask = maskLayer
        layer.addSublayer(backLayer)

        let strokeLayer = CAShapeLayer()
        strokeLayer.lineWidth = 1
        strokeLayer.strokeColor = Constants.frameStrokeColor.cgColor
        strokeLayer.lineDashPattern = [3, 1]
        strokeLayer.path = UIBezierPath(roundedRect: cuttedRect, cornerRadius: Constants.cornerRadius).cgPath
        strokeLayer.fillColor = nil
        layer.addSublayer(strokeLayer)

        let imageHeight = imageRatio.imageHeight
        let imageWidth = imageRatio.imageWidth

        let acutualImageRatioAgainstVisibleSize = imageWidth / bounds.width
        let interestX = cuttedRect.origin.x * acutualImageRatioAgainstVisibleSize
        let interestWidth = cuttedRect.width * acutualImageRatioAgainstVisibleSize
        let interestHeight = interestWidth * Constants.heightRatioAgainstWidth
        let interestY = (imageHeight / 2.0) - (interestHeight / 2.0)
        regionOfInterest = CGRect(
            x: interestX,
            y: interestY,
            width: interestWidth,
            height: interestHeight
        )
        bringSubviewToFront(headerStackView)
    }

    @objc
    private func backButtonTapped() {
        onBack?()
    }

    @objc
    private func flastButtonTapped() {
        onFlash?()
    }

    private func found(code: String) {
        onFound?(code)
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension QRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from _: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        found(code: stringValue)
    }
}
