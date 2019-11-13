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
        return searchbar
    }()
    
    lazy var geoLocationSearchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Enter a location"
        return searchbar
    }()
    
    lazy var mapView: MKMapView = {
        let mv = MKMapView()
        return mv
    }()
   
    lazy var listViewButton: UIButton = {
        let button = UIButton()
        
        //adjusts image of button
        let buttonImageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: UIImage.SymbolWeight.semibold)
        button.setImage(UIImage(systemName: "line.horizontal.3", withConfiguration: buttonImageConfiguration), for: .normal)
        
        return button
    }()
    
    //MARK: Properties
    private let locationManager = CLLocationManager()
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureDelegates()
        addSubviews()
        applyAllConstraints()
        requestLocationAndAuthorizeIfNeeded()
    }
    
    
    //MARK: Private Functions
    private func configureDelegates() {
        locationManager.delegate = self
        mapView.delegate = self
        venueSearchBar.delegate = self
        geoLocationSearchBar.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(venueSearchBar)
        view.addSubview(geoLocationSearchBar)
        view.addSubview(mapView)
        view.addSubview(listViewButton)
    }
    
    private func applyAllConstraints() {
        constrainGeoLocationSearchBar()
        constrainVenueSearchBar()
        constrainMapView()
        constrainListViewButton()
    }
    
    private func requestLocationAndAuthorizeIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
   
    
}

//MARK: LocationManager Delegate
extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("New locations: \(locations)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("An error occured when trying to retrieve locations: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
}


//MARK: SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}


//MARK: MapKit Delegate
extension SearchViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        mapView.userTrackingMode = .followWithHeading
    }
}


//MARK: Constraints
extension SearchViewController {
    private func constrainVenueSearchBar() {
        venueSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            venueSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            venueSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            venueSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            venueSearchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func constrainGeoLocationSearchBar() {
        geoLocationSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            geoLocationSearchBar.topAnchor.constraint(equalTo: venueSearchBar.bottomAnchor, constant: 10),
            geoLocationSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            geoLocationSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            geoLocationSearchBar.heightAnchor.constraint(equalToConstant: 40)
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
    
    private func constrainListViewButton() {
        listViewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listViewButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listViewButton.leadingAnchor.constraint(equalTo: venueSearchBar.trailingAnchor),
            listViewButton.heightAnchor.constraint(equalToConstant: 50),
            listViewButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
