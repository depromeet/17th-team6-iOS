//
//  RunningNavigationBar.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/14/25.
//

import UIKit

protocol NavigationBarDelegate: AnyObject {
    func didTapBackButton()
    func didSelectSegment(at index: Int)
}

final class RunningNavigationBar: UIView {
    weak var delegate: NavigationBarDelegate?

    private let segmentBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF0F3F8)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let selectedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFill
        return button
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.insertSegment(withTitle: "목표", at: 0, animated: true)
        segment.insertSegment(withTitle: "지도", at: 1, animated: true)
        segment.selectedSegmentIndex = 0

        segment.backgroundColor = .clear
        segment.selectedSegmentTintColor = .clear

        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(hex: 0x676D76),
            NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .bold)
        ], for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .bold)
        ], for: .selected)

        segment.layer.cornerRadius = 8
        segment.clipsToBounds = true

        // 세그먼트 간 간격을 위한 divider 설정
        let dividerImage = UIImage()
        segment.setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        // 각 세그먼트의 배경 이미지를 투명하게 설정
        let transparentImage = createTransparentImage()
        segment.setBackgroundImage(transparentImage, for: .normal, barMetrics: .default)
        segment.setBackgroundImage(transparentImage, for: .selected, barMetrics: .default)

        // 세그먼트 간 간격을 위한 content position 조정
        segment.setContentPositionAdjustment(UIOffset(horizontal: -4, vertical: 0), forSegmentType: .left, barMetrics: .default)
        segment.setContentPositionAdjustment(UIOffset(horizontal: 4, vertical: 0), forSegmentType: .right, barMetrics: .default)

        return segment
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        addAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        addSubviews(backButton, segmentBackgroundView, selectedBackgroundView, segmentedControl)

        self.backgroundColor = .clear

        updateSelectedBackgroundPosition()

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            segmentBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            segmentBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            segmentBackgroundView.widthAnchor.constraint(equalToConstant: 267),
            segmentBackgroundView.heightAnchor.constraint(equalToConstant: 44),

            segmentedControl.centerXAnchor.constraint(equalTo: segmentBackgroundView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: segmentBackgroundView.centerYAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: segmentBackgroundView.widthAnchor),
            segmentedControl.heightAnchor.constraint(equalTo: segmentBackgroundView.heightAnchor)
        ])
    }
    
    private func addAction() {
        let backButtonAction = UIAction { [weak self] _ in
            self?.delegate?.didTapBackButton()
        }
        backButton.addAction(backButtonAction, for: .touchUpInside)
        
        let segmentAction = UIAction { [weak self] action in
            guard let segment = action.sender as? UISegmentedControl else { return }
            print("Selected segment index: \(segment.selectedSegmentIndex)")
            self?.animateSelectedBackgroundPosition()
            self?.delegate?.didSelectSegment(at: segment.selectedSegmentIndex)
        }
        segmentedControl.addAction(segmentAction, for: .valueChanged)
    }

    private var selectedBackgroundConstraints: [NSLayoutConstraint] = []

    private func updateSelectedBackgroundPosition() {
        NSLayoutConstraint.deactivate(selectedBackgroundConstraints)
        selectedBackgroundConstraints.removeAll()

        guard segmentBackgroundView.frame != .zero else { return }

        let segmentWidth = segmentBackgroundView.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let xOffset = segmentBackgroundView.frame.minX + (segmentWidth * CGFloat(selectedIndex))
        
        let paddingSize: CGFloat = 6
        
        selectedBackgroundConstraints = [
            selectedBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xOffset + paddingSize),
            selectedBackgroundView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: xOffset + segmentWidth - paddingSize),
            selectedBackgroundView.topAnchor.constraint(equalTo: segmentBackgroundView.topAnchor, constant: paddingSize),
            selectedBackgroundView.bottomAnchor.constraint(equalTo: segmentBackgroundView.bottomAnchor, constant: -paddingSize)
        ]

        NSLayoutConstraint.activate(selectedBackgroundConstraints)
    }

    private func animateSelectedBackgroundPosition() {
        NSLayoutConstraint.deactivate(selectedBackgroundConstraints)
        selectedBackgroundConstraints.removeAll()

        guard segmentBackgroundView.frame != .zero else { return }

        let segmentWidth = segmentBackgroundView.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let xOffset = segmentBackgroundView.frame.minX + (segmentWidth * CGFloat(selectedIndex))

        selectedBackgroundConstraints = [
            selectedBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xOffset + 8),
            selectedBackgroundView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: xOffset + segmentWidth - 8),
            selectedBackgroundView.topAnchor.constraint(equalTo: segmentBackgroundView.topAnchor, constant: 8),
            selectedBackgroundView.bottomAnchor.constraint(equalTo: segmentBackgroundView.bottomAnchor, constant: -8)
        ]

        NSLayoutConstraint.activate(selectedBackgroundConstraints)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectedBackgroundPosition()
    }

    private func createTransparentImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    func setSegmentedControlIndex(to index: Int) {
        guard index >= 0 && index < segmentedControl.numberOfSegments else { return }
        segmentedControl.selectedSegmentIndex = index
        animateSelectedBackgroundPosition()
    }
}
