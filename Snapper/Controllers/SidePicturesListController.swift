//
//  SidePicturesListController.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 20/8/2021.
//

import UIKit

class SidePicturesListController: UIViewController {
    
    var _images: [Images] = []
    
    let cellId = "sideImagesCell"
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        _images = _images.filter({ _Image in
            if let _imagePath = _Image.path {
                return !_imagePath.absoluteString.contains("_thumbnail.png")
            }else{
                return true
            }
        }).sorted(by: { _image1, _image2 in
            _image1.name < _image2.name
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pictures"
        view.backgroundColor = .white
        
        let closeConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: closeConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(didTapClose))
        ]
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(SidePicturesListCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorInset = .init(top: 0, left: 31, bottom: 0, right: 31)
        tableView.separatorColor = UIColor.separator
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @objc func didTapClose(){
        self.dismiss(animated: true, completion: nil)
    }

}


extension SidePicturesListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._images.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return  UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SidePicturesListCell
        cell._imageFile = _images[indexPath.row]
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let inRowImage =  self._images[indexPath.row]
        
        var _extedMessage = ""
        if let _size = inRowImage.size {
            _extedMessage = "PNG Image - \(_size)"
        }
        
        let alertController = UIAlertController(title: "Share \(inRowImage.name)", message: "\(_extedMessage)", preferredStyle: .actionSheet)
        
        let viewAction = UIAlertAction(title: "View", style: .default) { _ in
            
            guard let path = inRowImage.path else { return }

            if FileManager.default.fileExists(atPath: path.relativePath) {
                
                let imageViewerController = ImageViewerController()
                imageViewerController._inRowImage = inRowImage
                imageViewerController._images = self._images
                
                let imageViewerNavigationController = UINavigationController(rootViewController: imageViewerController)
                
                imageViewerNavigationController.navigationBar.prefersLargeTitles = false
                imageViewerNavigationController.modalPresentationStyle = .overFullScreen
                imageViewerNavigationController.modalTransitionStyle = .coverVertical
                
                imageViewerNavigationController.navigationBar.barStyle = .black
                imageViewerNavigationController.navigationBar.barTintColor = .white
                
                self.present(imageViewerNavigationController, animated: true, completion: nil)
                
            }
        }
        
        viewAction.setValue(UIImage(systemName: "viewfinder")?.withTintColor(UIColor.MRed!, renderingMode: .alwaysOriginal), forKey: "image")
        viewAction.setValue(UIColor.MRed!, forKey: "titleTextColor")
        alertController.addAction(viewAction)
        
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            
            guard let path = inRowImage.path else { return }
            let stichedImage = path.relativePath
            
            let sharedMessage = "\(AppConfig.initial._sharedMsgTitle) \(inRowImage.creationDate).png"

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
        
        shareAction.setValue(UIImage(systemName: "square.and.arrow.up.on.square"), forKey: "image")
        alertController.addAction(shareAction)

        let saveAction = UIAlertAction(title: "Save to Photos", style: .default) { _ in
            
            guard let path = inRowImage.path else { return }
            guard let data = NSData(contentsOf: path) else { return }
            guard let _image = UIImage(data: data as Data) else { return }

            UIImageWriteToSavedPhotosAlbum(_image, self, nil, nil)
        }

        saveAction.setValue(UIImage(systemName: "doc.badge.plus")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), forKey: "image")
        saveAction.setValue(UIColor.darkGray, forKey: "titleTextColor")
        alertController.addAction(saveAction)
        
        let cancelMe = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelMe.setValue(UIImage(systemName: "xmark")?.withTintColor(.red, renderingMode: .alwaysOriginal), forKey: "image")
        cancelMe.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertController.addAction(cancelMe)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let inRowImage =  self._images[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (_, _, completion) in
            
            guard let _file = inRowImage.path else { return }
            
            if FileManager.default.fileExists(atPath: _file.relativePath) {
                
                try? FileManager.default.removeItem(atPath: _file.relativePath)
                self._images.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                
            }
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")

        let swipes = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipes
        
    }
    
}
