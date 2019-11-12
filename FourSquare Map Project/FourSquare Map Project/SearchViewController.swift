//
//  ViewController.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/6/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController {
    //MARK: UI Objects
    lazy var venueSearchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search for a venue"
        searchbar.showsCancelButton = true
        return searchbar
    }()
    
    lazy var geoLocationSearchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Enter a location"
//        searchbar.showsCancelButton = true
        return searchbar
    }()
    
    lazy var mapView: MKMapView = {
        let mv = MKMapView()
        return mv
    }()
   
    
    //MARK: Properties
    private let locationManager = CLLocationManager()
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }


}

