//
//  LocationSearchViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/4/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import UIKit

class LocationSearchViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
 
    var placesClient: GMSPlacesClient = GMSPlacesClient()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var searchResultData = [GMSAutocompletePrediction]()
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
            print(currentLocation)
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

        print("selectedPlaceForSegue \(selectedPlaceName)")

        print("planCreationViewController \(planCreationViewController)")
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        let n = self.navigationController?.viewControllers?.count as Int!
//        let planCreationViewController = self.navigationController?.viewControllers[n-2] as! PlanCreationViewController
//        
//        self.navigationController?.navigationBar.backItem
//        
//        println("planCreationViewController"planCreationViewController)
//        
////        let navController = segue.destinationViewController as! UINavigationController
////        let planCreationViewController = segue.destinationViewController as! PlanCreationViewController
////        
////        planCreationViewController.selectedPlaceId = selectedPlaceId
////        planCreationViewController.selectedPlaceName = selectedPlaceName
////        planCreationViewController.selectedPlaceGeoPoint = selectedPlaceGeoPoint
////        planCreationViewController.selectedPlaceFormattedAddress = selectedPlaceFormattedAddress
////        
////        println("selectedPlaceForSegue \(selectedPlaceName)")
//
//    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        print("selectedPlaceLocationSearch \(selectedPlaceName)")
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.searchResultData[indexPath.row]
        let placeText = place.attributedFullText.string
        print("row selected")
//        self.searchBar.text = placeText
        self.selectedPlaceId = place.placeID
        self.locationSearchResults.hidden = true
        
        
        //let placeId = "ChIJv2V798IJlR4Rq66ydZpHmt0"
        
        placesClient.lookUpPlaceID(selectedPlaceId, callback: {(place, error) -> Void in
            if error != nil {
                print("lookup place id query error")
                return
            }
            
            if place != nil {
                self.selectedPlaceName = place!.name
                self.selectedPlaceFormattedAddress = place!.formattedAddress
                
                let selectedPlaceCoordinate = place!.coordinate
                let longitude = selectedPlaceCoordinate.longitude
                let latitude = selectedPlaceCoordinate.latitude
                
                self.selectedPlaceGeoPoint = PFGeoPoint(latitude: selectedPlaceCoordinate.latitude, longitude: selectedPlaceCoordinate.longitude)
                let n = self.navigationController
                n?.popViewControllerAnimated(true)

            }
            
        })
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceAutocompleteCell") as! UITableViewCell!
        let place = self.searchResultData[indexPath.row]
        
        cell.textLabel!.text = place.attributedFullText.string
        //cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            //self.places = []
            print("aint nothin here")
            locationSearchResults.hidden = true
            self.searchResultData = [GMSAutocompletePrediction]()
            self.locationSearchResults.reloadData()
        }
        else {
            locationSearchResults.hidden = false
            print("searching for \(searchText)")
            let locValue = currentLocation.coordinate
            print("location at \(locValue.latitude), \(locValue.longitude)")
            let northEast = CLLocationCoordinate2DMake(locValue.latitude + 1, locValue.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(locValue.latitude - 1, locValue.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
            
            placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: {
                (results, error) -> Void in
                if error != nil {
                    print("Hay error \(error)")
                    return
                }
                else {
                    self.searchResultData = [GMSAutocompletePrediction]()
                    for result in results as! [GMSAutocompletePrediction] {
                        self.searchResultData.append(result)
                        print(result)
                    }
                    self.locationSearchResults.reloadData()
                }
            })
        }
    }
}