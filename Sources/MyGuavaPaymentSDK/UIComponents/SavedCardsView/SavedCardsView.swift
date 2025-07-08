//
//  SavedCardsView.swift
//  MyGuavaPaymentSDK
//
//  Created by Ignat Chegodaykin on 20.06.2025.
//

import UIKit
import SnapKit
import SkeletonView

final class SavedCardsView: UIView {
    /// Segment control action
    var onChangeSegmentControl: ((Int) -> Void)?
    var onEditButtonTapped: ((IndexPath) -> Void)?
    var onDeleteButtonTapped: ((IndexPath) -> Void)?

    enum Section: Int {
        case savedCards
        case newCard
    }

    private var cards: [Section: [[SavedCardsCellKind]]] = [:] {
        didSet {
            tableView.reloadData()
        }
    }

    // save the indexPath of last selected cell
    private var lastSelectedIndexPath: IndexPath? {
        didSet {
            reloadVisibleCellsSelected()
        }
    }

    private func reloadVisibleCellsSelected() {
        for cell in tableView.visibleCells {
            guard let cell = cell as? CardCell else {
                continue
            }
            if let indexPath = tableView.indexPath(for: cell) {
                cell.isSelected = indexPath == lastSelectedIndexPath
            }
        }
    }

    private var currentSection: Section = .savedCards {
        didSet {
            tableView.reloadData()
        }
    }

    private lazy var segmentedControl = SegmentedControl(actions: self.configureSegmentActions())
    private lazy var segmentedControlShimmerView: UIView = {
        let view = UIView()
        view.isSkeletonable = true
        return view
    }()

    private let tableView: ContentSizedTableView = {
        let tableView = ContentSizedTableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.register(cellClass: CardCell.self)
        tableView.register(cellClass: NewCardCell.self)
        tableView.registerHeaderFooter(SectionHeaderView.self)
        tableView.backgroundColor = .clear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        tableView.allowsMultipleSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.isSkeletonable = true
        return tableView
    }()

    private var selectedSegmentIndex = 0 {
        didSet {
            guard oldValue != selectedSegmentIndex else { return }
            onChangeSegmentControl?(selectedSegmentIndex)
            tableView.reloadData()
        }
    }

    private(set) var isLoading: Bool = false {
        didSet {
            showShimmerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        showShimmerIfNeeded()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        configureUI()
        addSubviews()
        configureLayout()
    }

    private func configureUI() {
        tableView.dataSource = self
        tableView.delegate = self

        backgroundColor = .background.primary
        segmentedControl.selectedSegmentIndex = 0
    }

    private func addSubviews() {
        addSubviews(
            segmentedControl,
            tableView,
            segmentedControlShimmerView
        )
    }

    private func configureLayout() {
        segmentedControl.snp.makeConstraints {
            $0.top.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(CGFloat.spacing1000)
        }

        segmentedControlShimmerView.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.directionalEdges.equalTo(segmentedControl)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(20)
            $0.bottom.directionalHorizontalEdges.equalToSuperview()
        }
    }

    private func configureSegmentActions() -> [UIAction] {
        let savedCardsAction = UIAction(title: "Saved cards", state: .on) { [weak self] _ in
            self?.currentSection = .savedCards
            self?.onChangeSegmentControl?(0)
        }

        let newCardAction = UIAction(title: "New card", state: .on) { [weak self] _ in
            self?.currentSection = .newCard
            self?.onChangeSegmentControl?(1)
        }

        return [savedCardsAction, newCardAction]
    }

    private func showShimmerIfNeeded() {
        if isLoading {
            segmentedControlShimmerView.isHidden = false
            tableView.showAnimatedGradientSkeleton()
            startShimmering()
        } else {
            segmentedControlShimmerView.isHidden = true
            tableView.hideSkeleton()
            stopShimmering()
        }
    }

    /// Shows shimmer loading
    public func showLoading() {
        isLoading = true
    }

    /// Hides shimmer loading
    public func hideLoading() {
        isLoading = false
    }

    func setCardsData(_ data: [Section: [[SavedCardsCellKind]]]) {
        cards = data
    }
}

extension SavedCardsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexPath = indexPath
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentSection == .savedCards {
            let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
            view?.titleLabel.text = "Not available for this payment"
            return view
        }
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentSection == .savedCards {
            return section == 1 ? 24 : 0
        }
        return 0
    }
}

extension SavedCardsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cards[currentSection]?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards[currentSection]?[safe: section]?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = cards[currentSection],
              let cellKind = type[safe: indexPath.section]?[indexPath.row] else {
            return UITableViewCell()
        }

        return cell(forKind: cellKind, tableView: tableView, indexPath: indexPath)
    }
}


// MARK: - SavedCardsView + CardCell

private extension SavedCardsView {
    func cell(
        forKind kind: SavedCardsCellKind,
        tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        switch kind {
        case let .card(viewModel):
            return makeDefaultCell(viewModel, tableView, indexPath)
        case .addNewCard:
            return makeAddNewCardCell(tableView, indexPath)
        case .error:
            return UITableViewCell()
        }
    }

    func makeDefaultCell(
        _ viewModel: Binding,
        _ tableView: UITableView,
        _ indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeue(
            cellClass: CardCell.self,
            for: indexPath
        ) else {
            return UITableViewCell()
        }

        if indexPath.row == 0 && lastSelectedIndexPath == nil {
            lastSelectedIndexPath = indexPath
            cell.isSelected = true
        } else {
            cell.isSelected = lastSelectedIndexPath == indexPath
        }

        cell.configure(with: viewModel)

        cell.onEditButtonTapped = { [weak self] in
            self?.onEditButtonTapped?(indexPath)
        }

        cell.onDeleteButtonTapped = { [weak self] in
            self?.onDeleteButtonTapped?(indexPath)
        }

        return cell
    }

    func makeAddNewCardCell(
        _ tableView: UITableView,
        _ indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeue(
            cellClass: NewCardCell.self,
            for: indexPath
        ) else {
            return UITableViewCell()
        }

        cell.onSaveCardTapped = { [weak self] in
            // tell the tableView to re-run its layout
            self?.tableView.performBatchUpdates(nil, completion: nil)
        }

        return cell
    }
}


// MARK: - SavedCardsView + SkeletonTableViewDataSource

extension SavedCardsView: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        1
    }

    func collectionSkeletonView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        3
    }

    func collectionSkeletonView(
        _ skeletonView: UITableView,
        skeletonCellForRowAt indexPath: IndexPath
    ) -> UITableViewCell? {
        guard let cell = skeletonView.dequeue(cellClass: CardCell.self, for: indexPath) else {
            return UITableViewCell()
        }

        cell.showLoading()

        return cell
    }

    func collectionSkeletonView(
        _: UITableView,
        cellIdentifierForRowAt _: IndexPath
    ) -> ReusableCellIdentifier {
        CardCell.reuseId
    }
}


// MARK: - ApplePayButtonView + ShimmerableView

extension SavedCardsView: ShimmerableView {
    public var shimmeringViews: [UIView] {
        [segmentedControlShimmerView]
    }

    public var shimmeringViewsCornerRadius: [UIView: ShimmerableViewConfiguration.ViewCornerRadius] {
        [segmentedControlShimmerView: .value(21)]
    }
}
