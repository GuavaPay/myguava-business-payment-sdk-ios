//
//  EditCardNamePopupRouter.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 23.06.2025.
//

import UIKit

final class EditCardNamePopupViewController: UIViewController, EditCardNamePopupViewInput {

    var output: EditCardNamePopupViewOutput?

    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .alphaBlack100
        return view
    }()
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.backgroundColor = .background.primary
        stackView.layer.cornerRadius = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
        return stackView
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .title3Semibold
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .foreground.onAccent
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .body2Regular
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .foreground.onAccentSecondary
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        return label
    }()
    private let inputContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    private let inputField = InputField(placeholderText: "Card name")
    private let inputTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Card name"
        label.font = .body1Regular
        label.textColor = .input.primaryForeground
        return label
    }()
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private var buttonConfigs: [Button] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        animateIn()
        output?.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animateOut()
    }

    private func setupView() {
        inputContainerStackView.addArrangedSubviews(
            inputTitleLabel,
            inputField
        )
        containerStackView.addArrangedSubviews(
            iconImageView,
            titleLabel,
            messageLabel,
            inputContainerStackView,
            buttonsStackView
        )
        backgroundContainerView.addSubview(containerStackView)
        view.addSubview(backgroundContainerView)

        containerStackView.setCustomSpacing(16, after: messageLabel)
        containerStackView.setCustomSpacing(24, after: inputContainerStackView)

        backgroundContainerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        )

        inputField.didChangeText = { [weak self] text in
            self?.output?.didChangeCardNameText(text)
        }
    }

    private func setupLayout() {
        backgroundContainerView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        containerStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
    }

    func setConfig(_ config: PopupConfig) {
        iconImageView.image = config.icon
        iconImageView.isHidden = config.icon == nil
        titleLabel.text = config.title
        titleLabel.isHidden = config.title == nil
        messageLabel.text = config.message
        messageLabel.isHidden = config.message == nil
        buttonConfigs = config.buttons ?? []

        guard let buttons = config.buttons else {
            return
        }

        for button in buttons {
            button.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }
        buttonsStackView.addArrangedSubviews(buttons)
    }

    @objc private func buttonTapped() {
        output?.buttonTapped()
    }

    @objc
    private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: backgroundContainerView)
        let inputFrame = backgroundContainerView.convert(containerStackView.frame, from: backgroundContainerView)
        if inputFrame.contains(tapLocation) {
            gesture.cancelsTouchesInView = false
            return
        }

        output?.buttonTapped()
    }

    private func animateIn() {
        containerStackView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        containerStackView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.containerStackView.transform = CGAffineTransform.identity
            self.containerStackView.alpha = 1
        }
    }

    private func animateOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerStackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerStackView.alpha = 0
        })
    }
}
