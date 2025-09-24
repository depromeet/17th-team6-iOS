//
//  AgrementCell.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/25/25.
//

import UIKit

final class AgrementCell: UITableViewCell {
    static let identifier = "RunningLevelCell"
    
    // MARK: UI
    
    private let checkButton: UIButton = {
        let button = UIButton(configuration: .miniCheckmark(isChecked: false))
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let titleLabel = UILabel()
    
    private let arrowButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)
        config.image = UIImage(systemName: "chevron.forward", withConfiguration: imageConfig)
        config.imagePadding = 0
        config.baseForegroundColor = UIColor(hex: 0x585D64)
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: Object lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Setup
    
    private func setupView() {
        selectionStyle = .none
        
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        [checkButton, titleLabel, arrowButton].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            checkButton.topAnchor.constraint(equalTo: container.topAnchor),
            checkButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 32),
            checkButton.heightAnchor.constraint(equalToConstant: 32),
            checkButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            
            arrowButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            arrowButton.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            arrowButton.widthAnchor.constraint(equalToConstant: 32),
            arrowButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: Configure
    
    func configure(with agreement: DisplayedAgreement) {
        titleLabel.attributedText = .withLetterSpacing(
            text: agreement.title,
            font: .pretendard(size: 16, weight: .regular),
            px: -0.2,
            color: .init(hex: 0x585D64)
        )
        
        checkButton.configuration = .miniCheckmark(isChecked: agreement.isChecked)
    }
}
