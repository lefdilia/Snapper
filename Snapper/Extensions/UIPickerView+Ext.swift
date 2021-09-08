//
//  UIPickerView+Ext.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 28/8/2021.
//

import UIKit


extension UserSettingsController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return _timerData.count
        case 2:
            return _photosData.count
        case 3:
            return _orientationData.count
        case 4:
            return _defaultCameraData.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return "\(_timerData[row])"
        case 2:
            return "\(_photosData[row])"
        case 3:
            return _orientationData[row]
        case 4:
            return _defaultCameraData[row]
        default:
            return "--"
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            selectedItem["timer"] = _timerData[row]
        case 2:
            selectedItem["numberOfPhotos"] = _photosData[row]
        case 3:
            selectedItem["orientation"] = "\(_orientationData[row])"
        case 4:
            selectedItem["defaultCamera"] = "\(_defaultCameraData[row])"
        default: return
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }

}

class UIDataPicker: UIPickerView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.SettingBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
