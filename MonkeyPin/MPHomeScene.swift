//
//  MPHomeScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 3/19/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit
import Parse    // TODO: delete this import; it's only here for Milestone 1 Demo Purposes

class MPHomeScene: SKScene {
    var contentCreated:Bool = false
    var buttons:[SKSpriteNode] = []
    var heldButton:SKSpriteNode? = nil
    var isMonkeyDoneWalking = false
    
    override func didMoveToView(view: SKView) {
        if (self.contentCreated == false){
            self.createSceneContents()
            self.contentCreated = true
            
            // register to receive notifications when the user shakes the device
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleShake), name: "shake", object: nil)
        }
    }
    
    override func willMoveFromView(view: SKView) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleShake(notification: NSNotification){
        // respond to user device shake
        if (isMonkeyDoneWalking){
            if let monkeyNode = self.childNodeWithName("walkingMonkeyNode") as? SKSpriteNode{
                // walking animation
                var animation:[SKTexture] = []
                animation.append(SKTexture(imageNamed: "monkey_arms_up"))
                animation.append(SKTexture(imageNamed: "monkey_war_face"))
                animation.append(SKTexture(imageNamed: "home_monkey"))
                let action = SKAction.repeatAction(SKAction.animateWithTextures(animation, timePerFrame: 0.5), count: 2)
                monkeyNode.runAction(action)
            }
        }
    }
    
    func createSceneContents(){
        self.backgroundColor = UIColor(colorLiteralRed: 73/255.0, green: 56/255.0, blue: 41/255.0, alpha: 1.0)
        self.scaleMode = SKSceneScaleMode.AspectFit
        self.createButtons()
        for btn in self.buttons{
            self.addChild(btn)
        }
        let walkingMonkey = newWalkingMonkey()
        self.addChild(walkingMonkey)
        self.updateMonkey()
        self.addChild(newHomeScreenLogo())
        self.updateHomeLogo()
    }
    
    func newHomeScreenLogo()->SKSpriteNode{
        let homeLogo = SKSpriteNode(imageNamed: "home_logo")
        homeLogo
        homeLogo.name = "homeLogoNode"
        return homeLogo
    }
    
    func updateHomeLogo(){
        // Do this based on the monkeyNode position
        if let monkeyNode = self.childNodeWithName("walkingMonkeyNode") as? SKSpriteNode{
            if let homeNode = self.childNodeWithName("homeLogoNode") as? SKSpriteNode{
                let scaleFactor:CGFloat = (1147.0/627.0)
                let verticalSpace = self.frame.height - monkeyNode.position.y - (monkeyNode.size.height/2.0) - 16.0
                if ((verticalSpace * scaleFactor) > (self.frame.size.width - 32.0)){
                    // screen width is limiting factor for logo size
                    homeNode.size = CGSizeMake(self.frame.size.width - 32.0, (self.frame.size.width - 32.0) / scaleFactor)
                    homeNode.position = CGPointMake(CGRectGetMidX(self.frame), monkeyNode.position.y + (monkeyNode.size.height/2.0) + verticalSpace/2.0)
                }else{
                    // available height is limiting factor for logo size
                    homeNode.size = CGSizeMake(verticalSpace*scaleFactor, verticalSpace)
                    homeNode.position = CGPointMake(CGRectGetMidX(self.frame), monkeyNode.position.y + (monkeyNode.size.height/2.0) + verticalSpace/2.0)
                }
                
            }
        }
    }
    
    func newWalkingMonkey()->SKSpriteNode{
        
        let walkingMonkey = SKSpriteNode(texture: SKTexture(imageNamed: "monkey_walk_r1"), size:CGSizeMake(50, 50 * (168.0/140.0)))
        walkingMonkey.name = "walkingMonkeyNode"
        return walkingMonkey
    }
    
    func updateMonkey(){
        if let monkeyNode = self.childNodeWithName("walkingMonkeyNode") as? SKSpriteNode{
            monkeyNode.removeAllActions()
            monkeyNode.size = CGSizeMake(50, 50 * (168.0/140.0))
            self.isMonkeyDoneWalking = false
            
            // walking animation
            var walkingRightAnimation:[SKTexture] = []
            walkingRightAnimation.append(SKTexture(imageNamed: "monkey_walk_r1"))
            walkingRightAnimation.append(SKTexture(imageNamed: "monkey_walk_r2"))
            walkingRightAnimation.append(SKTexture(imageNamed: "monkey_walk_r3"))
            walkingRightAnimation.append(SKTexture(imageNamed: "monkey_walk_r4"))
            let rightWalk = SKAction.repeatActionForever(SKAction.animateWithTextures(walkingRightAnimation, timePerFrame: 0.125))
            monkeyNode.runAction(rightWalk, withKey: "rightWalk")
            
            // physical movement
            let monkeySpeed:CGFloat = 75.0
            monkeyNode.position = CGPointMake(self.buttonPosition(0).x - (self.buttonSize().width/2.0), self.buttonPosition(0).y + self.buttonSize().height/2.0 + monkeyNode.frame.size.height/2.0)
            let horizontalDistance:CGFloat = self.buttonPosition(2).x - self.buttonPosition(0).x + self.buttonSize().width
            let motion = SKAction.sequence([SKAction.scaleXTo(1.0, duration: 0.0),SKAction.moveByX(horizontalDistance, y: 0.0, duration: (Double)(horizontalDistance/monkeySpeed)), SKAction.scaleXTo(-1.0, duration: 0.0), SKAction.moveByX(-1.0 * horizontalDistance, y: 0.0, duration: (Double)(horizontalDistance/monkeySpeed)),SKAction.scaleXTo(1.0, duration: 0.0),  SKAction.moveByX(horizontalDistance/2.0, y: 0.0, duration: (Double)((horizontalDistance/2.0)/monkeySpeed))])
            
            // upon completion, stop the walking animation and make the monkey face the user
            monkeyNode.runAction(motion, completion: { () -> Void in
                monkeyNode.removeActionForKey("rightWalk")
                monkeyNode.size = CGSizeMake(monkeyNode.size.height, monkeyNode.size.height)
                monkeyNode.runAction(SKAction.setTexture(SKTexture(imageNamed: "home_monkey")))
                self.isMonkeyDoneWalking = true
            })
        }
    }
    
    func createButtons(){
        if (self.buttons.count == 0){
            let playButtonNode = SKSpriteNode(imageNamed: "play_btn")
            playButtonNode.name = "playButtonNode"
            playButtonNode.zPosition = 2.0
            self.buttons.append(playButtonNode)
            
            let scoresButtonNode = SKSpriteNode(imageNamed:"scores_btn")
            scoresButtonNode.name = "scoresButtonNode"
            scoresButtonNode.zPosition = 2.0
            self.buttons.append(scoresButtonNode)
            
            let settingsButtonNode = SKSpriteNode(imageNamed:"settings_btn")
            settingsButtonNode.name = "settingsButtonNode"
            settingsButtonNode.zPosition = 2.0
            self.buttons.append(settingsButtonNode)
            self.updateButtons()
        }
    }
    
    func updateButtons(){
        if (self.buttons.count != 0){
            for index in 0 ..< 3{
                self.buttons[index].size = self.buttonSize()
                self.buttons[index].position = self.buttonPosition(index)
            }
        }
    }
    
    func buttonSize()->CGSize{
        // Compute button height/width aspect ratio for later use
        let scaleFactor:CGFloat = (201.0/616.0)
        
        // If screen is taller than it is wide, we will stack the buttons vertically
        // otherwise, we will place the buttons in one horizontal row side by side
        if (self.frame.height >= self.frame.width){
            let btnWidth = self.frame.width * 0.7
            return CGSizeMake(btnWidth, btnWidth * scaleFactor)
        }else{
            // 16.0 spacing around 3 buttons
            let btnWidth = (self.frame.width - (16.0 * 4)) / 3.0
            return CGSizeMake(btnWidth, btnWidth * scaleFactor)
        }
    }
    
    func buttonPosition(btnIndex: Int)->CGPoint{
        if (self.frame.height >= self.frame.width){
            return self.tallScreenButtonPosition(btnIndex)
        }else{
            return self.wideScreenButtonPosition(btnIndex)
        }
    }
    
    func wideScreenButtonPosition(btnIndex:Int)->CGPoint{
        let bottomMargin:CGFloat = 16.0
        let buttonSize:CGSize = self.buttonSize()
        let interButtonSpacing:CGFloat = 16.0
        
        switch (btnIndex){
        case 0:
            return CGPointMake((buttonSize.width * 0.5) + interButtonSpacing, (buttonSize.height / 2.0) + bottomMargin)
        case 1:
            return CGPointMake(self.buttons[0].position.x + buttonSize.width + interButtonSpacing, (buttonSize.height / 2.0) + bottomMargin)
        default:
            return CGPointMake(self.buttons[1].position.x + buttonSize.width + interButtonSpacing, (buttonSize.height / 2.0) + bottomMargin)
        }
    }
    
    func tallScreenButtonPosition(btnIndex:Int)->CGPoint{
        let bottomMargin:CGFloat = 16.0
        let buttonSize:CGSize = self.buttonSize()
        let interButtonSpacing:CGFloat = 8.0
        
        switch (btnIndex){
        case 0:
            return CGPointMake(self.frame.size.width/2.0, ((buttonSize.height/2.0)*5.0) + bottomMargin + interButtonSpacing*2.0)
        case 1:
            return CGPointMake(self.frame.size.width/2.0, ((buttonSize.height/2.0)*3.0) + bottomMargin + interButtonSpacing*1.0)
        default:
            return CGPointMake(self.frame.size.width/2.0, (buttonSize.height/2.0) + bottomMargin)
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        self.updateButtons()
        self.updateMonkey()
        self.updateHomeLogo()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if let tappedNode = self.nodeAtPoint(location) as? SKSpriteNode{
                // Check if the (child) node is a button and respond if necessary
                if ((tappedNode.name == "playButtonNode") || (tappedNode.name == "scoresButtonNode") ||
                    (tappedNode.name == "settingsButtonNode")){
                    setImageForButton(tappedNode, isPressed: true)
                    self.heldButton = tappedNode
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if let releasedNode = self.nodeAtPoint(location) as? SKSpriteNode{
                // Check if the (child) node is a button and respond if necessary
                if (releasedNode.name == "playButtonNode"){
                    setImageForButton(releasedNode, isPressed: false)
                    // saveRandomScore()       // For Demo Purposes Only
                    let trans = SKTransition.crossFadeWithDuration(1.0)
                    let gameScene = MPGameScene(size:self.size)
                    self.view?.presentScene(gameScene, transition:trans)
                    print("transition to play scene!")
                }else if (releasedNode.name == "scoresButtonNode"){
                    setImageForButton(releasedNode, isPressed: false)
                    let trans = SKTransition.flipVerticalWithDuration(1.0)
                    let scoresScene = MPScoresScene(size: self.size)
                    self.view?.presentScene(scoresScene, transition: trans)
                }else if (releasedNode.name == "settingsButtonNode"){
                    setImageForButton(releasedNode, isPressed: false)
                    let trans = SKTransition.crossFadeWithDuration(0.0)
                    let settingsScene = MPSettingsScene(size: self.size)
                    self.view?.presentScene(settingsScene, transition: trans)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            // There is currently a focused button
            if let focusedButton = heldButton{
                if (touchedNode != focusedButton){
                    // restore normal image
                    setImageForButton(focusedButton, isPressed: false)
                    heldButton = nil
                }
            }else{
                // There is currently not a focused button
                if let touchedButton = touchedNode as? SKSpriteNode{
                    if touchedButton.name == "playButtonNode" {
                        setImageForButton(touchedButton, isPressed: true)
                        self.heldButton = touchedButton
                    }else if touchedButton.name == "scoresButtonNode"{
                        setImageForButton(touchedButton, isPressed: true)
                        self.heldButton = touchedButton
                    }else if touchedButton.name == "settingsButtonNode"{
                        setImageForButton(touchedButton, isPressed: true)
                        self.heldButton = touchedButton
                    }
                }
            }
        }
    }
    
    // helper function
    func setImageForButton(btn: SKSpriteNode, isPressed: Bool){
        if (isPressed){
            if (btn.name == "playButtonNode"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "play_btn_pressed")))
            }else if (btn.name == "scoresButtonNode"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "scores_btn_pressed")))
            }else if (btn.name == "settingsButtonNode"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "settings_btn_pressed")))
            }
        }else{
            if (btn.name == "playButtonNode"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "play_btn")))
            }else if (btn.name == "scoresButtonNode"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "scores_btn")))
            }else if (btn.name == "settingsButtonNode"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "settings_btn")))
            }
        }
    }
}
