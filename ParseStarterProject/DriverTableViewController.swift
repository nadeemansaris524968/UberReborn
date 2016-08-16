//
//  DriverTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Nadeem Ansari on 8/15/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var usernames = [String]()
    
    var locations = [CLLocationCoordinate2D]()
    
    var locationManager: CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    
    var longitude: CLLocationDegrees = 0
    
    var distances = [CLLocationDistance]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        
        locationManager.startUpdatingLocation()

        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = location.latitude
        
        longitude = location.longitude
        
        print("Lat: \(latitude), Lon: \(longitude)")
        
        var query = PFQuery(className: "driverLocation")
        
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            
            if error == nil {
                
                if let objects = objects! as [PFObject]! {
                    
                    if objects.count > 0 {
                    
                    for object in objects {
                        
                        var query = PFQuery(className: "driverLocation")
                        query.getObjectInBackgroundWithId( object.objectId!, block: { (object, error) in
                            
                            if error != nil {
                                print(error)
                            }
                            else if let object = object {
                                object["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                                object.saveInBackground()
                            }
                            
                        })
                        
                    }
                }
                    else {
                        var driverLocation = PFObject(className: "driverLocation")
                        driverLocation["username"] = PFUser.currentUser()?.username
                        driverLocation["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.latitude)
                        
                        driverLocation.saveInBackground()
                    }
                    
                }
                
            }
            
            else {
                print(error)
            }
            
        }
        
        query = PFQuery(className: "riderRequest")
        
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
        
        query.limit = 10
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if error == nil {
                
                if let objects = objects! as? [PFObject]   {
                    
                    self.usernames.removeAll(keepCapacity: true)
                    
                    self.locations.removeAll(keepCapacity: true)
                    
                    for object in objects {
                        
                        if object["driverResponded"] == nil {
                        
                            if let username = object["username"] as? String {
                            
                                self.usernames.append(username)
                            
                            }
                        
                            if let returnedLocation = object["location"] as? PFGeoPoint {
                            
                                let requestLocation = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                            
                                self.locations.append(requestLocation)
                            
                                let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                                let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                                let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                            
                                self.distances.append(distance/1000)
                            }
                        }
                    
                    }
                        self.tableView.reloadData()
                }
            }
            else {
                print("Error: \(error?.userInfo["error"])")
            }
        })
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = usernames[indexPath.row] + " - " + String(format: "%.1f", distances[indexPath.row]) + "kms away"
        
        return cell
    }
 

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutDriver" {
            
            locationManager.stopUpdatingLocation()
            
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)
            
            PFUser.logOut()
        }
        
        if segue.identifier == "showViewRequests" {
            
            if let destination = segue.destinationViewController as? RequestViewController {
                
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
                
            }
            
        }
    }
    
}
