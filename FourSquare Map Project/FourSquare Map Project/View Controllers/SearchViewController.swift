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
        searchbar.placeholder = "New York, NY"
        return searchbar
    }()
    
    lazy var mapView: MKMapView = {
        let mv = MKMapView()
        mv.isRotateEnabled = false
        return mv
    }()
    
    lazy var listViewButton: UIButton = {
        let button = UIButton()
        
        //adjusts image of button
        let buttonImageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: UIImage.SymbolWeight.semibold)
        button.setImage(UIImage(systemName: "line.horizontal.3", withConfiguration: buttonImageConfiguration), for: .normal)
        
        return button
    }()
    
    lazy var resultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        layout.minimumLineSpacing = 20
        
        let cv = UICollectionView(frame: CGRect(x: 100, y: 100, width: 100, height: 100), collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(VenueCVCell.self, forCellWithReuseIdentifier: "venueCell")
        cv.backgroundColor = .clear
        return cv
    }()
    
    
    //MARK: - Properties
    private let locationManager = CLLocationManager()
    
    private let defaultNewYorkCoordinates = CLLocationCoordinate2D(latitude: 40.742054, longitude: -73.769417)
    
    private let searchRadius: Double = 5000
    
    private var venues: [Venue] = [] {
        willSet {
            self.venues.removeAll()
        }
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
            activityIndicator.stopAnimating()
            
            self.resultsCollectionView.reloadData()
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
        view.addSubview(resultsCollectionView)
    }
    
    private func applyAllConstraints() {
        constrainGeoLocationSearchBar()
        constrainVenueSearchBar()
        constrainMapView()
        constrainListViewButton()
        constrainCollectionView()
    }
    
    private func requestLocationAndAuthorizeIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.userTrackingMode = .follow
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if let userLocation = locationManager.location?.coordinate {
                centerMapOnLocation(location: userLocation, zoomLevel: 2)
                displayNameOfLocality(location: userLocation)
            } else {
                centerMapOnLocation(location: defaultNewYorkCoordinates, zoomLevel: 2)
            }
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //to zoom in the annotation
    private func centerMapOnLocation(location: CLLocationCoordinate2D, zoomLevel: Double) {
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: searchRadius * zoomLevel, longitudinalMeters: searchRadius * zoomLevel)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    private func displayNameOfLocality(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let locationObject = CLLocation(latitude: location.latitude, longitude: location.longitude)
        DispatchQueue.global(qos: .userInitiated).async {
            geocoder.reverseGeocodeLocation(locationObject) { (placemarks, error) in
                guard let placemark = placemarks?.first else {
                    print(error.debugDescription)
                    return
                }
                guard let placemarkLocality = placemark.locality?.description, let placemarkAdministrativeArea = placemark.administrativeArea?.description else {return}
                DispatchQueue.main.async {
                    self.geoLocationSearchBar.text = "\(placemarkLocality), \(placemarkAdministrativeArea)"
                }
            }
        }
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
            centerMapOnLocation(location: userLocation.coordinate, zoomLevel: 4)
            guard let lat = self.locationManager.location?.coordinate.latitude, let long = self.locationManager.location?.coordinate.longitude else { return }
            if let query = self.venueSearchBar.text {
                self.loadVenues(lat: lat, long: long, query: query)
            }
        } else if geoLocationSearchBar.text != "" {
            let geocoder = CLGeocoder()
            guard let locationSearchString = geoLocationSearchBar.text else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                geocoder.geocodeAddressString(locationSearchString) { (placemark, error) in
                    DispatchQueue.main.async {
                        guard let placemark = placemark?.first else {
                            print(error.debugDescription)
                            return
                        }
                        
                        guard let placemarkCoordinates = placemark.location?.coordinate else {return}
                        self.centerMapOnLocation(location: placemarkCoordinates, zoomLevel: 3)
                        if let query = self.venueSearchBar.text {
                            self.loadVenues(lat: placemarkCoordinates.latitude, long: placemarkCoordinates.longitude, query: query)
                        }
                    }
                }
            }
        } else {
            centerMapOnLocation(location: defaultNewYorkCoordinates, zoomLevel: 4)
            if let query = self.venueSearchBar.text {
                self.loadVenues(lat: defaultNewYorkCoordinates.latitude, long: defaultNewYorkCoordinates.longitude, query: query)
            }
        }
        
        
    }
    
    private func loadVenues(lat: CLLocationDegrees, long: CLLocationDegrees, query: String) {
        DispatchQueue.main.async {
            VenueFetchingService.manager.getVenues(lat: lat, long: long, query: query) { (result) in
                switch result {
                case .success(let retrievedVenues):
                    self.venues = retrievedVenues
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}


//MARK: - MapKit Delegate
extension SearchViewController: MKMapViewDelegate {
}


//MARK: - CollectionView Delegate
extension SearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "venueCell", for: indexPath) as! VenueCVCell
        
        if let venuePhoto = venues[indexPath.row].venue?.photoData {
            cell.imageView.image = UIImage(data: venuePhoto)
        } else {
            if let venueID = venues[indexPath.row].venue?.id {
                DispatchQueue.main.async {
                    VenuePhotoFetchingService.manager.getVenuePhoto(venueID: venueID) { (result) in
                        switch result {
                        case .failure:
                            self.venues[indexPath.row].venue?.photoData = UIImage(systemName: "photo.fill")?.withTintColor(.gray).pngData()
                        case .success(let venueImage):
                            DispatchQueue.main.async {
                                self.venues[indexPath.row].venue?.photoData = venueImage.pngData()
                                cell.imageView.image = venueImage
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    
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
    
    private func constrainCollectionView() {
        resultsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsCollectionView.heightAnchor.constraint(equalToConstant: 100),
            resultsCollectionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            resultsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            resultsCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
}
