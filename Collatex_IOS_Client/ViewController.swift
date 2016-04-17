//
//  ViewController.swift
//  Collatex_IOS_Client
//
//  Created by Foo Bar on 4/15/16.
//  Copyright © 2016 hs-fulda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate{
    
    let socket = SocketIOClient(socketURL: NSURL(string:"http://192.168.137.1:3000")!)
    var sessionId : String!
    var owner : String!
    
    @IBOutlet weak var docNameField: UITextField!
    
    @IBAction func roundBracketsPressed(sender: AnyObject) {
        textField.replaceRange(textField.selectedTextRange!, withText: "()")
    }
    
    @IBAction func backslashPressed(sender: AnyObject) {
        textField.replaceRange(textField.selectedTextRange!, withText: "'\'")
    }
    @IBAction func dollarPressed(sender: AnyObject) {
        
        textField.replaceRange(textField.selectedTextRange!, withText: "$")
    }
    
    @IBAction func plusPressed(sender: AnyObject) {
        
        textField.replaceRange(textField.selectedTextRange!, withText: "+")
    }
    @IBAction func curlyBracketsPressed(sender: AnyObject) {
        
        
        textField.replaceRange(textField.selectedTextRange!, withText: "{}")
    }
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.textField.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
        
        self.textField.layer.borderWidth = CGFloat(Float(1.0))
        self.textField.layer.cornerRadius = CGFloat(Float(5.0))
        
        //self.textField.text = ""
        textField.delegate = self
        
        self.addHandlers();
        self.socket.connect()
        self.socket.on("connect"){[weak self] data, ack in
            self!.connectHadler(data)
            
        }
        print(owner)
        self.socket.on("server_character"){[weak self] data, ack in
            self!.msgRecieveHandler(data)
            
        }
        self.socket.on("sessionid"){[weak self] data, ack in
            self!.getSessionId(data)
            
        }
        self.socket.on("user_online"){[weak self] data, ack in
            self!.onlineUsers(data)
            
        }
        //socket.disconnect()
        super.viewDidLoad()
    }
    @IBOutlet weak var textField: UITextView!

    @IBOutlet weak var _convetButton: UIButton!
    
    @IBOutlet weak var OnlineUsers: UILabel!
    
    @IBOutlet weak var _saveButton: UIButton!
    
    @IBAction func covertButtonPressed(sender: AnyObject) {
        socket.emit("client_convert", "doc3.tex", sessionId)
    }
    
    @IBAction func saveButtonPresssed(sender: AnyObject) {
        
        var docName = "default"
        if (docNameField.text!.isEmpty == false)
        {
            docName = docNameField.text!
        }
        
        let jsonObject: [String: AnyObject] = [
            "name": docName,
            "content": textField.text,
            "owner": owner,
        ]
        
        socket.emit("client_doc", jsonObject, sessionId)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyPressed(command:UIKeyCommand){
        
        print("user pressed \(command.input)")
    }
    
    func addHandlers(){
        
    }
    
    func onlineUsers(data: AnyObject)
    {

        OnlineUsers.hidden = false
        OnlineUsers.text = "Number of Users Online:\(data[0])"
        OnlineUsers.reloadInputViews()
        
    }
    func connectHadler(data: AnyObject)
    {
        print("connected to server")
        print(data)
        self.socket.emit("room", "abc123")
        
    }
    
    func msgRecieveHandler(data: AnyObject)
    {
        print("Message Recieved")
        textField.text = String(data[0])
        textField.reloadInputViews()
        print(data)
    }
    
    func getSessionId(data: AnyObject)
    {
        print("Message Recieved")
        sessionId = String(data[0])
        print(data)
    }
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
        let jsonObject: [String: AnyObject] = [
            "buffer": textField.text,
        ]
        
        socket.emit("client_character", jsonObject, sessionId)
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        socket.disconnect()
    
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

