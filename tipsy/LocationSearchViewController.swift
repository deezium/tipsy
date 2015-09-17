//
//  LocationSearchViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/4/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit
import Parse

class LocationSearchViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
 
//    var placesClient: GMSPlacesClient = GMSPlacesClient()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
//    var searchResultData = [GMSAutocompletePrediction]()
    var searchResultData = NSArray()
    var selectedPlaceId = String()
    var selectedPlaceName = String()
    var selectedPlaceGeoPoint = PFGeoPoint()
    var selectedPlaceFormattedAddress = String()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationSearchResults: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        locationSearchResults.hidden = true
        locationSearchResults.dataSource = self
        locationSearchResults.delegate = self
        
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            if (locationManager.location != nil) {
                self.currentLocation = locationManager.location!
            }
        }

    }

    override func viewWillDisappear(animated: Bool) {
        let n = self.navigationController?.viewControllers.count as Int!
        let planCreationViewController = self.navigationController?.viewControllers[n-1] as! PlanCreationViewController
        
        self.navigationController?.navigationBar.backItem
        
        if selectedPlaceId != "" {
            planCreationViewController.selectedPlaceId = selectedPlaceId
            planCreationViewController.selectedPlaceName = selectedPlaceName
            planCreationViewController.selectedPlaceGeoPoint = selectedPlaceGeoPoint
            planCreationViewController.selectedPlaceFormattedAddress = selectedPlaceFormattedAddress
            planCreationViewController.locationChanged = true
            
        }

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.searchResultData[indexPath.row]
        self.selectedPlaceId = place.placeID
        self.locationSearchResults.hidden = true
        
        
//        placesClient.lookUpPlaceID(selectedPlaceId, callback: {(place, error) -> Void in
//            if error != nil {
//                print("lookup place id query error")
//                return
//            }
//            
//            if place != nil {
//                self.selectedPlaceName = place!.name
//                self.selectedPlaceFormattedAddress = place!.formattedAddress
//                
//                let selectedPlaceCoordinate = place!.coordinate
//                
//                self.selectedPlaceGeoPoint = PFGeoPoint(latitude: selectedPlaceCoordinate.latitude, longitude: selectedPlaceCoordinate.longitude)
//                let n = self.navigationController
//                n?.popViewControllerAnimated(true)
//
//            }
//            
//        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceAutocompleteCell") as! UITableViewCell!
        let place = self.searchResultData[indexPath.row]
        
//        cell.textLabel!.text = place.attributedFullText.string
        //cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText == "" {
//            //self.places = []
//            print("aint nothin here")
//            locationSearchResults.hidden = true
//  //          self.searchResultData = [GMSAutocompletePrediction]()
//            self.locationSearchResults.reloadData()
//        }
//        else {
//            locationSearchResults.hidden = false
//            let locValue = currentLocation.coordinate
//            let northEast = CLLocationCoordinate2DMake(locValue.latitude + 1, locValue.longitude + 1)
//            let southWest = CLLocationCoordinate2DMake(locValue.latitude - 1, locValue.longitude - 1)
//    //        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
//      //      let filter = GMSAutocompleteFilter()
//        //    filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
//            
//          //  placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: {
//                (results, error) -> Void in
//                if error != nil {
//                    print("Hay error \(error)")
//                    return
//                }
//                else {
//                    
//                    if let results = results {
//                        self.searchResultData = [GMSAutocompletePrediction]()
//                        for result in results as! [GMSAutocompletePrediction] {
//                            self.searchResultData.append(result)
//                        }
//                        self.locationSearchResults.reloadData()
//                        
//                    }
//                }
//            })
//        }
//    }
}