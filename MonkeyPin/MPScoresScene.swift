//
//  MPScoresScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/4/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit
import Parse

class MPScoresScene: SKScene {
    var contentCreated:Bool = false
    var pageNumber:Int = 0
    var ranks:[SKLabelNode] = []
    var names:[SKLabelNode] = []
    var scores:[SKLabelNode] = []
    
    override func didMoveToView(view: SKView) {
        if (self.contentCreated == false){
            self.createSceneContents()
            self.contentCreated = true
        }
    }
    
    func createSceneContents(){
        self.backgroundColor = UIColor(colorLiteralRed: 73/255.0, green: 56/255.0, blue: 41/255.0, alpha: 1.0)
        self.scaleMode = SKSceneScaleMode.AspectFit
        
        let backButton = SKLabelNode(fontNamed:"Chalkduster")
        backButton.fontSize = 24
        backButton.name = "backButton"
        backButton.fontColor = SKColor.whiteColor()
        backButton.text = "Back"
        backButton.position = CGPointMake((backButton.frame.size.width / 2.0) + 16.0, self.frame.size.height - 66.0)
        
        let playerHeader = SKLabelNode(fontNamed: "Chalkduster")
        playerHeader.fontSize = 18
        playerHeader.fontColor = SKColor.whiteColor()
        playerHeader.text = "Player"
        playerHeader.position = CGPointMake(0.40*self.frame.width, backButton.position.y - (backButton.frame.size.height/2.0) - (playerHeader.frame.size.height/2.0) - 16.0)
        
        let scoreHeader = SKLabelNode(fontNamed: "Chalkduster")
        scoreHeader.fontSize = 18
        scoreHeader.fontColor = SKColor.whiteColor()
        scoreHeader.text = "Score"
        scoreHeader.position = CGPointMake(0.80*self.frame.width, backButton.position.y - (backButton.frame.size.height/2.0) - (scoreHeader.frame.size.height/2.0) - 16.0)
        
        self.addChild(backButton)
        self.addChild(playerHeader)
        self.addChild(scoreHeader)
        
        for index in 1 ..< 11{
            let verticalPosition:CGFloat = scoreHeader.position.y - (30.0 * CGFloat(index))
            
            let rankLabel = SKLabelNode(fontNamed: "Chalkduster")
            rankLabel.fontSize = 18
            rankLabel.fontColor = SKColor.whiteColor()
            rankLabel.text = "\(index)."
            rankLabel.position = CGPointMake(18.0, verticalPosition)
            ranks.append(rankLabel)
            
            let nameLabel = SKLabelNode(fontNamed:"Chalkduster")
            nameLabel.fontSize = 18
            nameLabel.fontColor = SKColor.whiteColor()
            nameLabel.text = ""
            nameLabel.position = CGPointMake(playerHeader.position.x, verticalPosition)
            names.append(nameLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.fontSize = 18
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.text = ""
            scoreLabel.position = CGPointMake(scoreHeader.position.x, verticalPosition)
            scores.append(scoreLabel)
            
            self.addChild(rankLabel)
            self.addChild(nameLabel)
            self.addChild(scoreLabel)
        }
        
        loadScores()
    }
    
    func loadScores(){
        let query = PFQuery(className: "GameScore")
        query.orderByDescending("score")
        query.limit = 10
        query.skip = self.pageNumber
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) in
            if (error != nil){
                print(error)
            }else if let result = objects{
                print(result)
                for index in 0 ..< result.count {
                    let object:PFObject = result[index]
                    self.names[index].text = object["playerName"] as? String
                    if let num = object["score"] as? NSNumber{
                        self.scores[index].text = num.stringValue
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if let releasedNode:SKNode = self.nodeAtPoint(location){
                if (releasedNode.name == "backButton"){
                    let trans = SKTransition.flipVerticalWithDuration(1.0)
                    let homeScene = MPHomeScene(size: self.size)
                    self.view?.presentScene(homeScene, transition: trans)
                }
            }
        }
    }
    
    
}
