//
//  PlanCreationViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 7/20/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

class PlanCreationViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    var placesClient: GMSPlacesClient = GMSPlacesClient()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var searchResultData = [GMSAutocompletePrediction]()

    @IBOutlet weak var startTime: UIDatePicker!
    
    @IBOutlet weak var endTime: UIDatePicker!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResults: UITableView!
    
    @IBAction func didTapPostButton(sender: AnyObject) {
        println("posted")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        searchBar.delegate = self
        self.searchResults.hidden = true
        self.searchResults.delegate = self
        self.searchResults.dataSource = self
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            self.currentLocation = locationManager.location
            println(currentLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            println("your current location is \(currentLocation)")
            locationManager.stopUpdatingLocation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceAutocompleteCell") as! UITableViewCell
        let place = self.searchResultData[indexPath.row]
        
        cell.textLabel!.text = place.attributedFullText.string
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            //self.places = []
            println("aint nothin here")
            searchResults.hidden = true
            self.searchResultData = [GMSAutocompletePrediction]()
            self.searchResults.reloadData()
        }
        else {
            searchResults.hidden = false
            println("searching for \(searchText)")
            let locValue = currentLocation.coordinate
            println("location at \(locValue.latitude), \(locValue.longitude)")
            let northEast = CLLocationCoordinate2DMake(locValue.latitude + 1, locValue.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(locValue.latitude - 1, locValue.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
            
            placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: {
                (results, error) -> Void in
                if error != nil {
                    println("Hay error \(error)")
                    return
                }
                else {
                    self.searchResultData = [GMSAutocompletePrediction]()
                    for result in results as! [GMSAutocompletePrediction] {
                        self.searchResultData.append(result)
                        println(result)
                    }
                    self.searchResults.reloadData()
                }
            })
        }
    }
}