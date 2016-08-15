//
//  RequestViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Nadeem Ansari on 8/15/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {
    
    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var requestUsername: String!

    @IBOutlet weak var driverMap: MKMapView!
    
    
    @IBAction func pickUpRider(sender: AnyObject) {
        
        let query = PFQuery(className: "riderRequest")
        
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if error == nil {
                
                print("Successfully retrieved \(objects!.count) objects")
                
                if let objects = objects! as? [PFObject]{
                    
                    for object in objects {
                        
                        var query = PFQuery(className: "riderRequest")
                        
                        query.getObjectInBackgroundWithId(object.objectId!, block: { (object, error ) in
                            
                            if let object = object {
                                
                                object["driverResponded"] = PFUser.currentUser()?.username
                                
                                object.saveInBackground()
                                
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                
                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                                    
                                    if error != nil {
                                        print(error)
                                    }
                                    else {
                                        if placemarks?.count > 0 {
                                            if let pm = placemarks![0] as? CLPlacemark {
                                                
                                                let mkPm = MKPlacemark(placemark: pm)
                                                
                                                var mapItem = MKMapItem(placemark: mkPm)
                                                
                                                mapItem.name = self.requestUsername
                                                
                                                var launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                                
                                                mapItem.openInMapsWithLaunchOptions(launchOptions)
                                                
                                            }
                                        }
                                    }
                                    
                                })
                                
                            }
                            
                            if error != nil {
                                print(error)
                            }
                            
                        })
                    }
                }
            }
            else {
                print("Error: \(error?.userInfo["error"])")
            }
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print(requestUsername)
        print(requestLocation)
        
        let center = requestLocation
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.driverMap.setRegion(region, animated: true)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        
        annotation.coordinate = requestLocation
        
        annotation.title = requestUsername
        
        self.driverMap.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
