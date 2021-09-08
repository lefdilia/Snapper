//
//  ViewController.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 14/8/2021.
//

import UIKit
import AVFoundation


class MainViewController: UIViewController {
    
    var capturedImages: [UIImage] = []

   lazy var savedSettings: [String: Any] = UserDefaults.standard.object(forKey: AppConfig.appKeys._SettingsKey) as? [String : Any] ?? AppConfig.appKeys._SettingsDefault
    
    //Initialize
    var session = AVCaptureSession()
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    //Settings
    var highResolutionEnabled = UserDefaults.standard.bool(forKey: AppConfig.appKeys._highResolutionKey)
    var flashMode = AVCaptureDevice.FlashMode.off
    lazy var cameraPosition: AVCaptureDevice.Position = savedSettings["defaultCamera"] as! String == "Front" ? .front : .back
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    lazy var timeLeft = savedSettings["timer"] as! Int + 1 // 0 + 1
    lazy var elapsedTimeLeft = savedSettings["timer"] as! Int + 1
    
    lazy var picturesToTake = savedSettings["numberOfPhotos"] as! Int
    lazy var elapsedPicturesToTake = savedSettings["numberOfPhotos"] as! Int

    var _loaderView = LoaderCircleView()
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let path = Bundle.main.path(forResource: "2868", ofType: "wav") else { return }
        try? audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        
        //Update HR
        highResolutionEnabled = UserDefaults.standard.bool(forKey: AppConfig.appKeys._highResolutionKey)
        
        if highResolutionEnabled == true {
            toggleHR.titleLabel?.attributedText  = NSMutableAttributedString(string: "HR", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .heavy),
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.clear
            ])
        }else{
            toggleHR.titleLabel?.attributedText  = NSMutableAttributedString(string: "HR", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .thin),
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.red
            ])
        }
        
        //Must Reset at End
        self.resetAction()
        
        //Update Used Camera
        let _cameraPosition: AVCaptureDevice.Position = savedSettings["defaultCamera"] as! String == "Front" ? .front : .back
        if cameraPosition.rawValue != _cameraPosition.rawValue {
            self.cameraPosition = _cameraPosition // update Value
            self.setupCamera()
        }
        
        //Update Values after next Controller
        self.savedSettings = UserDefaults.standard.object(forKey: AppConfig.appKeys._SettingsKey) as? [String : Any] ?? AppConfig.appKeys._SettingsDefault
    }

    //MARK:- Snapper UI
    
    let cameraButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "cameraButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var capturedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isUserInteractionEnabled = true
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeThumbs(_:)))
        swipeGesture.direction = .left
        imageView.addGestureRecognizer(swipeGesture)
        
        return imageView
    }()
    
    lazy var badgeCounter: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = .red
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    //MARK:- Right Menu View
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .darkGray.withAlphaComponent(0.3)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var toggleHR: UIButton = {
        let button = UIButton()
        button.setTitle("HR", for: .normal)
   
        if highResolutionEnabled == true {
            button.titleLabel?.attributedText  = NSMutableAttributedString(string: "HR", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .heavy),
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.clear
            ])
        }else{
            button.titleLabel?.attributedText  = NSMutableAttributedString(string: "HR", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .thin),
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.red
            ])
        }
    
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapToggleHR), for: .touchUpInside)
        return button
    }()
    
    let toggleCamera: UIButton = {
        let button = UIButton()
        let cameraConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let Umage = UIImage(systemName: "arrow.triangle.2.circlepath.camera", withConfiguration: cameraConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(Umage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapToggleCamera), for: .touchUpInside)
        return button
    }()
    
    let toggleFlash: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "flash-off"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapToggleFlash), for: .touchUpInside)
        return button
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        separator.backgroundColor = .clear
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    let userSettings: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "user-settings"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapuserSettings), for: .touchUpInside)
        return button
    }()
    
    let picturesFolder: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pictures-folder"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapPicturesFolder), for: .touchUpInside)
        return button
    }()
    
    let fixEndSpacing: UIView = {
        let spacing = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        spacing.backgroundColor = .clear
        return spacing
    }()
    
    lazy var menuView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [toggleHR, toggleCamera, toggleFlash, separator, userSettings, picturesFolder, fixEndSpacing])
        stack.axis = .vertical
        
        stack.distribution = .fill
        
        stack.setCustomSpacing(15, after: toggleHR)
        stack.setCustomSpacing(23, after: toggleCamera)
        stack.setCustomSpacing(40, after: toggleFlash)
        stack.setCustomSpacing(15, after: userSettings)
        stack.setCustomSpacing(15, after: picturesFolder)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layer.cornerRadius = 8
        stack.backgroundColor = .darkGray.withAlphaComponent(0.3)
        stack.alpha = 1
        return stack
    }()
    
    let showMenuView: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapMenuView), for: .touchUpInside)
        button.setImage(UIImage(named: "settings"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK:- Functions
    @objc private func didTapToggleHR(){
        highResolutionEnabled = !highResolutionEnabled
        UserDefaults.standard.setValue(highResolutionEnabled, forKey: AppConfig.appKeys._highResolutionKey)
        
        var attributes: NSMutableAttributedString?
        
        if highResolutionEnabled {
            attributes = NSMutableAttributedString(string: "HR", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .heavy),
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.clear
            ])
        }else{
            attributes = NSMutableAttributedString(string: "HR", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .thin),
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: UIColor.red
            ])
        }
        
        toggleHR.titleLabel?.attributedText = attributes
        showMessage(text: "High resolution: \(highResolutionEnabled ? "Enabled" : "Disabled")")
    }
    
    
    @objc private func didTapToggleCamera(){
        if cameraPosition == .back {
            cameraPosition = .front
            showMessage(text: "You are using Front Camera")
        }else{
            cameraPosition = .back
            showMessage(text: "You are using Back Camera")
        }
        setupCamera()
    }
    
    @objc private func didTapToggleFlash(){
        
        switch self.flashMode {
        case .off:
            self.flashMode = .on
            showMessage(text: "Flash mode is Activated")
            toggleFlash.setImage(UIImage(named: "flash-on"), for: .normal)
            break
        case .on:
            self.flashMode = .auto
            showMessage(text: "Flash mode is set to Automatic")
            toggleFlash.setImage(UIImage(named: "flash-auto"), for: .normal)
            break
        case .auto:
            self.flashMode = .off
            showMessage(text: "Flash mode is Disabled")
            toggleFlash.setImage(UIImage(named: "flash-off"), for: .normal)
            break
        default:
            break
        }
    }
    
    @objc private func didTapuserSettings(){
        
        let userSettings = UserSettingsController()
        let settingsNavigationController = UINavigationController(rootViewController: userSettings)
        
        settingsNavigationController.navigationBar.prefersLargeTitles = true
        settingsNavigationController.modalPresentationStyle = .fullScreen
        settingsNavigationController.modalTransitionStyle = .crossDissolve
        
        self.present(settingsNavigationController, animated: true) {
            self.resetAction()
        }
    }
    
    @objc private func didTapPicturesFolder(){
        
        let PicturesList = PicturesListController()
        let PicturesNavigationController = UINavigationController(rootViewController: PicturesList)
        
        PicturesNavigationController.navigationBar.prefersLargeTitles = true
        PicturesNavigationController.modalPresentationStyle = .fullScreen
        PicturesNavigationController.modalTransitionStyle = .crossDissolve
        
        present(PicturesNavigationController, animated: true) {
            self.resetAction()
        }
    }
    
   private func resetAction(){
        
        self.savedSettings = UserDefaults.standard.object(forKey: AppConfig.appKeys._SettingsKey) as? [String : Any] ?? AppConfig.appKeys._SettingsDefault
        
        self.timeLeft = self.savedSettings["timer"] as! Int
        self.elapsedTimeLeft = self.savedSettings["timer"] as! Int
        self.picturesToTake = savedSettings["numberOfPhotos"] as! Int
        self.elapsedPicturesToTake = savedSettings["numberOfPhotos"] as! Int
        
        self.hideThumbnail()
        self.timer?.invalidate()
        self.cameraButton.isEnabled = true
    }
    
    
    @objc private func didTapMenuView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.menuView.alpha = 1.0 - self.menuView.alpha
        })
    }
    
    @objc private func didSwipeThumbs(_ gesture: UISwipeGestureRecognizer){
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.hideThumbnail()
        })
    }
    
    private func hideThumbnail(){
        self.capturedImageView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
        self.badgeCounter.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
    }
    
    private func showThumbnail(){
        self.capturedImageView.transform = .identity
        self.badgeCounter.transform = .identity
    }
    
    private func showMessage(text: String) {
        messageLabel.text = " \(text)  "
        
        UIView.animate(withDuration: 2.0, animations: {
            self.messageLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveLinear, animations: { [weak self] in
            self?.messageLabel.alpha = 0.0
        }, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //test
    let timerView: UILabel = {
        let timerView = UILabel()
        timerView.textColor = .white
        timerView.font = UIFont.systemFont(ofSize: 100, weight: .semibold)
        timerView.textAlignment = .center
        timerView.translatesAutoresizingMaskIntoConstraints = false
        return timerView
    }()
    
    private func startTimer() -> Timer? {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        return timer
    }
    
    @objc func onTimerFires() {
        
        elapsedTimeLeft -= 1
                
        self.timerView.transform = .identity
        self.timerView.layer.opacity = 1
        
        if elapsedTimeLeft < 1 {
            self.timerView.text = ""
        }else{
            self.timerView.text = "\(elapsedTimeLeft)"
        }
        
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut, animations: {
            self.timerView.transform =  self.timerView.transform.scaledBy(x: 3, y: 3)
            self.timerView.layer.opacity = 0
        })
        
        if elapsedTimeLeft <= 0 {
            self.timer?.invalidate()
            self.elapsedPicturesToTake -= 1
            
            self.timerView.alpha = 0
            
            if self.elapsedPicturesToTake <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                
                self.takePhoto() // take last image
                
                self.elapsedTimeLeft = self.timeLeft
                self.elapsedPicturesToTake = self.picturesToTake
                
                if self.capturedImages.count == 0 {
                    self._loaderView.removeFromSuperview()
                    self.cameraButton.isEnabled = true
                }

            }else{
                self.takePhoto()
                                
                self.elapsedTimeLeft = self.timeLeft
                self.timer = self.startTimer()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.layer.addSublayer(previewLayer)
        view.addSubview(cameraButton)
        
        view.addSubview(capturedImageView)
        NSLayoutConstraint.activate([
            capturedImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 13),
            capturedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            capturedImageView.widthAnchor.constraint(equalToConstant: 80),
            capturedImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        view.addSubview(badgeCounter)
        NSLayoutConstraint.activate([
            badgeCounter.topAnchor.constraint(equalTo: capturedImageView.topAnchor, constant: -12),
            badgeCounter.trailingAnchor.constraint(equalTo: capturedImageView.trailingAnchor, constant: 12),
            badgeCounter.widthAnchor.constraint(equalToConstant: 24),
            badgeCounter.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        view.addSubview(showMenuView)
        NSLayoutConstraint.activate([
            showMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            showMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  -100),
            showMenuView.heightAnchor.constraint(equalToConstant: 30),
            showMenuView.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        view.addSubview(menuView)
        NSLayoutConstraint.activate([
            menuView.bottomAnchor.constraint(equalTo: showMenuView.topAnchor, constant: -20),
            menuView.centerXAnchor.constraint(equalTo: showMenuView.centerXAnchor),
            menuView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        checkCameraPermission()
        
        view.addSubview(timerView)
        NSLayoutConstraint.activate([
            timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = view.bounds
        cameraButton.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)

    }
    

    func setupSpinningCircleView(){

        _loaderView = LoaderCircleView()
        _loaderView.frame = CGRect(x: view.center.x - 30, y: 30, width: 60, height: 60)
        
        cameraButton.addSubview(_loaderView)
        _loaderView.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor).isActive = true
        _loaderView.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        
        _loaderView.animate()
    }
    
    
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] access in
                guard access else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }
    
    private func setupCamera(){
        
        if session.isRunning {
            session.stopRunning()
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) {

            if !session.inputs.isEmpty {
                session.removeInput(session.inputs.first!)
            }

            let preset: AVCaptureSession.Preset = .high
            
            if session.canSetSessionPreset(preset){
                session.sessionPreset = preset
            }

            do {
                let input = try AVCaptureDeviceInput(device: device) // the device we found
                
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                
            }catch {}
            
        }
    }

    
    private func processImages(){
        
        let _isVertical = self.savedSettings["orientation"] as! String == "Vertical" ? true : false
        
        MergeImages(images: self.capturedImages, isVertical: _isVertical) { image, globalName, path in
            
            guard let path = path else {
                return self._loaderView.removeFromSuperview()
            }
            
            let _size = path.fileSizeString
            let _creationDate = path.creationDate ?? Date()
            
            let processedData = ("\(globalName).png", image, path, _size, _creationDate)
            self.popMergedResult(processedData: processedData)
 
        }
    }

    private func popMergedResult (processedData: (name: String, image: UIImage, path: URL?, size: String?, creationDate: Date)){
        
        var _extedMessage = ""
        if let _size = processedData.size {
            _extedMessage = "PNG Image - \(_size)"
        }
        
        let alertController = UIAlertController(title: AppConfig.initial._sharedMsgTitle, message: "\(_extedMessage)", preferredStyle: .alert)
        
        alertController.addImage(image: processedData.image)
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            guard let path = processedData.path else { return }
            let stichedImage = path.relativePath
            
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy HH:mm:ss"
            
            let _creationDate = df.string(from: processedData.creationDate)
            
            let sharedMessage = "\(AppConfig.initial._sharedMsgTitle) \(_creationDate).png"

            if FileManager.default.fileExists(atPath: stichedImage) {
                
                let _stiched = self.createLinkToFile(atURL: URL(fileURLWithPath: stichedImage), withName: sharedMessage)
                
                guard let _stiched = _stiched else { return }
                
                let activityViewController = UIActivityViewController(activityItems: [_stiched], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [.airDrop]
                
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                
                DispatchQueue.main.async {
                    activityViewController.completionWithItemsHandler = { activity, success, items, error in
                        UINavigationBar.appearance().tintColor = .white
                        activityViewController.dismiss(animated: true)
                    }
                    
                    self.present(activityViewController, animated: true) {() -> Void in
                        UINavigationBar.appearance().tintColor = .darkGray
                    }
                }
            }
        }
        shareAction.setValue(UIImage(systemName: "square.and.arrow.up.on.square"), forKey: "image")
        alertController.addAction(shareAction)
        

        let saveAction = UIAlertAction(title: "Save to Photos", style: .default) { _ in
            let _image = processedData.image
            UIImageWriteToSavedPhotosAlbum(_image, self, nil, nil)
        }

        saveAction.setValue(UIImage(systemName: "doc.badge.plus")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), forKey: "image")
        saveAction.setValue(UIColor.darkGray, forKey: "titleTextColor")
        alertController.addAction(saveAction)

        
        let cancelMe = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        cancelMe.setValue(UIImage(systemName: "xmark")?.withTintColor(.red, renderingMode: .alwaysOriginal), forKey: "image")
        alertController.addAction(cancelMe)
        
        present(alertController, animated: true) {

            self._loaderView.removeFromSuperview()
            self.cameraButton.isEnabled = true
            
        }
    }
    
    private func createLinkToFile(atURL fileURL: URL, withName fileName: String) -> URL? {
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory
        let linkURL = tempDirectoryURL.appendingPathComponent(fileName)
        do {
            if fileManager.fileExists(atPath: linkURL.path) {
                try fileManager.removeItem(at: linkURL)
            }
            try fileManager.linkItem(at: fileURL, to: linkURL)
            return linkURL
        } catch {
            return nil
        }
    }
    
    private func MergeImages(images: [UIImage], isVertical: Bool, completion: @escaping (UIImage, String, URL?)->()) {
        
        DispatchQueue.global(qos: .utility).async {
            
            let manager = FileManager.default
            
            let _NSUUID = NSUUID().uuidString.split(separator: "-")
            let globalName = "\(_NSUUID.first!)-\(_NSUUID.last!)"
            
            let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let savingFolder = documentsDirectory.appendingPathComponent(globalName)
            
            try? manager.createDirectory(at: savingFolder, withIntermediateDirectories: true, attributes: [:])
            
            var stitchedImages: UIImage!
            var msPath: URL?
            
            if images.count > 0 {
                var maxWidth = CGFloat(0), maxHeight = CGFloat(0)
                for image in images {
                    if image.size.width > maxWidth {
                        maxWidth = image.size.width
                    }
                    if image.size.height > maxHeight {
                        maxHeight = image.size.height
                    }
                }
                var totalSize : CGSize
                let maxSize = CGSize(width: maxWidth, height: maxHeight)
                if isVertical {
                    totalSize = CGSize(width: maxSize.width, height: maxSize.height * (CGFloat)(images.count))
                } else {
                    totalSize = CGSize(width: maxSize.width  * (CGFloat)(images.count), height:  maxSize.height)
                }
                UIGraphicsBeginImageContext(totalSize)
                
                for (index, image) in images.enumerated() {
                    
                    let offset = (CGFloat)(images.firstIndex(of: image)!)
                    let rect =  AVMakeRect(aspectRatio: image.size, insideRect: isVertical ?
                                            CGRect(x: 0, y: maxSize.height * offset, width: maxSize.width, height: maxSize.height) :
                                            CGRect(x: maxSize.width * offset, y: 0, width: maxSize.width, height: maxSize.height))
                    image.draw(in: rect)
                    
                    //Save to Disk
                    let fileURL = savingFolder.appendingPathComponent("Image_\(index+1).png")
                    
                    if let data = image.jpegData(compressionQuality: 1.0) {
                            try? data.write(to: fileURL, options: .atomicWrite)
                    }
                }
                stitchedImages = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                msPath = stitchedImages.saveToDocuments(savingFolder: savingFolder, globalName: globalName)
                
                //Save to Photos
                if UserDefaults.standard.bool(forKey: AppConfig.appKeys._autoSaveToPhotosKey) == true {
                    UIImageWriteToSavedPhotosAlbum(stitchedImages, self, nil, nil)
                }
                
                //Thumbnail : Create & save
                let _maxSize = CGSize(width: 245, height: 300)
                let imgSize = stitchedImages.size
                
                var ratio: CGFloat!
                if (imgSize.width > imgSize.height) {
                    ratio = _maxSize.width / imgSize.width
                }else {
                    ratio = _maxSize.height / imgSize.height
                }
                
                let scaledSize = CGSize(width: imgSize.width*ratio, height: imgSize.height*ratio)
                var resizedImage = stitchedImages.imageWithSize(scaledSize)
                
                if (imgSize.height > imgSize.width) {
                    let left = (_maxSize.width - resizedImage.size.width) / 2
                    resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
                }
                
                let _ = resizedImage.saveToDocuments(savingFolder: savingFolder, globalName: "\(globalName)_thumbnail")
                
            }
            DispatchQueue.main.async { () -> Void in
                return completion(stitchedImages, globalName, msPath)
            }
        }
    }
    
    private func takePhoto(){

        let AVSettings = AVCapturePhotoSettings()
        
        let HighResolution = self.highResolutionEnabled
        
        output.isHighResolutionCaptureEnabled = HighResolution
        AVSettings.isHighResolutionPhotoEnabled = HighResolution
        
        if output.supportedFlashModes.contains(self.flashMode) {
            AVSettings.flashMode = self.flashMode
        }
        
        if AVSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
            AVSettings.previewPhotoFormat = [
                kCVPixelBufferPixelFormatTypeKey : AVSettings.availablePreviewPhotoPixelFormatTypes.first!,
                kCVPixelBufferWidthKey : 512,
                kCVPixelBufferHeightKey : 512
            ] as [String: Any]
        }
        
        AVSettings.embeddedThumbnailPhotoFormat = [
            AVVideoCodecKey: AVVideoCodecType.jpeg,
            AVVideoWidthKey: 512,
            AVVideoHeightKey: 512
        ]

        AVSettings.isDepthDataDeliveryEnabled = output.isDepthDataDeliverySupported
        
        output.connections.first?.videoOrientation = .portrait
        
        if output.availablePhotoFileTypes.count == 0 || output.connections.count == 0 {
            return
        }else{
            output.capturePhoto(with: AVSettings, delegate: self)
        }
    }
    
    @objc private func didTapCamera(sender: UIButton){
    
        sender.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                        
            sender.isEnabled = false
            sender.transform = CGAffineTransform.identity
            
        }, completion: { _ in
            self.audioPlayer?.play()
        })
        
        self.capturedImages.removeAll()
        self.badgeCounter.text = "\(self.capturedImages.count)"
        self.badgeCounter.isHidden = true
        self.capturedImageView.isHidden = true

        self.capturedImageView.transform = .identity
        self.badgeCounter.transform = .identity
        
        let _ = self.startTimer()
        
    }
}


extension MainViewController: AVCapturePhotoCaptureDelegate {
    
    func showPreview(for photo: AVCapturePhoto) {
        guard let previewPixelBuffer = photo.previewPixelBuffer else { return }
        
        let ciImage = CIImage(cvPixelBuffer: previewPixelBuffer).oriented(.right)
        let uiImage = UIImage(ciImage: ciImage)
                
        UIView.transition(with: capturedImageView,
                          duration: 0.6,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.capturedImageView.isHidden = false
                            self.capturedImageView.image = uiImage
                          })
    }
    

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else { return }
 
        capturedImages.append(image)
        
        self.showThumbnail()
        self.badgeCounter.isHidden = false
        self.badgeCounter.text = String(self.capturedImages.count)
                
        showPreview(for: photo)
            
        if !self.capturedImages.isEmpty {
            if self.capturedImages.count == self.picturesToTake {
                
                self.setupSpinningCircleView()
                self.processImages()
                
            }
        }else{
            self._loaderView.removeFromSuperview()
            self.cameraButton.isEnabled = true
        }
    }

    
}

