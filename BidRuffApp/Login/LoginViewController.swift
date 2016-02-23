//
//  LoginViewController.swift
//  BidRuffApp
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var viewShaker:AFViewShaker?
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        viewShaker = AFViewShaker(viewsArray: [emailTextField, passwordTextField])
        // Do any additional setup after loading the view.
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            
            var user = PFUser()
            user.email = emailTextField.text!.lowercaseString
            user.username = user.email
            user.password = passwordTextField.text!
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded == true {
                    self.registerForPush()
                    self.performSegueWithIdentifier("loginToItemSegue", sender: nil)
                } else {
                    let errorString = error.userInfo["error"] as! NSString
                    print("Error Signing up: \(error)")
                    PFUser.logInWithUsernameInBackground(user.username, password: user.password, block: { (user, error) -> Void in
                        if error == nil {
                            
                            self.registerForPush()
                            self.performSegueWithIdentifier("loginToItemSegue", sender: nil)
                        }else{
                            print("Error logging in ")
                            self.viewShaker?.shake()
                        }
                    })
                }
            }
            
        }else{
            //Can't login with nothing set
            viewShaker?.shake()
        }
    }
    
    
    func registerForPush() {
        let user = PFUser.currentUser()
        let currentInstalation = PFInstallation.currentInstallation()
        currentInstalation["email"] = user.email
        currentInstalation.saveInBackgroundWithBlock(nil)

        
        let application = UIApplication.sharedApplication()
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert,UIUserNotificationType.Sound,UIUserNotificationType.Badge], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else{
            let types: UIRemoteNotificationType = [.Badge, .Alert, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
    }
}
