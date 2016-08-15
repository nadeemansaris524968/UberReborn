/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var riderLBL: UILabel!
    
    @IBOutlet weak var driverLBL: UILabel!
    
    var signupState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        self.username.delegate = self
        
        self.password.delegate = self
        
        
        
    }
    @IBOutlet weak var signupBTNOTLT: UIButton!
    
    @IBAction func signup(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Missing Field(s)", message: "Username and password are required!")
            
        }
        else {
            
            let user: PFUser = PFUser()
            user.username = username.text
            user.password = password.text
            
            if signupState == true {
                
                // Sign up code
           
                user["isDriver"] = `switch`.on
            
                user.signUpInBackgroundWithBlock({ (success, error) in
                
                    if success == true {
                        
                       self.performSegueWithIdentifier("loginRider", sender: self)
                    
                    }
                
                    else    {
                        if let error = error {
                        
                            let errorString = error.userInfo["error"] as? NSString
                        
                            self.displayAlert("Signup failed!", message: errorString as! String)
                        
                        }
                    }
                })
            }
            
            else {
                
                // Log in code
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) in
                    
                    if user != nil {
                        
                        // Successful login
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                    }
                    else {
                        
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            self.displayAlert("Login failed!", message: errorString)
                        }
                    }
                    
                })
                
            }
        }
    }

    @IBOutlet weak var toggleLoginTextOTLT: UIButton!
    
    @IBAction func toggleLogin(sender: AnyObject) {
        
        if signupState == true {
            
            signupBTNOTLT.setTitle("Log in", forState: UIControlState.Normal)
            
            toggleLoginTextOTLT.setTitle("Switch to Sign up", forState: UIControlState.Normal)
            
            signupState = false
            
            riderLBL.alpha = 0
            
            driverLBL.alpha = 0
            
            `switch`.alpha = 0
            
        }
        else {
            
            signupBTNOTLT.setTitle("Sign up", forState: UIControlState.Normal)
            
            toggleLoginTextOTLT.setTitle("Switch to login", forState: UIControlState.Normal)
            
            signupState = true
            
            riderLBL.alpha = 1
            
            driverLBL.alpha = 1
            
            `switch`.alpha = 1
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
        
            performSegueWithIdentifier("loginRider", sender: self)
        }
    }
    
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}
