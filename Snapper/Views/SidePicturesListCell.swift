//
//  SidePicturesListCell.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 24/8/2021.
//

import UIKit
import SDWebImage

class SidePicturesListCell: UITableViewCell {
    
    var _imageFile: Images? {
        didSet{
            guard let imageFile = _imageFile else { return }

            let transformer = SDImageResizingTransformer(size: CGSize(width: 150, height: 150), scaleMode: .aspectFit)
            
            snapperImageView.sd_setImage(with: imageFile.path,
                                         placeholderImage: UIImage(named: "placeholder"),
                                         options: .scaleDownLargeImages,
                                         context: [.imageTransformer: transformer])

            

            _fileTitle.text = imageFile.name
            _creationDateLabel.text = imageFile.creationDate
            _sizeLabel.text = imageFile.size

        }
    }
    
     let snapperImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    
    var _creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let _fileTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let _sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        return label
    }()
    
    lazy var vStackView: UIStackView = {
        let stack =  UIStackView(arrangedSubviews: [_fileTitle, _creationDateLabel, _sizeLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        stack.setCustomSpacing(15, after: _fileTitle)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let _accessView: UIButton = {
        let _view = UIButton()
        _view.setImage(UIImage(systemName: "square.and.arrow.up")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), for: .normal)
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        selectionStyle = .none
                
        contentView.addSubview(snapperImageView)
        NSLayoutConstraint.activate([
            snapperImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            snapperImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            snapperImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 105),
            snapperImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 110),

        ])
        
        addSubview(vStackView)
        NSLayoutConstraint.activate([
            vStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            vStackView.leadingAnchor.constraint(equalTo: snapperImageView.trailingAnchor, constant: 10)
        ])
    
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
