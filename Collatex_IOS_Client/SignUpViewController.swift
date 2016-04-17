//
//  SignUpViewController.swift
//  Collatex_IOS_Client
//
//  Created by Foo Bar on 4/17/16.
//  Copyright © 2016 hs-fulda. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    let socket = SocketIOClient(socketURL: NSURL(string:"http://192.168.137.1:3000")!)
    var sessionId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userEmailField.delegate = self
        self.password1Field.delegate = self
        self.password2Field.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        self.socket.connect()
        
        self.socket.on("connect"){[weak self] data, ack in
            self!.connectHadler(data)
            
        }
        
        self.socket.on("sessionid"){[weak self] data, ack in
            self!.getSessionId(data)
            
        }
        
        self.socket.on("server_registration"){[weak self] data, ack in
            self!.getRegistrationResponse(data)
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var userEmailField: UITextField!

    @IBOutlet weak var password1Field: UITextField!

    @IBOutlet weak var password2Field: UITextField!
    
    
    @IBAction func RegisterButtonPressed(sender: AnyObject) {
        let user = userEmailField.text!
        let pass = password1Field.text!
        let pass2 = password2Field.text!
        
        if (pass != pass2)
        {
            displayAlertMessage("Passwords do not Match")
            return
        }
        
        if (user.isEmpty || pass.isEmpty || pass2.isEmpty)
        {
            displayAlertMessage("All fields are Required")
            return
        }
        
        let jsonObject: [String: AnyObject] = [
            "userEmail": user,
            "userPassword": pass,
        ]
        
        socket.emit("client_register",jsonObject,sessionId)
        
    }
    
    func connectHadler(data: AnyObject)
    {
        print("connected to server")
        print(data)
        self.socket.emit("room", "abc123")
        
    }
    
    func getSessionId(data: AnyObject)
    {
        print("Message Recieved")
        sessionId = String(data[0])
        print(data)
        
    }
    
    func getRegistrationResponse(data: AnyObject)
    {
        print("login_reponse")
        print(data)
    
        
        if (String(data[0]).containsString("Error"))
        {
            displayAlertMessage("Cannot Register: Please try Again later")
        }
        else
        {
            displayAlertMessage("Registration Successful: Login to continue")
            
            socket.disconnect()
        }
    }
    
    func displayAlertMessage(userMessage: String)
    {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
