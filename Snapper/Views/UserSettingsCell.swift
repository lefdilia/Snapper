//
//  UserSettingsCell.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 24/8/2021.
//

import UIKit

class UserSettingsCell: UITableViewCell {
    
    var _setting: Settings? {
        didSet{
            guard let _Setting = _setting else { return }
            optionTitle.text = _Setting.title
            optionSlogan.text = !_Setting.slogan!.isEmpty ? " \(_Setting.slogan!)" : ""
            optionValues.text = _Setting._values
        }
    }

    static let identifier = "UserSettingsCell"
    static let headerIdentifier = "UserSettingsHeaderCell"
    
    let optionTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        let attributedText = NSMutableAttributedString(string: "--", attributes: [
                                                        .font: UIFont.systemFont(ofSize: 16, weight: .regular) as Any,
                                                        .foregroundColor: UIColor.neebGray as Any])
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let optionSlogan: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        let attributedText = NSMutableAttributedString(string: "--", attributes: [
                                                        .font: UIFont.systemFont(ofSize: 14, weight: .light) as Any,
                                                        .foregroundColor: UIColor.neebGray as Any])
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stacktitle: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [optionTitle, optionSlogan])
        stack.axis = .vertical
        stack.setCustomSpacing(5, after: optionTitle)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let optionValues: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        let attributedText = NSMutableAttributedString(string: " ", attributes: [
                                                        .font: UIFont.systemFont(ofSize: 14, weight: .light) as Any,
                                                        .foregroundColor: UIColor.neebGray as Any])
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stacktitle)
        contentView.addSubview(optionValues)

        NSLayoutConstraint.activate([
            stacktitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stacktitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            optionValues.centerYAnchor.constraint(equalTo: centerYAnchor),
            optionValues.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
