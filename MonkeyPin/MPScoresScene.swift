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
    var locations:[SKLabelNode] = []
    
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
        
        let toggleButton = SKLabelNode(fontNamed:"Chalkduster")
        toggleButton.fontSize = 16
        toggleButton.name = "toggleButton"
        toggleButton.fontColor = SKColor.whiteColor()
        toggleButton.text = "Show Local Scores"
        toggleButton.position = CGPointMake(self.size.width - (toggleButton.frame.size.width / 2.0) - 16.0, self.frame.size.height - 66.0)
        
        let playerHeader = SKLabelNode(fontNamed: "Chalkduster")
        playerHeader.fontSize = 12
        playerHeader.fontColor = SKColor.whiteColor()
        playerHeader.text = "Player"
        playerHeader.position = CGPointMake(0.20*self.frame.width, backButton.position.y - (backButton.frame.size.height/2.0) - (playerHeader.frame.size.height/2.0) - 16.0)
        
        let scoreHeader = SKLabelNode(fontNamed: "Chalkduster")
        scoreHeader.fontSize = 12
        scoreHeader.fontColor = SKColor.whiteColor()
        scoreHeader.text = "Score"
        scoreHeader.position = CGPointMake(0.40*self.frame.width, backButton.position.y - (backButton.frame.size.height/2.0) - (scoreHeader.frame.size.height/2.0) - 16.0)
        
        let locationHeader = SKLabelNode(fontNamed: "Chalkduster")
        locationHeader.fontSize = 12
        locationHeader.fontColor = SKColor.whiteColor()
        locationHeader.text = "Location"
        locationHeader.position = CGPointMake(0.75*self.frame.width, backButton.position.y - (backButton.frame.size.height/2.0) - (scoreHeader.frame.size.height/2.0) - 16.0)
        
        self.addChild(backButton)
        self.addChild(toggleButton)
        self.addChild(playerHeader)
        self.addChild(scoreHeader)
        self.addChild(locationHeader)
        
        for index in 1 ..< 11{
            let verticalPosition:CGFloat = scoreHeader.position.y - (30.0 * CGFloat(index))
            
            let rankLabel = SKLabelNode(fontNamed: "Chalkduster")
            rankLabel.fontSize = 10
            rankLabel.fontColor = SKColor.whiteColor()
            rankLabel.text = "\(index)."
            rankLabel.position = CGPointMake(18.0, verticalPosition)
            ranks.append(rankLabel)
            
            let nameLabel = SKLabelNode(fontNamed:"Chalkduster")
            nameLabel.fontSize = 10
            nameLabel.fontColor = SKColor.whiteColor()
            nameLabel.text = ""
            nameLabel.position = CGPointMake(playerHeader.position.x, verticalPosition)
            names.append(nameLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.fontSize = 10
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.text = ""
            scoreLabel.position = CGPointMake(scoreHeader.position.x, verticalPosition)
            scores.append(scoreLabel)
            
            let locationLabel = SKLabelNode(fontNamed:"Chalkduster")
            locationLabel.fontSize = 10
            locationLabel.fontColor = SKColor.whiteColor()
            locationLabel.text = ""
            locationLabel.position = CGPointMake(locationHeader.position.x, verticalPosition)
            locations.append(locationLabel)
            
            self.addChild(rankLabel)
            self.addChild(nameLabel)
            self.addChild(scoreLabel)
            self.addChild(locationLabel)
        }
        
        loadGlobalScores()
    }
    
    func loadGlobalScores(){
        self.clearScores()
        
        let query = PFQuery(className: "MPScore")
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
                    self.locations[index].text = object["location"] as? String
                }
            }
        }
    }
    
    func loadLocalScores(){
        self.clearScores()
        
        if let basePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)).first{
            if let scores = NSKeyedUnarchiver.unarchiveObjectWithFile(basePath + "/localScores") as? [MPScore]{
                let sortedScores = scores.sort({ (score1, score2) -> Bool in
                    if (score1.score > score2.score){
                        return true
                    }
                    return false
                })
                
                for index in 0 ..< min(10, sortedScores.count){
                    self.names[index].text = sortedScores[index].playerName
                    self.scores[index].text = String(sortedScores[index].score)
                    self.locations[index].text = String(sortedScores[index].location)
                }
            }
        }
        
    }
    
    // helper func to clear scores
    func clearScores(){
        for name:SKLabelNode in names{
            name.text = ""
        }
        
        for score:SKLabelNode in scores{
            score.text = ""
        }
        
        for location:SKLabelNode in locations{
            location.text = ""
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
                }else if (releasedNode.name == "toggleButton"){
                    let toggleLabel = releasedNode as! SKLabelNode
                    if toggleLabel.text == "Show Local Scores"{
                        toggleLabel.text = "Show All Scores"
                        self.loadLocalScores()
                    }else{
                        toggleLabel.text = "Show Local Scores"
                        self.loadGlobalScores()
                    }
                }
            }
        }
    }
    
    
}
