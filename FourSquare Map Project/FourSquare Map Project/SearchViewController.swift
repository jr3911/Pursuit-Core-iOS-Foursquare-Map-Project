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
        locationManager.delegate = self
        addSubviews()
        applyAllConstraints()
        requestLocationAndAuthorizeIfNeeded()
    }
    
    
    //MARK: Private Functions
    private func addSubviews() {
        view.addSubview(venueSearchBar)
        view.addSubview(geoLocationSearchBar)
        view.addSubview(mapView)
    }
    
    private func applyAllConstraints() {
        constrainGeoLocationSearchBar()
        constrainVenueSearchBar()
        constrainMapView()
    }
    
    private func requestLocationAndAuthorizeIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
}

//MARK: CLLocationManagerDelegate Extension
extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("New locations: \(locations)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("An error occured when trying to retrieve locations: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
}


//MARK: Constraints
extension SearchViewController {
    private func constrainVenueSearchBar() {
        venueSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            venueSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            venueSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            venueSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            venueSearchBar.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func constrainGeoLocationSearchBar() {
        geoLocationSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            geoLocationSearchBar.topAnchor.constraint(equalTo: venueSearchBar.bottomAnchor, constant: 10),
            geoLocationSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            geoLocationSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            geoLocationSearchBar.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func constrainMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: geoLocationSearchBar.bottomAnchor, constant: 10),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
