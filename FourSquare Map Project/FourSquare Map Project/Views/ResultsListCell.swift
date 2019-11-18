//
//  ResultsListCell.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/17/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import UIKit

class ResultsListCell: UITableViewCell {
    //MARK: UI Objects
     lazy var venueImageView: UIImageView = {
       let iv = UIImageView()
        iv.layer.cornerRadius = iv.frame.height / 3
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
       let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(venueImageView)
        addSubview(nameLabel)
        
        constrainImageView()
        constrainLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func constrainImageView() {
        venueImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            venueImageView.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor),
            venueImageView.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            venueImageView.bottomAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor),
            venueImageView.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    private func constrainLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: venueImageView.trailingAnchor, constant: 20),
            nameLabel.heightAnchor.constraint(equalToConstant: 30),
            nameLabel.widthAnchor.constraint(equalToConstant: self.contentView.frame.width - venueImageView.frame.width),
        ])
    }
    
}
