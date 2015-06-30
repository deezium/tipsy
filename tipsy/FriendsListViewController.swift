//
//  FriendsListViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 6/18/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import SwiftAddressBook

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsListTableView : UITableView!
    
    let kCellIdentifier: String = "FriendsListCell"
    let facebook = FacebookController()
    var results = [String]()
    
    func getPeople() -> Array<String> {
        if let people : [SwiftAddressBookPerson] = swiftAddressBook?.allPeople {
            //println("people: \(people)")
            for person in people {
                println(person.compositeName)
                results.append(person.compositeName!)
            }
        }
        println(results.count)
        return results
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPeople()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        println(facebook.returnUserData())
        return self.getPeople().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        let result = self.getPeople()[indexPath.row]
        
        cell.textLabel?.text = "\(result)"
        return cell
    }
}