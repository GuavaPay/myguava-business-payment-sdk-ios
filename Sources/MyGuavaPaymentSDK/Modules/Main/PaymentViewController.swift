//
//  PaymentViewController.swift
//  MyGuavaPaymentSDK
//
//  Created by Said Kagirov on 11.06.2025.
//

import UIKit
import SnapKit

public final class PaymentViewController: UIViewController, PaymentViewInput {

    private let maxDimmedAlpha: CGFloat = 0.6
    private let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100

    private var containerViewHeightConstraint: Constraint?
    private var containerViewBottomConstraint: Constraint?

    private var isFirstShow: Bool = true

    /// Tracks the currently focused input for keyboard handling
    private weak var activeInputView: UIView?

    private let confirmButtonView = Button(
        config: Button.Config(
            type: .text("Pay"),
            state: .disabled,
            scheme: Button.Scheme.primary,
            size: .large
        )
    )
    private let applePayButtonView = ApplePayButtonView()
    private let cardInformationView = CardInformationView()
    private let separatorView = SeparatorWithTextView()

    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = Icons.close
        button.setImage(image, for: .normal)
        button.tintColor = .background.inverse
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UICustomization.Common.backgroundColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let savedCardsView = SavedCardsView()

    private let contactInformationView = ContactInformationView()

    private let paymentsImageContainer = UIView()

    private let paymentsImageStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()

    private let bottomSpacer = UIView()

    var output: PaymentViewOutput?

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupLayout()
        configureViews()
        setupPanGesture()
        bindActions()
        setupKeyboardObservers()
        output?.viewDidLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Need for fix animate present after scan qr
        if isFirstShow {
            updatePreferredHeight()
            animatePresentContainer()
            isFirstShow = false
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Need for correct update layout height
        if !isFirstShow {
            updatePreferredHeight()
        }
    }

    func showLoading(_ isLoading: Bool) {
        if isLoading {
            applePayButtonView.showLoading()
            separatorView.showLoading()
            savedCardsView.showLoading()
            cardInformationView.showLoading()
            contactInformationView.showLoading()
            confirmButtonView.showLoading()
            paymentsImageStack.isHidden = true
            bottomSpacer.isHidden = true
        } else {
            applePayButtonView.hideLoading()
            separatorView.hideLoading()
            savedCardsView.hideLoading()
            cardInformationView.hideLoading()
            contactInformationView.hideLoading()
            confirmButtonView.hideLoading()
            paymentsImageStack.isHidden = false
            bottomSpacer.isHidden = false
        }
    }

    func closeView() {
        animateDismissView()
    }

    func showCardNumberState(_ state: CardNumberState) {
        cardInformationView.cardNumberView.showState(state)
    }

    func showSecurityCodeState(_ state: CardSecurityCodeState) {
        cardInformationView.securityCodeView.showState(state)
    }

    func showAvailableCardSchemes(_ icons: [UIImage]) {
        paymentsImageStack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        icons.forEach {
            let imageView = UIImageView(image: $0)
            imageView.contentMode = .scaleAspectFit
            imageView.setContentHuggingPriority(.required, for: .horizontal)
            paymentsImageStack.addArrangedSubview(imageView)
        }
    }

    func setCardNumber(_ model: CardScannerModel) {
        if let number = model.number {
            cardInformationView.cardNumberView.setCardNumber(number)
        }

        if let expireDate = model.expireDate {
            cardInformationView.expirationView.setExpirationDate(expireDate)
        }
    }

    func setSecurityCodeLength(_ length: Int) {
        cardInformationView.setSecurityCodeLength(length)
    }

    func configureSaveCards(_ saveCards: [SavedCardsView.Section : [[SavedCardsCellKind]]]) {
        savedCardsView.setCardsData(saveCards)
    }

    func selectSegmentControl(index: Int) {
        savedCardsView.setSelectedSegment(index: index)
    }

    func hideApplePayment() {
        applePayButtonView.isHidden = true
        separatorView.isHidden = true // later need move to apple pay button
    }

    func disablePaymentCard() {
        confirmButtonView.setState(.disabled)
        cardInformationView.disable()
        contactInformationView.isHidden = true
    }

    func disableAllPayments() {
        disablePaymentCard()
        applePayButtonView.isUserInteractionEnabled = false
    }

    func disableSaveCards() {
        savedCardsView.isHidden = true
        cardInformationView.isHidden = false
    }

    func hideSaveCards(_ isHidden: Bool) {
        savedCardsView.setHidden(isHidden)
        cardInformationView.isHidden = !isHidden
    }

    func setIsBindingAvailable(_ isBindingAvailable: Bool) {
        cardInformationView.setSaveCardCheckboxVisible(isBindingAvailable)
    }

    func hideCardholderInput() {
        cardInformationView.hideCardholderInput()
    }

    func nextActiveInputIfAvailable() {
        cardInformationView.nextActiveInputIfAvailable()
    }

    private func configureViews() {
        applePayButtonView.onTap = { [weak self] in
            self?.output?.didTapApplePay()
        }
        cardInformationView.cardNumberView.onChangeDigits = { [weak self] digits in
            self?.output?.didChangeCardNumber(digits: digits)
        }
        cardInformationView.onFieldEndEditing = { [weak self] field in
            self?.output?.didEndEditing(field: field)
        }
        cardInformationView.onScanButtonTapped = { [weak self] in
            self?.output?.didTapScanCard()
        }
        cardInformationView.onSaveCardTapped = { [weak self] needSaveCard in
            self?.output?.didTapSaveNewCard(needSaveCard)
        }
        cardInformationView.onNewCardNameTextChange = { [weak self] text in
            self?.output?.didChangeNewCardName(text)
        }

        savedCardsView.onChangeSegmentControl = { [weak self] index in
            let showSaveCards = index == 0
            self?.hideSaveCards(!showSaveCards)
            self?.updatePreferredHeight()
            self?.output?.didSelectSavedCards(showSaveCards)
        }

        savedCardsView.onCVVCodeEndEditing = { [weak self] index, code in
            self?.output?.didChangeSavedCardCVV(index, code: code)
        }

        savedCardsView.onFieldEndEditing = { [weak self] field in
            self?.output?.didEndEditing(field: field)
        }
    }

    private func addSubviews() {
        view.backgroundColor = .clear
        view.addSubview(dimmedView)
        view.addSubview(containerView)

        stackView.addArrangedSubviews(
            applePayButtonView,
            separatorView,
            savedCardsView,
            cardInformationView,
            contactInformationView,
            paymentsImageContainer,
            bottomSpacer
        )

        savedCardsView.isHidden = false
        cardInformationView.isHidden = true

        stackView.setCustomSpacing(24, after: separatorView)

        containerView.addSubviews(
            scrollView,
            confirmButtonView,
            closeButton
        )

        scrollView.addSubview(stackView)

        paymentsImageContainer.addSubview(paymentsImageStack)

        closeButton.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)
    }

    private func setupLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            containerViewBottomConstraint = $0.bottom.equalToSuperview().offset(300).constraint
            containerViewHeightConstraint = $0.height.equalTo(300).constraint
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(16)
            $0.leading.equalTo(containerView).offset(16)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(containerView)
            $0.bottom.equalTo(confirmButtonView.snp.top).offset(-12)
        }

        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.edges.equalTo(scrollView).inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }

        paymentsImageStack.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        confirmButtonView.snp.makeConstraints {
            $0.leading.trailing.equalTo(containerView).inset(16)
            $0.bottom.equalTo(containerView).inset(32)
            $0.height.equalTo(48)
        }

        bottomSpacer.snp.makeConstraints {
            $0.height.equalTo(30)
        }
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
    }

    private func bindActions() {
        contactInformationView.onSelectPhoneCode = { [weak self] in
            self?.output?.didTapSelectPhoneCodeButton()
        }

        contactInformationView.onSaveButton = { [weak self] phoneNumber, email in
            self?.output?.didTapContactInformationSaveButton(phoneNumber: phoneNumber, email: email)
        }

        savedCardsView.onEditButtonTapped = { [weak self] indexPath in
            self?.output?.didTapEditCardButton(indexPath: indexPath)
        }

        savedCardsView.onDeleteButtonTapped = { [weak self] indexPath in
            self?.output?.didTapDeleteCardButton(indexPath: indexPath)
        }

        confirmButtonView.setAction { [weak self] in
            self?.output?.didTapConfirmButton()
        }

        contactInformationView.onChangeInfo = { [weak self] editing in
            self?.output?.didTapChangeInfo(editing: editing)
        }
    }

    private func setupKeyboardObservers() {
        hideKeyboardWhenTappedAround()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidBeginEditing(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidEndEditing(_:)),
            name: UITextField.textDidEndEditingNotification,
            object: nil
        )
    }

    private func handleDismissView() {
        // Need for correct update layout height
        isFirstShow = true
        output?.didCloseViewByUser()
        animateDismissView()
    }

    @objc
    func updatePreferredHeight() {
        view.layoutIfNeeded()

        let contentHeight = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let fixedBottomPadding: CGFloat = 30 + 48 + 12
        let topInset: CGFloat = 16 + 24 + 16
        let totalHeight = contentHeight + fixedBottomPadding + topInset
        let exceedsMaxHeight = totalHeight > maximumContainerHeight
        let finalHeight = min(totalHeight, maximumContainerHeight)

        containerViewHeightConstraint?.update(offset: finalHeight)
        containerViewBottomConstraint?.update(offset: 0)
        scrollView.isScrollEnabled = exceedsMaxHeight

        self.view.layoutIfNeeded()
    }

    private func animatePresentContainer() {
        containerView.transform = CGAffineTransform(translationX: 0, y: containerViewHeightConstraint?.layoutConstraints.first?.constant ?? 400)
        dimmedView.alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut]) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            self.containerView.transform = .identity
        }
    }

    private func animateDismissView() {
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 0.0
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn]) {
            self.containerViewBottomConstraint?.update(offset: self.containerViewHeightConstraint?.layoutConstraints.first?.constant ?? 300)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    @objc
    private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: containerView)
        let velocity = recognizer.velocity(in: containerView)

        if recognizer.state == .changed && translation.y > 0 {
            containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if recognizer.state == .ended {
            if translation.y > 100 || velocity.y > 1000 {
                handleDismissView()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.containerView.transform = .identity
                }
            }
        }
    }

    @objc
    private func handleCloseButton() {
        handleDismissView()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view == dimmedView {
            handleDismissView()
        }
    }

    func configureSelectCountry(_ country: CountryResponse) {
        contactInformationView.configureSelectCountry(country)
    }

    func configureValidEmailField(_ isValid: Bool) {
        contactInformationView.configureValidEmailField(isValid)
    }

    func configureConfirmButton(with state: Button.State) {
        confirmButtonView.setState(state)
    }

    func configureConfirmButton(text: String) {
        confirmButtonView.setText(text)
    }

    func setCurrentContactInformation(_ data: Payer?) {
        contactInformationView.setCurrentData(data)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = frameValue.cgRectValue.height
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = insets
        scrollView.verticalScrollIndicatorInsets = insets
        if let active = activeInputView {
            let rect = active.convert(active.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let insets = UIEdgeInsets.zero
        scrollView.contentInset = insets
        scrollView.verticalScrollIndicatorInsets = insets
    }

    @objc private func textFieldDidBeginEditing(_ notification: Notification) {
        activeInputView = notification.object as? UIView
    }

    @objc private func textFieldDidEndEditing(_ notification: Notification) {
        activeInputView = nil
    }
}
