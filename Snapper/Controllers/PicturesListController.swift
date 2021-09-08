//
//  PicturesListController.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 18/8/2021.
//

import UIKit
import SDWebImage

class PicturesListController: UIViewController {
    
    var _images = [Images]()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let cellId = "savedPicturesCell"
    
    @objc func didTapClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        listImages { _images, _error in
            self._images = _images
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Pictures"
        view.backgroundColor = .white
        
        navigationItem.backButtonTitle = ""
        
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
        
        tableView.register(PicturesListCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorInset = .init(top: 0, left: 31, bottom: 0, right: 31)
        tableView.separatorColor = UIColor.separator
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
}


extension PicturesListController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return  UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _images.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return _images.count == 0 ? 150 : 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Image List is Empty."
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let _imageFile = _images[indexPath.row]
        
        guard let folderName = _imageFile.originalName else { return }
        
        listImages(folderName: folderName) { _images, _error in
            let sidePicturesList = SidePicturesListController()
            sidePicturesList._images = _images
            self.navigationController?.pushViewController(sidePicturesList, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PicturesListCell
        cell._imageFile = _images[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let fileManager = FileManager.default
        
        let inRowImage =  self._images[indexPath.row]
        
        let shareAction = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            
            guard let path = inRowImage.path else { return }
            let stichedImage = path.relativePath
            
            let sharedMessage = "Snapper Image \(inRowImage.creationDate).png"
            
            if fileManager.fileExists(atPath: stichedImage) {
                
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
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (_, _, completion) in
            
            guard let _file = inRowImage.path else { return }
            
            if fileManager.fileExists(atPath: _file.relativePath) {
                
                try? fileManager.removeItem(atPath: _file.relativePath)
                self._images.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                
            }
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = .darkGray
        
        let swipes = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return swipes
        
    }
}


extension PicturesListController {
    
    func listImages(folderName: String = "", completion: @escaping([Images], Error?)->()) {
        
        var _list = [Images]()
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return completion(_list, "Can't access Documents directory" as? Error)
        }
        
        var imagefolder: URL = documentsDirectory
        
        if !folderName.isEmpty {
            imagefolder = documentsDirectory.appendingPathComponent(folderName)
        }
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: imagefolder, includingPropertiesForKeys: [
                .isDirectoryKey, .nameKey, .fileSizeKey, .creationDateKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey
            ], options: [])
            
            for fileURL in directoryContents {
                
                var _thumbnail: URL?
                var _path: URL?
                var _originalName: String?
                var _name: String?
                var _size: String?
                var _creationDate: String?
                
                do {
                    
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isDirectoryKey, .nameKey, .fileSizeKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .creationDateKey])
                    
                    _originalName = fileAttributes.name
                    
                    if let fName = fileAttributes.name {
                        
                        if fileAttributes.isDirectory == true {
                            _path = fileURL.appendingPathComponent("\(fName).png")
                            _thumbnail = fileURL.appendingPathComponent("\(fName)_thumbnail.png")

                            if let path = _path {
                                if path.fileSize == 0 {
                                    continue
                                }
                            }
                            
                            _name = fileAttributes.name
                            
                        }else{
                            _path = fileURL
                            _name = fileAttributes.name?
                                .replacingOccurrences(of: ".png", with: "")
                                .replacingOccurrences(of: "_", with: " ")
                            
                            if !folderName.isEmpty {
                                _name = _name?.replacingOccurrences(of: folderName, with: "Snapped-Image")
                            }
                        }
                        
                        _size = _path?.fileSizeString
                    }
                    
                    let df = DateFormatter()
                    df.dateFormat = "MM-dd-yyyy HH.mm.ss"
                    _creationDate = df.string(from: fileAttributes.creationDate ?? Date())
                    
                    let _Images = Images(thumbnail: _thumbnail, path: _path, originalName: _originalName, name: _name ?? "--", size: _size ?? "0 KB", creationDate: _creationDate ?? "--")
                    _list.append(_Images)
                    
                } catch {
                    return completion(_list, error.localizedDescription as? Error) }
            }
            _list = _list.sorted(by: { $0.creationDate > $1.creationDate})
            
            return completion(_list, nil)
            
        } catch {
            return completion(_list, "Could not search for urls of files in documents directory: \(error.localizedDescription)" as? Error)
        }
    }
    
    
}
