//
//  UserSettingsController.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 18/8/2021.
//

import UIKit

class UserSettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var settings = [Section]()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.SettingBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    lazy var tempTextView = UITextField(frame: .zero)
    lazy var tempTextView2 = UITextField(frame: .zero)
    lazy var tempTextView3 = UITextField(frame: .zero)
    lazy var tempTextView4 = UITextField(frame: .zero)

    lazy var doneToolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.backgroundColor = UIColor.SettingBackground

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(doneButtonTapped))
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark")?.withTintColor(UIColor.neebGray!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(closeButtonTapped))

        let items = [closeButton, flexSpace, doneButton]
        toolbar.items = items
        toolbar.sizeToFit()

        return toolbar
    }()
        
    lazy var selectedItem: [String: Any] = UserDefaults.standard.object(forKey: AppConfig.appKeys._SettingsKey) as? [String : Any] ?? AppConfig.appKeys._SettingsDefault
    
    var _timerPickerView = UIDataPicker()
    var _photosPickerView = UIDataPicker()
    var _orientationPickerView = UIDataPicker()
    var _defaultCameraPickerView = UIDataPicker()

    let _timerData = AppConfig.appData.timer
    let _photosData = AppConfig.appData.photos
    let _orientationData = AppConfig.appData.orientation
    let _defaultCameraData = AppConfig.appData.defaultCamera
    
    override func viewWillAppear(_ animated: Bool) {
        self.settings = buildData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "User Settings"

        let closeConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: closeConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal),
                            style: .plain, target: self,
                            action: #selector(didTapClose))]
   
        view.addSubview(tableView)
        tableView.register(UserSettingsCell.self, forCellReuseIdentifier: UserSettingsCell.identifier)
        tableView.register(SettingsSwitchCell.self, forCellReuseIdentifier: SettingsSwitchCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        setupPickers()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let setting = settings[indexPath.section].options[indexPath.row]
        
        switch setting.self {
        case .staticCell(let setting):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserSettingsCell.identifier, for: indexPath) as? UserSettingsCell else { return UITableViewCell() }
            cell._setting = setting
            return cell

        case .switchCell(let setting):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSwitchCell.identifier, for: indexPath) as? SettingsSwitchCell else { return UITableViewCell() }
            cell._setting = setting
            cell.mSwitch.tag = indexPath.row
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = settings[indexPath.section].options[indexPath.row]

        switch type.self {
        case .staticCell(let setting):
                setting.handler()
        case .switchCell(let setting):
                setting.handler()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 30
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let title = settings[section].title
        
        let headerView: UIView = {
            let _view = UIView()
            return _view
        }()

        let headerLabel: UILabel = {
            let label = UILabel()
            let attributedText = NSMutableAttributedString(string: title, attributes: [ .font : UIFont.systemFont(ofSize: 16, weight: .regular) as Any,.foregroundColor : UIColor.lightGray as Any ])
            label.attributedText = attributedText
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -9)
        ])

        return headerView

    }

    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let _appName = Bundle.main.appName ?? "--"
        let _appVersion = Bundle.main.appVersion ?? "--"
        let _buildNumber = Bundle.main.buildNumber ?? "0.0.0"

        let sdFooter = "\(_appName) Version \(_appVersion) ( Build \(_buildNumber) )"
        
        let footerView: UIView = {
            let _view = UIView()
            _view.isUserInteractionEnabled = true
            _view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnPortfolio)))
            return _view
        }()


        let footerLabel: UILabel = {
            let label = UILabel()
            
            let attributedText = NSMutableAttributedString(string: "Made with ", attributes: [ .font : UIFont.systemFont(ofSize: 14, weight: .regular) as Any,.foregroundColor : UIColor.lightDark as Any ])
            
            let heartAttachment = NSTextAttachment()
            heartAttachment.image = UIImage(named: "heart-footer")
            heartAttachment.bounds = CGRect(x: 0, y: label.font.descender - 4, width: heartAttachment.image!.size.width, height: heartAttachment.image!.size.height)
            attributedText.append(NSAttributedString(attachment: heartAttachment))
            
            attributedText.append(NSAttributedString(string: " By ", attributes: [ .font : UIFont.systemFont(ofSize: 14, weight: .regular) as Any,.foregroundColor : UIColor.lightDark as Any ]))
            attributedText.append(NSAttributedString(string: "Lefdilia", attributes: [ .font : UIFont.systemFont(ofSize: 14, weight: .heavy) as Any,.foregroundColor : UIColor.lightDark as Any ]))

            attributedText.append(NSAttributedString(string: "\n\(sdFooter)", attributes: [ .font : UIFont.systemFont(ofSize: 11, weight: .regular) as Any,.foregroundColor : UIColor.lightDark as Any ]))
                        
            label.attributedText = attributedText
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        footerView.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            footerView.heightAnchor.constraint(equalToConstant: 100),
            footerLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
        ])
        
        if section ==  tableView.numberOfSections - 1 {
            return footerView
        }else{
            return UIView()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func setupPickers(){
       
        view.addSubview(tempTextView)
        view.addSubview(tempTextView2)
        view.addSubview(tempTextView3)
        view.addSubview(tempTextView4)

        tempTextView.inputView = _timerPickerView
        tempTextView.inputAccessoryView = doneToolbar
        
        tempTextView2.inputView = _photosPickerView
        tempTextView2.inputAccessoryView = doneToolbar

        tempTextView3.inputView = _orientationPickerView
        tempTextView3.inputAccessoryView = doneToolbar

        tempTextView4.inputView = _defaultCameraPickerView
        tempTextView4.inputAccessoryView = doneToolbar

        _timerPickerView.dataSource = self
        _photosPickerView.dataSource = self
        _orientationPickerView.dataSource = self
        _defaultCameraPickerView.dataSource = self
        
        _timerPickerView.delegate = self
        _photosPickerView.delegate = self
        _orientationPickerView.delegate = self
        _defaultCameraPickerView.delegate = self
        
        _timerPickerView.tag = 1
        _photosPickerView.tag = 2
        _orientationPickerView.tag = 3
        _defaultCameraPickerView.tag = 4
        
    }

    @objc func didTapOnPortfolio(){
        let portfolio = URL(string: "https://www.lefdilia.com")!
        UIApplication.shared.open(portfolio)
    }
    
    @objc func didTapClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped(){
        tempTextView.resignFirstResponder()
        tempTextView2.resignFirstResponder()
        tempTextView3.resignFirstResponder()
        tempTextView4.resignFirstResponder()
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem){
        
        UserDefaults.standard.setValue(selectedItem, forKey: "Settings")
        
        self.settings = buildData()
        self.tableView.reloadData()
        
        closeButtonTapped()
    }
    
    
    private func buildData() -> [Section]{
        
        let _selectedItem: [String: Any] = UserDefaults.standard.object(forKey: AppConfig.appKeys._SettingsKey) as? [String : Any] ?? AppConfig.appKeys._SettingsDefault
        
        let settings = [
            Section(title: "USER OPTIONS", options: [
                .switchCell(model: SettingsMitSwitch(title: "High Resolution", slogan: "", icon: nil, iconBackgroundColor: .clear, handler: {}, isOn: UserDefaults.standard.bool(forKey: "highResolution") )),
                
                .switchCell(model: SettingsMitSwitch(title: "Auto Save to Photo Library", slogan: "", icon: nil, iconBackgroundColor: .clear,  handler: {}, isOn: UserDefaults.standard.bool(forKey: "autoSaveToPhotos") ))
            ]),
            Section(title: "CAMERA", options: [
                .staticCell(model: Settings(title: "Time",
                                            slogan: "Time to wait before taking a photo",
                                            icon: UIImage(systemName: "bolt.circle"),
                                            iconBackgroundColor: .systemBlue,
                                            _values: "\(_selectedItem["timer"] ?? "--")"){
                    
                    self.tempTextView.becomeFirstResponder()
                    
                    var _index = 3
                    if let _selectedValueindex = AppConfig.appData.timer.firstIndex(of: _selectedItem["timer"] as! Int) {
                        _index = _selectedValueindex
                    }
                    
                    self._timerPickerView.selectRow(_index, inComponent: 0, animated: true)
                
                }),
                .staticCell(model: Settings(title: "Photos",
                                            slogan: "Number of photos to take", icon: nil,
                                            iconBackgroundColor: .clear,
                                            _values: "\(_selectedItem["numberOfPhotos"] ?? "--")" ){
                    
                    self.tempTextView2.becomeFirstResponder()
                    var _index = 4
                    if let _selectedValueindex = AppConfig.appData.photos.firstIndex(of: _selectedItem["numberOfPhotos"] as! Int) {
                        _index = _selectedValueindex
                    }
                    
                    self._photosPickerView.selectRow(_index, inComponent: 0, animated: true)
                    
                }),
                
                .staticCell(model: Settings(title: "Photos Orientation",
                                            slogan: "How Combined Photos must be saved",
                                            icon: nil,
                                            iconBackgroundColor: .clear,
                                            _values: _selectedItem["orientation"] as! String){
                    
                    self.tempTextView3.becomeFirstResponder()
                    
                    var _index = 0
                    if let _selectedValueindex = AppConfig.appData.orientation.firstIndex(of: _selectedItem["orientation"] as! String) {
                        _index = _selectedValueindex
                    }
                    
                    self._orientationPickerView.selectRow(_index, inComponent: 0, animated: true)
                    
                }),
                
                .staticCell(model: Settings(title: "Default Camera",
                                            slogan: "Phone Camera to use",
                                            icon: nil,
                                            iconBackgroundColor: .clear,
                                            _values: _selectedItem["defaultCamera"] as! String){
                    
                    self.tempTextView4.becomeFirstResponder()
                    
                    var _index = 0
                    if let _selectedValueindex = AppConfig.appData.defaultCamera.firstIndex(of: _selectedItem["defaultCamera"] as! String) {
                        _index = _selectedValueindex
                    }
                                            
                    self._defaultCameraPickerView.selectRow(_index, inComponent: 0, animated: true)

                    
                })
            ])
        ]
        
        return settings
    }
    
   
}



