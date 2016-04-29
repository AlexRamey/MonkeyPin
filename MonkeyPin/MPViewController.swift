//
//  ViewController.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 3/18/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MPViewController: UIViewController {
    let MP_PLAYER_NAME_DEFAULTS_KEY:String = "MP_PLAYER_NAME_DEFAULTS_KEY"
    var isPresentingScene:Bool = false
    var backgroundMusicPlayer:AVAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let isTesting:Bool = false
        if let spriteView:SKView = self.view as? SKView{
            spriteView.showsDrawCount = isTesting
            spriteView.showsNodeCount = isTesting
            spriteView.showsFPS = isTesting
        }
        
        if let url = NSBundle.mainBundle().URLForResource("jungle", withExtension: "wav"){
            do{
                let audioPlayer = try AVAudioPlayer(contentsOfURL: url)
                audioPlayer.numberOfLoops = -1
                if NSUserDefaults.standardUserDefaults().integerForKey("MP_AUDIO_ON_DEFAULTS_KEY") == 1{
                    // if audio is on
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                }
                self.backgroundMusicPlayer = audioPlayer
            }catch{
                print("uh-oh . . . audio player exception")
            }
        }
        
        // handle shake events
        self.becomeFirstResponder()
        
        // listen for audio toggles
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(turnAudioON), name: "audioON", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(turnAudioOFF), name: "audioOFF", object: nil)
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (motion == .MotionShake){
            // Post a notification any time the user shakes the device
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: nil)
        }
    }
    
    func turnAudioON(notification: NSNotification){
        if let player = self.backgroundMusicPlayer{
            player.prepareToPlay()
            player.play()
        }
    }
    
    func turnAudioOFF(notification: NSNotification){
        if let player = self.backgroundMusicPlayer{
            player.stop()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (!isPresentingScene){
            let scene = MPHomeScene(size:self.view.frame.size)
            if let spriteView:SKView = self.view as? SKView{
                spriteView.presentScene(scene)
                isPresentingScene = true
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(MP_PLAYER_NAME_DEFAULTS_KEY){
            // player has already entered a name
            print(NSUserDefaults.standardUserDefaults().objectForKey(MP_PLAYER_NAME_DEFAULTS_KEY))
        }else{
            self.promptForPlayerName()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if (isPresentingScene){
            if let spriteView:SKView = self.view as? SKView{
                if let scene = spriteView.scene{
                    scene.size = size
                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // helper function to present UIAlertController to prompt user for player name input
    func promptForPlayerName(){
        let alertController = UIAlertController(title: "Player Name", message: "Enter your player name that will appear on the leaderboards. You may update it later in settings.", preferredStyle: .Alert)
        
        // The 'save' button is the user's only way out
        let saveAction = UIAlertAction(title: "Save", style: .Default , handler: { (_) in
            if let name = alertController.textFields![0].text{
                NSUserDefaults.standardUserDefaults().setObject(name, forKey:self.MP_PLAYER_NAME_DEFAULTS_KEY)
            }
        })
        saveAction.enabled = false
        
        
        alertController.addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Player1234567"
            
            // only enable the 'save' button if the user has entered a non-empty string
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                saveAction.enabled = textField.text != ""
            }
        })
        
        alertController.addAction(saveAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

}

