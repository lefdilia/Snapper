//
//  ImageViewerController.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 30/8/2021.
//

import UIKit

class ImageViewerController: UIViewController, UIScrollViewDelegate {
    
    var _images = [Images]()

    var _inRowImage: Images? {
        didSet{
            guard let _inRowImage = _inRowImage else { return }
            guard let path = _inRowImage.path else { return }
            guard let data = NSData(contentsOf: path) else { return }
            
            guard let _image = UIImage(data: data as Data) else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = _image
            }
        }
    }

    
    lazy var imageView: UIImageView = {
        let _viewer = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        _viewer.center = view.center
        _viewer.contentMode = .scaleAspectFit
        _viewer.isUserInteractionEnabled = true
        
        let _leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        _leftSwipe.direction = .left
        
        let _rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        _rightSwipe.direction = .right
        
        let _downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        _downSwipe.direction = .down

        _viewer.addGestureRecognizer(_leftSwipe)
        _viewer.addGestureRecognizer(_rightSwipe)
        _viewer.addGestureRecognizer(_downSwipe)

        return _viewer
    }()
    
    lazy var scrollImg: UIScrollView = {
        let _sctroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        _sctroll.contentSize = .zero
        _sctroll.alwaysBounceVertical = false
        _sctroll.alwaysBounceHorizontal = false
        _sctroll.showsVerticalScrollIndicator = true
        _sctroll.flashScrollIndicators()
        return _sctroll
    }()

    
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer){
        
        if sender.direction == .down {
            self.dismiss(animated: true, completion: nil)
        } else  if sender.direction == .left {
            handlePreviousImage()
        } else  if sender.direction == .right {
            handleNextImage()
        }
        
    }
    
    func handlePreviousImage(){
        if self._images.count == 0 { return }
        
        let index = self._images.firstIndex(where: { _Image in
            return _Image.name == self._inRowImage?.name && _Image.path == self._inRowImage?.path
        })
        
        
        guard let currentIndex = index else { return }
        
        var previousImage: Images?
        
        if currentIndex == 0 {
            let nextIndex = self._images.count - 1
            previousImage = self._images[nextIndex]
        }else{
            previousImage = self._images[currentIndex - 1]
        }

        self._inRowImage = previousImage
        
    }
    
    func handleNextImage(){
                
        if self._images.count == 0 { return }
        
        let currentIndex = self._images.firstIndex(where: { _Image in
            return _Image.name == self._inRowImage?.name && _Image.path == self._inRowImage?.path
        })
        
        guard let index = currentIndex else { return }
        
        var nextImage: Images?
        if index == self._images.count - 1 {
            nextImage = self._images[0]
        }else{
            nextImage = self._images[index+1]
        }
        
        self._inRowImage = nextImage
        
    }

    @objc func didSwipeDown(_ sender: UISwipeGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        view.backgroundColor = .white
        navigationItem.backButtonTitle = ""
        
        let closeConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up.on.square", withConfiguration: closeConfiguration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(didTapShare)),
            
            UIBarButtonItem(image: UIImage(systemName: "doc.badge.plus", withConfiguration: closeConfiguration)?.withTintColor(UIColor.MRed!, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(didTapSaveToPhotos)),
        ]
        
        navigationItem.rightBarButtonItems = [
                        UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: closeConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(didTapClose))
        ]

        scrollImg.delegate = self
        scrollImg.minimumZoomScale = 1
        scrollImg.maximumZoomScale = 4.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        view.addSubview(scrollImg)
        scrollImg.addSubview(imageView)
        
        if #available(iOS 11.0, *) {
            scrollImg.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

    }
    
    
    @objc func didTapShare(){

        guard let _inRowImage = self._inRowImage else { return }
        
        guard let path = _inRowImage.path else { return }
        let stichedImage = path.relativePath
        
        let sharedMessage = "\(AppConfig.initial._sharedMsgTitle) \(_inRowImage.creationDate).png"

        if FileManager.default.fileExists(atPath: stichedImage) {
            
            let _stiched = URL(fileURLWithPath: stichedImage).createLinkToFile(withName: sharedMessage)
            
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
    
    @objc func didTapSaveToPhotos(){

        guard let path = self._inRowImage?.path else { return }
        guard let data = NSData(contentsOf: path) else { return }
        guard let _image = UIImage(data: data as Data) else { return }
        
        UIImageWriteToSavedPhotosAlbum(_image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil{
            let alert = UIAlertController(title: "Snapper", message: "Your image could not be saved to Photos.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
           let alert = UIAlertController(title: "Snapper", message: "Your image was successfully saved to Photos.", preferredStyle: UIAlertController.Style.alert)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
           self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func didTapClose(){
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
