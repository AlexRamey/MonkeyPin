//
//  MPHomeScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 3/19/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit

class MPHomeScene: SKScene {
    var contentCreated:Bool = false
    var buttons:[SKSpriteNode] = []
    
    override func didMoveToView(view: SKView) {
        if (self.contentCreated == false){
            self.createSceneContents()
            self.contentCreated = true
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
            monkeyNode.position = CGPointMake(32.0, self.buttonPosition(0).y + self.buttonSize().height/2.0 + monkeyNode.frame.size.height/2.0)
            let horizontalDistance:CGFloat = self.frame.width - 64.0
            let motion = SKAction.sequence([SKAction.moveByX(horizontalDistance, y: 0.0, duration: (Double)(horizontalDistance/monkeySpeed)), SKAction.scaleXTo(-1.0, duration: 0.0), SKAction.moveByX(-1.0 * horizontalDistance, y: 0.0, duration: (Double)(horizontalDistance/monkeySpeed)),SKAction.scaleXTo(1.0, duration: 0.0),  SKAction.moveByX(horizontalDistance/2.0, y: 0.0, duration: (Double)((horizontalDistance/2.0)/monkeySpeed))])
            
            // upon completion, stop the walking animation and make the monkey face the user
            monkeyNode.runAction(motion, completion: { () -> Void in
                monkeyNode.removeActionForKey("rightWalk")
                monkeyNode.size = CGSizeMake(monkeyNode.size.height, monkeyNode.size.height)
                monkeyNode.runAction(SKAction.setTexture(SKTexture(imageNamed: "home_monkey")))
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
            for var index = 0; index < 3; ++index{
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
            // Get location of the tap in this node
            let location = touch.locationInNode(self)
            // Get the child node at this location (or this node if there is no child)
            let tappedNode = self.nodeAtPoint(location)
            // Check if the (child) node is a button and respond if necessary
            if tappedNode.name == "playButtonNode" {
                print("play tapped!")
            }else if tappedNode.name == "scoresButtonNode"{
                print("scores tapped!")
            }else if tappedNode.name == "settingsButtonNode"{
                print("settings tapped!")
            }
        }
    }
}