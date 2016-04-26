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
    var isLocal:Bool = true
    var ranks:[SKLabelNode] = []
    var names:[SKLabelNode] = []
    var scores:[SKLabelNode] = []
    var locations:[SKLabelNode] = []
    
    let pageSize:Int = 10   // 10 high scores per page
    
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
        backButton.name = "backButton"
        backButton.fontSize = 18
        backButton.fontColor = SKColor.whiteColor()
        backButton.text = "Back"
        
        let toggleButton = SKLabelNode(fontNamed:"Chalkduster")
        toggleButton.name = "toggleButton"
        toggleButton.fontSize = 18
        toggleButton.fontColor = SKColor.whiteColor()
        toggleButton.text = "Show Global Scores"
        
        let prevButton = SKLabelNode(fontNamed:"Chalkduster")
        prevButton.name = "prevButton"
        prevButton.fontSize = 18
        prevButton.fontColor = SKColor.whiteColor()
        prevButton.text = "Prev Page"
        
        let nextButton = SKLabelNode(fontNamed:"Chalkduster")
        nextButton.name = "nextButton"
        nextButton.fontSize = 18
        nextButton.fontColor = SKColor.whiteColor()
        nextButton.text = "Next Page"
        
        let playerHeader = SKLabelNode(fontNamed: "Chalkduster")
        playerHeader.name = "playerHeader"
        playerHeader.fontSize = 12
        playerHeader.fontColor = SKColor.whiteColor()
        playerHeader.text = "Player"
        
        let scoreHeader = SKLabelNode(fontNamed: "Chalkduster")
        scoreHeader.name = "scoreHeader"
        scoreHeader.fontSize = 12
        scoreHeader.fontColor = SKColor.whiteColor()
        scoreHeader.text = "Score"
        
        let locationHeader = SKLabelNode(fontNamed: "Chalkduster")
        locationHeader.name = "locationHeader"
        locationHeader.fontSize = 12
        locationHeader.fontColor = SKColor.whiteColor()
        locationHeader.text = "Location"
        
        self.addChild(backButton)
        self.addChild(toggleButton)
        self.addChild(prevButton)
        self.addChild(nextButton)
        self.addChild(playerHeader)
        self.addChild(scoreHeader)
        self.addChild(locationHeader)
        
        for index in 1 ... pageSize{
            let rankLabel = SKLabelNode(fontNamed: "Chalkduster")
            rankLabel.fontSize = 10
            rankLabel.fontColor = SKColor.whiteColor()
            rankLabel.text = "\(index)."
            ranks.append(rankLabel)
            
            let nameLabel = SKLabelNode(fontNamed:"Chalkduster")
            nameLabel.fontSize = 10
            nameLabel.fontColor = SKColor.whiteColor()
            nameLabel.text = ""
            names.append(nameLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.fontSize = 10
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.text = ""
            scores.append(scoreLabel)
            
            let locationLabel = SKLabelNode(fontNamed:"Chalkduster")
            locationLabel.fontSize = 10
            locationLabel.fontColor = SKColor.whiteColor()
            locationLabel.text = ""
            locations.append(locationLabel)
            
            self.addChild(rankLabel)
            self.addChild(nameLabel)
            self.addChild(scoreLabel)
            self.addChild(locationLabel)
        }
        self.updateViews()
        loadScores()
    }
    
    func updateViews(){
        let sideMargin:CGFloat = 16.0
        let topMargin:CGFloat = (self.frame.size.width > self.frame.size.height ? 16.0 : 32.0)
        let spacing:CGFloat = 12.0
        let playerHeaderXPosition:CGFloat = (0.20 * self.frame.width)
        let scoreHeaderXPosition:CGFloat = (0.40 * self.frame.width)
        let locationHeaderXPosition:CGFloat = (0.75 * self.frame.width)
        
        
        if let backButton = self.childNodeWithName("backButton"){
            backButton.position = CGPointMake((backButton.frame.size.width / 2.0) + sideMargin, self.frame.size.height - topMargin - backButton.frame.size.height/2.0)
            
            if let playerHeader = self.childNodeWithName("playerHeader"){
                playerHeader.position = CGPointMake(playerHeaderXPosition, backButton.position.y - (backButton.frame.size.height/2.0) - (playerHeader.frame.size.height/2.0) - spacing)
                
                if ((self.ranks.count == 10) && (self.names.count == 10) && (self.scores.count == 10) && (self.locations.count == 10))
                {
                    let entryHeight:CGFloat = self.ranks[0].frame.size.height
                    for index in 0 ..< 10{
                        let verticalPosition:CGFloat = playerHeader.position.y - playerHeader.frame.size.height/2.0 - (spacing * CGFloat(index + 1)) - (entryHeight * (CGFloat(index)))
                        
                        self.ranks[index].position = CGPointMake(sideMargin, verticalPosition)
                        self.names[index].position = CGPointMake(playerHeaderXPosition, verticalPosition)
                        self.scores[index].position = CGPointMake(scoreHeaderXPosition, verticalPosition)
                        self.locations[index].position = CGPointMake(locationHeaderXPosition, verticalPosition)
                    }
                }
            }
            
            if let scoreHeader = self.childNodeWithName("scoreHeader"){
                scoreHeader.position = CGPointMake(scoreHeaderXPosition, backButton.position.y - (backButton.frame.size.height/2.0) - (scoreHeader.frame.size.height/2.0) - spacing)
            }
            
            if let locationHeader = self.childNodeWithName("locationHeader"){
                locationHeader.position = CGPointMake(locationHeaderXPosition, backButton.position.y - (backButton.frame.size.height/2.0) - (locationHeader.frame.size.height/2.0) - spacing)
            }
            
            if let prevButton = self.childNodeWithName("prevButton"){
                prevButton.position = CGPointMake(sideMargin + prevButton.frame.size.width/2.0, topMargin)
            }
            
            if let nextButton = self.childNodeWithName("nextButton"){
                nextButton.position = CGPointMake(self.frame.size.width - sideMargin - nextButton.frame.size.width/2.0, topMargin)
            }
        }
        
        if let toggleButton = self.childNodeWithName("toggleButton"){
            toggleButton.position = CGPointMake(self.size.width - (toggleButton.frame.size.width / 2.0) - sideMargin, self.frame.size.height - topMargin - toggleButton.frame.size.height/2.0)
        }
    }
    
    func loadScores(){
        var index:Int = 1
        for node:SKLabelNode in self.ranks{
            node.text = "\((self.pageSize * self.pageNumber) + index)"
            index += 1
        }
        
        if (self.isLocal){
            loadLocalScores()
        }else{
            loadGlobalScores()
        }
    }
    
    func loadGlobalScores(){
        self.clearScores()
        
        let query = PFQuery(className: "MPScore")
        query.orderByDescending("score")
        query.limit = self.pageSize
        query.skip = (self.pageNumber * self.pageSize)
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
                
                let firstIndex:Int = self.pageNumber * self.pageSize
                
                if sortedScores.count > firstIndex{
                    for index in firstIndex ..< min(firstIndex + self.pageSize, sortedScores.count){
                        self.names[index%10].text = sortedScores[index].playerName
                        self.scores[index%10].text = String(sortedScores[index].score)
                        self.locations[index%10].text = sortedScores[index].location
                    }
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
    
    override func didChangeSize(oldSize: CGSize) {
        // handle rotation
        self.updateViews()
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
                        toggleLabel.text = "Show Global Scores"
                        self.isLocal = true
                    }else{
                        toggleLabel.text = "Show Local Scores"
                        self.isLocal = false
                    }
                    // reset page number upon toggle
                    self.pageNumber = 0
                    self.loadScores()
                }else if (releasedNode.name == "prevButton"){
                    if (self.pageNumber > 0){
                        self.pageNumber -= 1
                        self.loadScores()
                    }
                }else if (releasedNode.name == "nextButton"){
                    self.pageNumber += 1
                    self.loadScores()
                }
            }
        }
    }
    
}
