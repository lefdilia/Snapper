//
//  SettingsSwitchCell.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 27/8/2021.
//

import UIKit

class SettingsSwitchCell: UITableViewCell {
    
    var _setting: SettingsMitSwitch? {
        didSet{
            guard let _Setting = _setting else { return }
            optionTitle.text = _Setting.title
            optionSlogan.text = _Setting.slogan
            mSwitch.isOn = _Setting.isOn
        }
    }
    
    static let identifier = "SettingsSwitchCell"
    static let headerIdentifier = "SettingsSwitchHeaderCell"
    
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
                                                        .font: UIFont.systemFont(ofSize: 15, weight: .light) as Any,
                                                        .foregroundColor: UIColor.neebGray as Any])
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stacktitle: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [optionTitle, optionSlogan])
        stack.axis = .vertical
        stack.setCustomSpacing(8, after: optionTitle)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    lazy var mSwitch: UISwitch = {
        let _switch = UISwitch()
        _switch.onTintColor = .systemGreen
        _switch.translatesAutoresizingMaskIntoConstraints = false
        _switch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return _switch
    }()
    
    @objc func switchChanged(sender: UISwitch){
        switch sender.tag {
        case 0:
            UserDefaults.standard.setValue(sender.isOn, forKey: "highResolution")
        case 1:
            UserDefaults.standard.setValue(sender.isOn, forKey: "autoSaveToPhotos")
        default: break
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(stacktitle)
        contentView.addSubview(mSwitch)
        
        NSLayoutConstraint.activate([
            stacktitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stacktitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            mSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            mSwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}
