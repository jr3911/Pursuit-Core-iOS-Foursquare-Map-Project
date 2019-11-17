//
//  VenueCVCell.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/17/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import UIKit

class VenueCVCell: UICollectionViewCell {
    //MARK: - UI Objects
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constrainImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Constraints
    private func constrainImageView() {
        self.contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
}
