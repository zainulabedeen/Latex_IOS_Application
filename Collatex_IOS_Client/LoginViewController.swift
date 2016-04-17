//
//  LoginViewController.swift
//  Collatex_IOS_Client
//
//  Created by Foo Bar on 4/17/16.
//  Copyright © 2016 hs-fulda. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let socket = SocketIOClient(socketURL: NSURL(string:"http://192.168.137.1:3000")!)
    var sessionId : String!
    var owner : String!
    var loggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
        self.socket.connect()
        
        self.socket.on("connect"){[weak self] data, ack in
            self!.connectHadler(data)
            
        }
        
        self.socket.on("server_login"){[weak self] data, ack in
            self!.loginHadler(data)
            
        }
        
        self.socket.on("server_useronlinelist"){[weak self] data, ack in
            self!.loginUsersHadler(data)
            
        }
        self.socket.on("sessionid"){[weak self] data, ack in
            self!.getSessionId(data)
            
        }
    }

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func LoginButtonPressed(sender: AnyObject) {
        
        let user = emailField.text!
        let pass = passwordField.text!
        
        if (user.isEmpty || pass.isEmpty)
        {
            displayAlertMessage("All fields are Required")
            return
        }
        
        let jsonObject: [String: AnyObject] = [
            "userEmail": user,
            "userPassword": pass,
        ]
        
        socket.emit("client_login",jsonObject,sessionId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectHadler(data: AnyObject)
    {
        print("connected to server")
        print(data)
        self.socket.emit("room", "abc123")
        
    }
    
    func loginHadler(data: AnyObject)
    {
        print("login_reponse")
        print(data)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (String(data[0]).containsString("match"))
        {
            displayAlertMessage("UserName or Password Incorrect")
        }
        else
        {
            owner = String(data[0])
            print(owner)
            ///displayAlertMessage("login Successfull")
            loggedIn = true
            let vc: ViewController = storyboard.instantiateViewControllerWithIdentifier("latexController") as! ViewController
            vc.owner = owner
            self.presentViewController(vc, animated: true, completion: nil)
            socket.disconnect()
        }
    }
    
    func loginUsersHadler(data: AnyObject)
    {
        print("loginUsers_reponse")
        print(data)
        
    }
    func getSessionId(data: AnyObject)
    {
        print("Message Recieved")
        sessionId = String(data[0])
        print(data)

    }
    
    func displayAlertMessage(userMessage: String)
    {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //var DestViewController : ViewController = segue.destinationViewController as! ViewController
        //DestViewController.owner = owner
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
