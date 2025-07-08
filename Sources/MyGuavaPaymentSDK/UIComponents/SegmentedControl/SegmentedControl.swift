//
//  SegmentedControl.swift
//
//
//  Created by Mikhail Kirillov on 25/6/24.
//

import UIKit

public final class SegmentedControl: UISegmentedControl {

    // MARK: - Properties
    public struct SegmentItem {
        let title: String
        let action: (Int) -> Void

        public init(title: String, action: @escaping (Int) -> Void) {
            self.title = title
            self.action = action
        }
    }

    // MARK: - Private properties

    private var segments = [SegmentItem]()
    private var style: Style

    // MARK: - Init

    /// Creates a segmented control with segments having the given titles or images.
    public init(segmentItems: [SegmentItem] = [], style: Style = StockStyle()) {
        self.segments = segmentItems
        self.style = style
        super.init(items: segmentItems.map{ $0.title })
        applyStyle()
    }

    /// Creates a segmented control with segments having the given titles or images.
    public init(actions: [UIAction], style: Style = StockStyle()) {
        self.style = style
        super.init(items: actions)

        applyStyle()
    }

    /// Creates a segmented control with segments  using Strings, UIImages or UIActions
    public init(items: [Any], style: Style = StockStyle()) {
        self.style = style
        super.init(items: items)

        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    public override func actionForSegment(at segment: Int) -> UIAction? {
        guard !segments.isEmpty, let item = segments[safe: segment] else {
            if #available(iOS 14.0, *) {
                return super.actionForSegment(at: segment)
            } else {
                return nil
            }
        }
        return UIAction(title: item.title) { _ in
            item.action(segment)
        }
    }
    
    /// Inserts SegmentItem at given index
    /// - Parameters:
    ///   - item: item for insertion
    ///   - segment: index for insertion
    ///   - animated: animate segments change, default is true
    public func insertSegment(_ item: SegmentItem, at segment: Int, animated: Bool = true) {
        segments.insert(item, at: segment)
        if #available(iOS 14.0, *) {
            self.insertSegment(action: UIAction(title: item.title, handler: { _ in
                item.action(segment)
            }), at: segment, animated: animated)
        } else {
            self.insertSegment(withTitle: item.title, at: segment, animated: animated)
        }
    }
    
    /// Sets view's segments
    /// - Parameters:
    ///   - items: array of SegmentItem
    ///   - animated: animate segments change, default is false
    public func setSegments(_ items: [SegmentItem], animated: Bool = false) {
        segments = items
        segments.enumerated().forEach { index, segment in
            insertSegment(segment, at: index, animated: animated)
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }
        applyStyle()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: CGFloat.spacing1000)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2

        let foregroundIndex = numberOfSegments

        if selectedSegmentIndex >= 0,
           subviews.indices.contains(foregroundIndex),
           let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: 5, dy: 5)
            foregroundImageView.image = UIImage(color: style.tintColor)

            // this removes the weird scaling animation
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")

            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height / 2
            foregroundImageView.layer.masksToBounds = true

            foregroundImageView.backgroundColor = style.tintColor
        }
    }

    // MARK: - Private methods

    private func applyStyle() {
        let selectedAttributes = [
            NSAttributedString.Key.font: style.selectedFontStyle,
            NSAttributedString.Key.foregroundColor: style.selectedForegroundColor
        ]

        let attributes = [
            NSAttributedString.Key.font: style.fontStyle,
            NSAttributedString.Key.foregroundColor: style.foregroundColor
        ]

        setTitleTextAttributes(selectedAttributes, for: .selected)
        setTitleTextAttributes(attributes, for: .normal)
    }
}
