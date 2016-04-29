//
//  MPSettingsScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/23/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit
import UIKit

// two settings: difficulty and playerName (todo: maybe audio toggle)
class MPSettingsScene: SKScene, UITextFieldDelegate {
    var contentCreated:Bool = false
    var nameInput:UITextField? = nil
    var difficultyInput:UISegmentedControl? = nil
    var audioToggle:UISwitch? = nil
    
    // constants
    let MP_PLAYER_NAME_DEFAULTS_KEY:String = "MP_PLAYER_NAME_DEFAULTS_KEY"
    let MP_GAME_DIFFICULTY_DEFAULTS_KEY:String = "MP_GAME_DIFFICULTY_DEFAULTS_KEY"
    let placeholderTextColor = UIColor(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 0.6)
    
    override func didMoveToView(view: SKView) {
        if (self.contentCreated == false){
            // add name input field
            self.nameInput = UITextField()
            self.nameInput?.returnKeyType = .Done
            self.nameInput?.font = UIFont(name: "Chalkduster", size: 14.0)
            self.nameInput?.textColor = UIColor.whiteColor()
            self.nameInput?.backgroundColor = UIColor.clearColor()
            if let playerName:String = NSUserDefaults.standardUserDefaults().objectForKey(MP_PLAYER_NAME_DEFAULTS_KEY) as? String{
                self.nameInput?.attributedPlaceholder = NSAttributedString(string:playerName,
                                                                           attributes:[NSForegroundColorAttributeName: placeholderTextColor])
            }
            self.nameInput!.delegate = self
            view.addSubview(self.nameInput!)
            
            // add difficulty input segmented control
            self.difficultyInput = UISegmentedControl(items: ["Easy", "Normal", "Hard"])
            self.difficultyInput?.tintColor = UIColor.whiteColor()
            self.difficultyInput?.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey(MP_GAME_DIFFICULTY_DEFAULTS_KEY)
            self.difficultyInput?.addTarget(self, action: #selector(indexChanged), forControlEvents: .ValueChanged)
            self.difficultyInput?.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Chalkduster", size: 14.0)!], forState: .Normal)
            view.addSubview(self.difficultyInput!)
            
            // add audio toggle switch
            self.audioToggle = UISwitch()
            self.audioToggle?.on = (NSUserDefaults.standardUserDefaults().integerForKey("MP_AUDIO_ON_DEFAULTS_KEY") == 1)
            self.audioToggle?.tintColor = UIColor.whiteColor()
            self.audioToggle?.addTarget(self, action: #selector(audioToggled), forControlEvents: .ValueChanged)
            view.addSubview(self.audioToggle!)
            
            self.createSceneContents()
            self.contentCreated = true
        }
    }
    
    override func willMoveFromView(view: SKView) {
        self.nameInput?.removeFromSuperview()
        self.difficultyInput?.removeFromSuperview()
        self.audioToggle?.removeFromSuperview()
    }
    
    func createSceneContents(){
        self.backgroundColor = UIColor(colorLiteralRed: 73/255.0, green: 56/255.0, blue: 41/255.0, alpha: 1.0)
        self.scaleMode = SKSceneScaleMode.AspectFit
        
        let backButton = SKLabelNode(fontNamed:"Chalkduster")
        backButton.name = "backButton"
        backButton.fontSize = 18
        backButton.fontColor = SKColor.whiteColor()
        backButton.text = "Back"
        self.addChild(backButton)
        
        let nameInputLabel = SKLabelNode(fontNamed:"Chalkduster")
        nameInputLabel.name = "nameInputLabel"
        nameInputLabel.fontSize = 14
        nameInputLabel.verticalAlignmentMode = .Center
        nameInputLabel.fontColor = SKColor.whiteColor()
        nameInputLabel.text = "Edit Player Name: "
        self.addChild(nameInputLabel)
        
        let difficultyInputLabel = SKLabelNode(fontNamed:"Chalkduster")
        difficultyInputLabel.name = "difficultyInputLabel"
        difficultyInputLabel.fontSize = 14
        difficultyInputLabel.verticalAlignmentMode = .Center
        difficultyInputLabel.fontColor = SKColor.whiteColor()
        difficultyInputLabel.text = "Change Difficulty:"
        self.addChild(difficultyInputLabel)
        
        let audioToggleLabel = SKLabelNode(fontNamed: "Chalkduster")
        audioToggleLabel.name = "audioToggleLabel"
        audioToggleLabel.fontSize = 14
        audioToggleLabel.verticalAlignmentMode = .Center
        audioToggleLabel.fontColor = SKColor.whiteColor()
        audioToggleLabel.text = "Toggle Game Audio: "
        self.addChild(audioToggleLabel)
        
        self.updateViews()
    }
    
    func updateViews(){
        let sideMargin:CGFloat = 8.0
        let spacing:CGFloat = 16.0
        let topMargin:CGFloat = (self.frame.size.width > self.frame.size.height ? 16.0 : 32.0)
        let extraPadding:CGFloat = self.frame.size.height * 0.10;
        
        if let backButton = self.childNodeWithName("backButton"){
            backButton.position = CGPointMake((backButton.frame.size.width / 2.0) + sideMargin, self.frame.size.height - topMargin - backButton.frame.size.height/2.0)
            
            if let nameInputLabel = self.childNodeWithName("nameInputLabel"){
                nameInputLabel.position = CGPointMake(sideMargin + (nameInputLabel.frame.size.width/2.0), backButton.position.y - (backButton.frame.size.height/2.0) - spacing - (nameInputLabel.frame.size.height/2.0) - extraPadding)
                
                if let textField = self.nameInput{
                    let xPosition:CGFloat = nameInputLabel.position.x + (nameInputLabel.frame.size.width/2.0) + spacing
                    textField.frame = CGRectMake(xPosition, self.frame.size.height - backButton.position.y + backButton.frame.size.height/2.0 + spacing + extraPadding, self.frame.size.width - xPosition - sideMargin, nameInputLabel.frame.size.height)
                }
                
                if let difficultyInputLabel = self.childNodeWithName("difficultyInputLabel"){
                    difficultyInputLabel.position = CGPointMake(sideMargin + (difficultyInputLabel.frame.size.width/2.0), nameInputLabel.position.y - (nameInputLabel.frame.size.height/2.0) - spacing - (difficultyInputLabel.frame.size.height/2.0))
                    
                    if let segmentedControl = self.difficultyInput{
                        segmentedControl.frame = CGRectMake(sideMargin, self.frame.size.height - difficultyInputLabel.position.y + (difficultyInputLabel.frame.size.height/2.0) + spacing, self.frame.size.width - (sideMargin*2), 30.0)
                        
                        if let audioToggleLabel = self.childNodeWithName("audioToggleLabel"){
                            audioToggleLabel.position = CGPointMake(sideMargin + (audioToggleLabel.frame.size.width/2.0), difficultyInputLabel.position.y - (difficultyInputLabel.frame.size.height/2.0) - spacing - segmentedControl.frame.size.height - spacing - (audioToggleLabel.frame.size.height/2.0))
                            
                            if let audioToggle = self.audioToggle{
                                audioToggle.frame = CGRectMake(sideMargin + audioToggleLabel.frame.size.width + spacing, self.frame.size.height - audioToggleLabel.position.y - (audioToggle.frame.size.height/2.0), 120.0, 30.0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        self.updateViews()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // A touch anywhere outside of the text field cancels the edit
        if let textField = self.nameInput{
            if (textField.editing){
                textField.text = ""
                textField.endEditing(true)
            }
        }
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if let releasedNode:SKNode = self.nodeAtPoint(location){
                if (releasedNode.name == "backButton"){
                    self.nameInput?.hidden = true
                    let trans = SKTransition.crossFadeWithDuration(0.0)
                    let homeScene = MPHomeScene(size: self.size)
                    self.view?.presentScene(homeScene, transition: trans)
                }
            }
        }
    }
    
    @IBAction func indexChanged(sender:UISegmentedControl){
        NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: MP_GAME_DIFFICULTY_DEFAULTS_KEY)
    }
    
    @IBAction func audioToggled(sender:UISwitch){
        let currentSetting = NSUserDefaults.standardUserDefaults().integerForKey("MP_AUDIO_ON_DEFAULTS_KEY")
        
        if (currentSetting == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("audioOFF", object: nil)
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("audioON", object: nil)
        }
        
        NSUserDefaults.standardUserDefaults().setInteger((currentSetting+1)%2, forKey: "MP_AUDIO_ON_DEFAULTS_KEY")
    }
    
    // MARK - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Tapping the return button submits the edit
        if let text = textField.text{
            if (text != ""){
                NSUserDefaults.standardUserDefaults().setObject(text, forKey: MP_PLAYER_NAME_DEFAULTS_KEY)
                textField.attributedPlaceholder = NSAttributedString(string:text,
                                                                    attributes:[NSForegroundColorAttributeName: placeholderTextColor])
            }
        }
        
        textField.text = ""
        textField.endEditing(true)
        return true
    }
}
