//
//  LocationViewController.swift
//  Weather App
//
//  Created by Gerjan te Velde on 03/05/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - Objects and Properties
    var networkService: NetworkService?
    @IBOutlet weak var showWeatherButton: UIButton!
    @IBOutlet weak var goToMyLocationButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    let locationmanager = CLLocationManager()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showWeatherButton.layer.cornerRadius = 5
        goToMyLocationButton.layer.cornerRadius = 5
        
        networkService = NetworkService()
        
        locationmanager.delegate = self
    }
    
    //MARK: - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 1_000, longitudinalMeters: 1_000)
            mapView.setRegion(region, animated: true)
            goToMyLocationButton.isEnabled = true
            activityIndicator.stopAnimating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //MARK: - Actions
    @IBAction func showWeatherButtonTouchUpInside(_ sender: UIButton) {
        let center = mapView.centerCoordinate
        networkService!.createCurrentWeatherURL(for: .geographicCoordinates(latitude: center.latitude, longitude: center.longitude))
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CurrentWeatherTableViewController") as! CurrentWeatherTableViewController
        destinationVC.networkService = networkService
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func goToMyLocationButtonTouchUpInside(_ sender: UIButton) {
        locationmanager.requestWhenInUseAuthorization()
        goToMyLocationButton.isEnabled = false
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        locationmanager.requestLocation()
    }
}

