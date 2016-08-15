//
//  RiderViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Nadeem Ansari on 8/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var callUberBTN: UIButton!
    
    @IBOutlet weak var myMap: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    
    var longitude: CLLocationDegrees = 0
    
    var riderRequestActive = false
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
            if latitude == 0 || longitude == 0 {
                displayAlert("Could not call Uber!", message: "Your location is not correct")
            }
            else {
                let riderRequest = PFObject(className: "riderRequest")
                riderRequest["username"] = PFUser.currentUser()?.username
                riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
        
                riderRequest.saveInBackgroundWithBlock { (success, error) in
            
                    if success == true {
                
                        self.callUberBTN.setTitle("Cancel Uber", forState: UIControlState.Normal)
                    }
                    else {
                    
                        self.displayAlert("Could not call Uber!", message: "Please try again")
                    }
                }
            }
         
            riderRequestActive = true
        }
        
        else {
            
            riderRequestActive = false
            
            self.callUberBTN.setTitle("Call an Uber", forState: UIControlState.Normal)
            
            let query = PFQuery(className: "riderRequest")
            
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                
                if error == nil {
                    
                    print("Successfully retrieved \(objects!.count) objects")
                    
                    if let objects = objects! as? [PFObject]{
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                        }
                    }
                }
                else {
                    print("Error: \(error?.userInfo["error"])")
                }
            })
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        if #available(iOS 8.0, *) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMap.delegate = self
        
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
        
        print("Lat: \(location.latitude), Lon: \(location.latitude)")
        
        latitude = location.latitude
        
        longitude = location.longitude
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.myMap.setRegion(region, animated: true)
        
        self.myMap.removeAnnotations(myMap.annotations)
        
        let pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        
        annotation.coordinate = pinLocation
        
        annotation.title = "You're here!"
        
        self.myMap.addAnnotation(annotation)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
            
            PFUser.logOut()
        }
    }
}
