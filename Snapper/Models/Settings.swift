//
//  Settings.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 24/8/2021.
//

import UIKit


struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: Settings)
    case switchCell(model: SettingsMitSwitch)
}

struct Settings {
    let title: String
    let slogan: String?
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    var _values: String
    let handler: (()->Void)
}

struct SettingsMitSwitch {
    let title: String
    let slogan: String?
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (()->Void)
    var isOn: Bool
}
