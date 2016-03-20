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
    
    override func didMoveToView(view: SKView) {
        if (self.contentCreated == false){
            self.createSceneContents()
            self.contentCreated = true
        }
    }
    
    func createSceneContents(){
        self.backgroundColor = SKColor.whiteColor()
        self.scaleMode = SKSceneScaleMode.AspectFit
        self.addChild(newPlayButtonNode())
    }
    
    func newPlayButtonNode()->SKSpriteNode{
        let playButtonNode = SKSpriteNode(imageNamed: "play_btn")
        
        playButtonNode.size = self.buttonSize()
        playButtonNode.name = "playButtonNode"
        playButtonNode.position = CGPointMake(self.frame.size.width/2.0, playButtonNode.size.height/2.0)
        playButtonNode.zPosition = 2.0
        return playButtonNode
    }
    
    func buttonSize()->CGSize{
        // implement logic to leave minimal space for monkey image at top
        return CGSizeMake(self.frame.width * 0.8, self.frame.width * 0.8 * (201.0/616.0))
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
            }
        }
    }
}
