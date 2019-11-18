//
//  ResultsListVC.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/17/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import UIKit

class ResultsListVC: UITableViewController {
    var venues: [Venue]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ResultsListCell.self, forCellReuseIdentifier: "resultCell")
        self.title = "Results List"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultsListCell
        
        guard let venues = venues else { return cell }
        
        if let venuePhoto = venues[indexPath.row].venue?.photoData,
            let venueName = venues[indexPath.row].venue?.name {
            cell.venueImageView.image = UIImage(data: venuePhoto)
            cell.nameLabel.text = venueName
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
