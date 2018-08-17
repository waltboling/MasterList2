//
//  LocationReminderViewController.swift
//  MasterList2
//
//  Created by Jon Boling on 8/13/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import CloudKit

class LocationReminderViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var radiusControl: UISegmentedControl!
    @IBOutlet weak var notificationControl: UISegmentedControl!
    @IBOutlet weak var inputAddressTextField: UITextField!
    
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    var currentList: CKRecord?
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    
    var coordinate: CLLocationCoordinate2D?
    var selectedRadius = 0
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressSearchBar.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        //maybe move all instances of the notCenter to Menu's viewDidLoad
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("Accepted permission.")
            } else {
                print("Did not accept permission.")
            }
        }
       self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            //locationManager.stopUpdatingLocation()
        //setting map region
        /*if let location = RemindersManager.shared.currentLocation {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            mapView.setRegion(region, animated: true)*/
            
            mapView.showsUserLocation = true

        }
        
        
        addMapTrackingButton()

    }
    
    //update user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        let userLocation = locations.last
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let viewRegion = MKCoordinateRegionMake((userLocation?.coordinate)!, span)
        self.mapView.setRegion(viewRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }

    //search bar functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // ignoring user? why? idk
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //hide search bar
        searchBar.resignFirstResponder()
        
        //create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            //remove activity indicator
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("error") // eventually should show error alert
            } else {
                //for removing annotations (maybe dont want)
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                //getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                //zooming in on annotation
                self.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegionMake(self.coordinate!, span)
                self.mapView.setRegion(region, animated: true)
            }
            
        }
    
    }
    
    //IBActions

    @IBAction func cancelWasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonWasTapped(_ sender: Any) {
        let notifyIndex = notificationControl.selectedSegmentIndex
        let notifyOnEntry = (notifyIndex == 0 || notifyIndex == 2)
        let notifyOnExit = (notifyIndex == 1 || notifyIndex == 2)
        let radiusIndex = radiusControl.selectedSegmentIndex
        if radiusIndex == 0 {
            selectedRadius = 100
        } else if radiusIndex == 1 {
            selectedRadius = 200
        } else if radiusIndex == 2 {
            selectedRadius = 500
        } else if radiusIndex == 3 {
            selectedRadius = 1000
        } else {
            print("error getting radius")
        }
        print("selected radius is \(selectedRadius)")
        
        if let coordinate = coordinate {
            let reminder = Reminder(coordinate: coordinate, notifyOnEntry: notifyOnEntry, notifyOnExit: notifyOnExit, selectedRadius: selectedRadius)
            RemindersManager.shared.add(reminder: reminder)
            dismiss(animated: true, completion: nil)
            print("coordinate is \(coordinate)")
        }
        
        //need to set up iCloud saving still
    }
    
    func addMapTrackingButton(){
        //let image = UIImage(named: "trackme") as UIImage?
        let button   = UIButton(type: UIButtonType.custom) as UIButton
        button.frame = CGRect(origin: CGPoint(x:5, y: 25), size: CGSize(width: 35, height: 35))
        //button.setImage(image, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(self.centerMapOnUserButtonClicked), for:.touchUpInside)
        mapView.addSubview(button)
    }
    
    @objc func centerMapOnUserButtonClicked() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
}
