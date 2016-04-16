//
//  MPPauseOverlayScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/16/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit
import UIKit

class MPPauseOverlay: SKSpriteNode {
    var heldButton:SKSpriteNode? = nil
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if let tappedNode = self.nodeAtPoint(location) as? SKSpriteNode{
                // Check if the (child) node is a button and respond if necessary
                if ((tappedNode.name == "resumeButton") || (tappedNode.name == "quitButton")){
                    setImageForButton(tappedNode, isPressed: true)
                    self.heldButton = tappedNode
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
                    if ((touchedButton.name=="quitButton") ||
                        (touchedButton.name=="resumeButton")) {
                        setImageForButton(touchedButton, isPressed: true)
                        self.heldButton = touchedButton
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        if let parent = self.parent as? MPGameScene{
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                if let releasedNode = self.nodeAtPoint(location) as? SKSpriteNode{
                    if (releasedNode.name == "resumeButton"){
                        parent.unpause()
                        self.removeFromParent()
                    }else if releasedNode.name == "quitButton" {
                        parent.quit()
                    }
                }
            }
        }
    }
    
    // helper function
    func setImageForButton(btn: SKSpriteNode, isPressed: Bool){
        if (isPressed){
            if (btn.name == "resumeButton"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "resume_btn_pressed")))
            }else if (btn.name == "quitButton"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "quit_btn_pressed")))
            }
        }else{
            if (btn.name == "resumeButton"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "resume_btn")))
            }else if (btn.name == "quitButton"){
                btn.runAction(SKAction.setTexture(SKTexture(imageNamed: "quit_btn")))
            }
        }
    }
    
    
}
