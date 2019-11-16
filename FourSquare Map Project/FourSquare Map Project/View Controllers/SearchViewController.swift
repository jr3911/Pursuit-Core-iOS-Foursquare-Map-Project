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
    //MARK: - UI Objects
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
    
    
    //MARK: - Properties
    private let locationManager = CLLocationManager()
    
    private let searchRadius: Double = 5000
    
    private var venues: [Venue] = [] {
        didSet {
            //create activity indicator
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)

            let annotations = self.mapView.annotations
            self.mapView.removeAnnotations(annotations)
            
            self.venues.forEach { (venue) in
                //search request
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = venue.venue?.name
                let activeSearch = MKLocalSearch(request: searchRequest)
                activeSearch.start { (response, error) in
                    activityIndicator.stopAnimating()
                    
                    if response == nil {
                        print(error.debugDescription)
                    } else {
                        //get data
                        let latitud = response?.boundingRegion.center.latitude
                        let longitud = response?.boundingRegion.center.longitude
                        
                        let newAnnotation = MKPointAnnotation()
                        newAnnotation.title = response?.mapItems.first?.name
                        newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitud!, longitude: longitud!)
                        self.mapView.addAnnotation(newAnnotation)
                    }
                }
            }
        }
    }
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureDelegates()
        addSubviews()
        applyAllConstraints()
        requestLocationAndAuthorizeIfNeeded()
    }
    
    
    //MARK: - Private Functions
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
            mapView.userTrackingMode = .follow
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if let userLocation = locationManager.location?.coordinate {
                centerMapOnLocation(location: userLocation)
            }
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //to zoom in the annotation
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: searchRadius * 2, longitudinalMeters: searchRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

//MARK: - LocationManager Delegate
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


//MARK: - SearchBar Delegate
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let userLocation = locationManager.location {
            centerMapOnLocation(location: userLocation.coordinate)
        }
        
        VenueFetchingService.manager.getVenues(lat: (locationManager.location?.coordinate.latitude)!, long: (locationManager.location?.coordinate.longitude)!, query: searchBar.text!) { (result) in
            switch result {
            case .success(let retrievedVenues):
                self.venues = retrievedVenues
            case .failure(let error):
                print(error)
            }
        }
    }
    
}


//MARK: - MapKit Delegate
extension SearchViewController: MKMapViewDelegate {
}


//MARK: - Constraints
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
