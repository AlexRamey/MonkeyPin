//
//  MPGameScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/6/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit
import Parse

class MPGameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate, MPLocationFinderDelegate {
    let MP_PLAYER_NAME_DEFAULTS_KEY:String = "MP_PLAYER_NAME_DEFAULTS_KEY"
    
    // Scene Fields
    var contentCreated:Bool = false
    var lastTouch: CGPoint? = nil
    var heldButton:SKSpriteNode? = nil
    var doubleTapGesture:UITapGestureRecognizer? = nil
    var locationFinder:MPLocationFinder? = nil
    
    // Used to give bowl balls and money bags unique names
    var uniqueBallID:Int = 0
    var uniqueMoneyID:Int = 0
    
    // Constants
    let TANK_SPEED:CGFloat = 25.0
    let NORMAL_SPEED:CGFloat = 75.0
    var playerSpeed:CGFloat = 75.0
    var ballSpeed:CGFloat = 70.0
    let HUDHeight:CGFloat = 52.0
    let MAX_NUM_BOWL_BALLS = 4
    let MAX_NUM_MONEY_BAGS = 3
    let SURVIVOR_BONUS_INTERVAL:Double = 30.0
    
    // Collision Categories
    let monkeyCategory: UInt32 = 0x1 << 0
    let moneyCategory: UInt32 = 0x1 << 1
    let ballCategory: UInt32 = 0x1 << 2
    let pinCategory: UInt32 = 0x1 << 3
    
    // Game State
    var moneyBagCount:Int = 0
    var moneyBagScore:Int = 0
    var bowlBallCount:Int = 0
    var currentScore:Int = 0
    var livesLeft:Int = 3
    var isPausedState:Bool = false
    var isTankMode:Bool = false
    
    // Pause State Vars
    var ballVelocities:[(String, CGVector?)] = []
    
    // static functions
    static func skRand(low:CGFloat, high:CGFloat)->CGFloat{
        return skRandf() * (high - low) + low
    }
    
    static func skRandf()->CGFloat{
        return ((CGFloat)(rand())) / ((CGFloat)(RAND_MAX))
    }
    
    override func didMoveToView(view: SKView) {
        if (self.contentCreated == false){
            self.createSceneContents()
            self.contentCreated = true
            physicsWorld.contactDelegate = self
        }
        
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        self.doubleTapGesture?.numberOfTapsRequired = 2
        if let recognizer = self.doubleTapGesture{
            view.addGestureRecognizer(recognizer)
        }
    }
    
    override func willMoveFromView(view: SKView) {
        if let recognizer = self.doubleTapGesture{
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    func createSceneContents(){
        // background texture
        let background = SKSpriteNode(imageNamed: "grass_texture")
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(background)
        
        // HUD
        let HUD = newHUD()
        self.addChild(HUD)
        updateHUDLayout()
        
        // Player Monkey
        let monkey = newMonkeyPlayer()
        self.addChild(monkey)
        
        // Bowling Pin
        let bowlingPin = newBowlingPin()
        self.addChild(bowlingPin)
        
        // test money bag
        // let moneyBag = newMoneyBag()
        // self.addChild(moneyBag)
        
        // initiate bowl ball sequence
        let makeBalls = SKAction.sequence([SKAction.performSelector(#selector(addBowlBall), onTarget: self),SKAction.waitForDuration(3.0, withRange: 2.0)])
        self.runAction(SKAction.repeatActionForever(makeBalls))
        
        // initiate money bag drops
        let makeItRain = SKAction.sequence([SKAction.performSelector(#selector(addMoneyBag), onTarget: self),SKAction.waitForDuration(10.0, withRange: 5.0)])
        self.runAction(SKAction.repeatActionForever(makeItRain))
        
        // initiate surivalist score bonuses
        let youEarnedIt = SKAction.sequence([SKAction.performSelector(#selector(addSurvivorScore), onTarget: self), SKAction.waitForDuration(SURVIVOR_BONUS_INTERVAL, withRange:0.0)])
        self.runAction(SKAction.repeatActionForever(youEarnedIt))
    }
    
    func newMonkeyPlayer()->SKSpriteNode{
        let playerSize:CGSize = CGSizeMake(40.0,40.0)
        let playerMonkey = SKSpriteNode(texture: SKTexture(imageNamed: "player_monkey"), size:playerSize)
        playerMonkey.name = "player"
        playerMonkey.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        let physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "player_monkey"), size: playerSize)
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = monkeyCategory
        physicsBody.contactTestBitMask = moneyCategory | ballCategory | pinCategory
        physicsBody.collisionBitMask = 0x0
        physicsBody.usesPreciseCollisionDetection = true
        playerMonkey.physicsBody = physicsBody
        return playerMonkey
    }
    
    func newMoneyBag()->SKSpriteNode{
        let moneyBag = SKSpriteNode(texture:SKTexture(imageNamed: "money_bag"), size:CGSizeMake(30.0,30.0))
        
        let physicsBody = SKPhysicsBody(texture:SKTexture(imageNamed:"money_bag"), size:CGSizeMake(30,30))
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = moneyCategory
        physicsBody.contactTestBitMask = monkeyCategory
        physicsBody.collisionBitMask = 0x0
        physicsBody.usesPreciseCollisionDetection = true
        moneyBag.physicsBody = physicsBody
        
        if (self.isTankMode){
            physicsBody.contactTestBitMask = monkeyCategory | pinCategory
        }
        
        return moneyBag
    }
    
    func newBowlingPin()->SKSpriteNode{
        let pinSize:CGSize = CGSizeMake(20.0, 20.0 * (256.0/88.0))
        
        let bowlingPin = SKSpriteNode(texture:SKTexture(imageNamed: "bowling_pin"), size:pinSize)
        bowlingPin.name = "bowlingPin"
        bowlingPin.position = CGPointMake(CGRectGetMidX(self.frame), 380.0)
        
        let physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed:"bowling_pin"), size: pinSize)
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = pinCategory
        physicsBody.contactTestBitMask = monkeyCategory | ballCategory
        physicsBody.collisionBitMask = ballCategory
        physicsBody.usesPreciseCollisionDetection = true
        bowlingPin.physicsBody = physicsBody
        
        return bowlingPin
    }
    
    func enterTankMode(){
        if (self.isTankMode == true){
            // already in tank mode
            return
        }
        
        guard let pin = self.childNodeWithName("bowlingPin") as? SKSpriteNode else{
            return
        }
        
        guard let player = self.childNodeWithName("player") as? SKSpriteNode else{
            return
        }
        
        // Remove Pin
        pin.removeFromParent()
        
        // Enter Tank Mode
        let tankSize = CGSizeMake(40.0 * (142.0/203.0),40.0)
        player.size = tankSize
        player.runAction(SKAction.sequence([SKAction.rotateToAngle(CGFloat(M_PI), duration: 0.0), SKAction.setTexture(SKTexture(imageNamed: "tank_mode"))]))
        player.physicsBody = nil
        
        let pinBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(0.5*tankSize.width, 0.5*tankSize.height), center: CGPointMake(0.0,-0.25*tankSize.height))
        pinBody.affectedByGravity = false
        pinBody.allowsRotation = false
        pinBody.categoryBitMask = pinCategory
        pinBody.contactTestBitMask = moneyCategory | ballCategory
        pinBody.collisionBitMask = ballCategory
        pinBody.usesPreciseCollisionDetection = true
        pinBody.restitution = 1.0   // pin body doesn't lose energy when it bounces off objects
        pinBody.linearDamping = 0.0 // pin body doesn't lose energy from air resistance
        player.physicsBody = pinBody
        
        let emptyNode = SKSpriteNode(color: UIColor.clearColor(), size: tankSize)
        emptyNode.name = "emptyNode"
        emptyNode.position = player.position
        let monkeyBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(tankSize.width, (tankSize.height/2.0) - 8.0), center: CGPointMake(0.0, 0.25*tankSize.height))
        monkeyBody.affectedByGravity = false
        monkeyBody.allowsRotation = false
        monkeyBody.categoryBitMask = monkeyCategory
        monkeyBody.contactTestBitMask = moneyCategory | ballCategory
        monkeyBody.collisionBitMask = 0x0
        monkeyBody.usesPreciseCollisionDetection = true
        monkeyBody.restitution = 1.0    // monkey body doesn't lose energy when it bounces off objects
        monkeyBody.linearDamping = 0.0  // monkey body doesn't lose energy from air resistance
        emptyNode.physicsBody = monkeyBody
        
        self.addChild(emptyNode)
        
        // tanks are slow but powerful!
        self.playerSpeed = TANK_SPEED
        
        // during tank mode, money bags need to respond to pin collisions
        self.enumerateChildNodesWithName("money[0-9]") { (node, ptr) in
            node.physicsBody?.contactTestBitMask = self.monkeyCategory | self.pinCategory
        }
        
        self.isTankMode = true
    }
    
    func doubleTap(recognizer: UITapGestureRecognizer){
        self.exitTankMode()
    }
    
    func exitTankMode(){
        if (self.isTankMode == false){
            // already not in tank mode
            return
        }
        
        guard let emptyNode = self.childNodeWithName("emptyNode") as? SKSpriteNode else{
            return
        }
        
        guard let player = self.childNodeWithName("player") as? SKSpriteNode else{
            return
        }
        
        // remove empty node
        emptyNode.removeFromParent()
        
        // create fresh new monkey player at same position as current player
        // remove old player
        let monkeyPlayer = newMonkeyPlayer()
        monkeyPlayer.position = player.position
        monkeyPlayer.zRotation = player.zRotation
        player.removeFromParent()
        
        self.addChild(monkeyPlayer)
        lastTouch = nil
        
        let bowlingPin = newBowlingPin()
        
        let distance = (monkeyPlayer.size.width/2.0) + (bowlingPin.size.height/2.0)
        
        bowlingPin.position = CGPointMake(monkeyPlayer.position.x + (distance * cos(monkeyPlayer.zRotation - CGFloat(M_PI)/2.0)),monkeyPlayer.position.y + (distance * sin(player.zRotation - CGFloat(M_PI)/2.0)))
        
        self.addChild(bowlingPin)
        
        // player is fast again!
        self.playerSpeed = NORMAL_SPEED
        
        // no longer in tank mode, so money bags no longer need to care about pin collisions
        self.enumerateChildNodesWithName("money[0-9]") { (node, ptr) in
            node.physicsBody?.contactTestBitMask = self.monkeyCategory
        }
        
        self.isTankMode = false
    }
    
/*-----------------------------Heads Up Display (HUD)----------------------------*/
    
    func newHUD()->SKSpriteNode{
        let HUD = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(self.frame.size.width, HUDHeight))
        HUD.name = "HUD"
        
        // note: anchorPoint coordinates are percentages, not literal values
        HUD.anchorPoint = CGPointMake(0.0,1.0)
        
        //for i in 0...2{
            //HUD.addChild(newMonkeyLifeNodeAtIndex(i))
        //}
        HUD.addChild(newMonkeyLifeIcon())
        HUD.addChild(newLifeLabel(3))
        HUD.addChild(newMoneyBagIcon())
        HUD.addChild(newMoneyLabel(0))
        // HUD.addChild(newRoundLabel(1))
        HUD.addChild(newScoreLabel(0))
        HUD.addChild(newPauseButton())
        
        return HUD
    }
    
    func newMonkeyLifeIcon()->SKSpriteNode{
        let monkeyLife = SKSpriteNode(texture:SKTexture(imageNamed: "life_icon"))
        monkeyLife.name = "playerLifeIcon"
        // note: anchorPoint coordinates are percentages, not literal values
        monkeyLife.anchorPoint = CGPointMake(0.0,1.0)
        return monkeyLife
    }
    
    func newLifeLabel(lives: Int)->SKLabelNode{
        let lifeLabel = newHUDLabel("x\(lives)")
        lifeLabel.name = "playerLives"
        return lifeLabel
    }
    
    func newMoneyBagIcon()->SKSpriteNode{
        let moneyBag = SKSpriteNode(texture:SKTexture(imageNamed: "money_bag_icon"))
        moneyBag.name = "playerMoneyIcon"
        // note: anchorPoint coordinates are percentages, not literal values
        moneyBag.anchorPoint = CGPointMake(0.0,1.0)
        return moneyBag
    }
    
    func newMoneyLabel(money: Int)->SKLabelNode{
        let moneyLabel = newHUDLabel("x\(money)")
        moneyLabel.name = "playerMoney"
        return moneyLabel
    }
    
    func newRoundLabel(round: Int)->SKLabelNode{
        let roundLabel = newHUDLabel("Round \(round)")
        roundLabel.name = "gameRound"
        roundLabel.fontColor = UIColor.blackColor()
        return roundLabel
    }
    
    func newScoreLabel(score: Int)->SKLabelNode{
        let scoreLabel = newHUDLabel("\(score)")
        scoreLabel.name = "playerScore"
        scoreLabel.fontColor = UIColor.init(colorLiteralRed: 1.0, green: 215.0/255.0, blue: 0/0, alpha: 1.0)
        scoreLabel.fontSize = 20.0
        return scoreLabel
    }
    
    func newPauseButton()->SKSpriteNode{
        let pauseButton = SKSpriteNode(texture:SKTexture(imageNamed: "pause_btn"))
        pauseButton.name = "pauseButton"
        // note: anchorPoint coordinates are percentages, not literal values
        pauseButton.anchorPoint = CGPointMake(0.0,1.0)
        return pauseButton
    }
    
    // helper function
    func newHUDLabel(text: String)->SKLabelNode{
        let hudLabel = SKLabelNode(fontNamed:"Chalkduster")
        hudLabel.fontSize = 16.0
        hudLabel.fontColor = UIColor.whiteColor()
        hudLabel.text = text;
        return hudLabel
    }
    
    func updateHUDLayout(){
        let margin:CGFloat = 16.0
        let tokenDim:CGFloat = 25.0
        let spacing:CGFloat = 4.0
        let labelYPos:CGFloat = -margin - tokenDim
        var horizontalOffset:CGFloat = 0.0
        // verify there exists a HUD
        guard let HUD = self.childNodeWithName("HUD") as? SKSpriteNode else{
            return
        }
        
        HUD.position = CGPointMake(0.0, self.frame.height)
        HUD.size = CGSizeMake(self.frame.size.width, HUDHeight)
        
        // update the position of the monkey life icon
        if let monkeyLife = HUD.childNodeWithName("playerLifeIcon") as? SKSpriteNode{
            monkeyLife.size = CGSizeMake(tokenDim, tokenDim)
            monkeyLife.position = CGPointMake(margin,-margin)
            horizontalOffset += (margin + tokenDim + spacing)
        }
        
        // update the position of the monkey life label
        if let monkeyLives = HUD.childNodeWithName("playerLives"){
            monkeyLives.position = CGPointMake(horizontalOffset + monkeyLives.frame.width/2.0, labelYPos)
            horizontalOffset += (monkeyLives.frame.width + spacing)
        }
        
        // update the position of the money bag icon
        if let moneyBagIcon = HUD.childNodeWithName("playerMoneyIcon") as? SKSpriteNode{
            // make height proportional
            moneyBagIcon.size = CGSizeMake(tokenDim * (293.0/392.0), tokenDim)
            moneyBagIcon.position = CGPointMake(horizontalOffset, -margin)
            horizontalOffset += (moneyBagIcon.size.width + spacing)
        }
        
        // update the position of the money label
        if let moneyLabel = HUD.childNodeWithName("playerMoney"){
            moneyLabel.position = CGPointMake(horizontalOffset + moneyLabel.frame.width/2.0, labelYPos)
            horizontalOffset += (moneyLabel.frame.width + spacing)
        }
        
        // update the position of the round label
        if let roundLabel = HUD.childNodeWithName("gameRound"){
            roundLabel.position = CGPointMake(horizontalOffset + roundLabel.frame.width/2.0, labelYPos)
            horizontalOffset += (roundLabel.frame.width + spacing)
        }
        
        // update the position of the pause button
        if let pauseBtn = HUD.childNodeWithName("pauseButton") as? SKSpriteNode{
            pauseBtn.size = CGSizeMake(tokenDim, tokenDim)
            // pin to bottom left corner
            pauseBtn.position = CGPointMake(margin, -self.frame.height + margin + tokenDim)
        }
        
        // update the position of the score label
        if let scoreLabel = HUD.childNodeWithName("playerScore"){
            scoreLabel.position = CGPointMake(self.frame.width - scoreLabel.frame.width/2.0 - margin, labelYPos)
        }
    }
    
/*---------------------------------------END HUD----------------------------------*/
    
    func newPauseOverlay()->MPPauseOverlay{
        let overlay = MPPauseOverlay()
        overlay.name = "pauseOverlay"
        overlay.color = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        
        // add button holder
        let holder = SKSpriteNode(imageNamed: "pause_btn_holder")
        holder.name = "buttonHolder"
        overlay.addChild(holder)
        
        // add paused label
        let pausedLabel = SKSpriteNode(imageNamed:"paused_label")
        pausedLabel.name = "pausedLabel"
        holder.addChild(pausedLabel)
        
        // add resume button
        let resumeBtn = SKSpriteNode(imageNamed: "resume_btn")
        resumeBtn.name = "resumeButton"
        holder.addChild(resumeBtn)
        
        // add quit button
        let quitBtn = SKSpriteNode(imageNamed: "quit_btn")
        quitBtn.name = "quitButton"
        holder.addChild(quitBtn)
        
        return overlay
    }
    
    func updatePauseOverlay(){
        let holderMargin:CGFloat = 16.0
        let spacing:CGFloat = 8.0
        let holderWidth:CGFloat = 300.0
        let buttonSize:CGSize = CGSizeMake(holderWidth - holderMargin*2,(holderWidth - holderMargin*2) * (200.0/614.0))
        
        if let overlay = self.childNodeWithName("pauseOverlay") as? MPPauseOverlay{
            overlay.size = CGSizeMake(self.frame.width, self.frame.height)
            overlay.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            
            if let holder = overlay.childNodeWithName("buttonHolder") as? SKSpriteNode{
                holder.position = CGPointMake(0.0, 0.0)
                holder.size = CGSizeMake(holderWidth, holderWidth * (654.0/689.0))
                
                if let pausedLabel = holder.childNodeWithName("pausedLabel") as? SKSpriteNode{
                    pausedLabel.size = CGSizeMake(holderWidth/2.0, (holderWidth/2.0) * (92.0/366.0))
                    pausedLabel.position = CGPointMake(0.0, holder.size.height/2.0 - pausedLabel.size.height/2.0 - holderMargin)
                }
                
                if let resumeButton = holder.childNodeWithName("resumeButton") as? SKSpriteNode{
                    resumeButton.size = buttonSize
                    resumeButton.position = CGPointMake(0.0, buttonSize.height/2.0 + holderMargin - holder.size.height/2.0)
                    
                    if let quitButton = holder.childNodeWithName("quitButton") as? SKSpriteNode{
                        quitButton.size = buttonSize
                        quitButton.position = CGPointMake(0.0, resumeButton.position.y + buttonSize.height + spacing)
                    }
                }
            }
        }
    }
    
    func newGameOverOverlay()->MPGameOverOverlay{
        let overlay = MPGameOverOverlay()
        overlay.name = "newGameOverlay"
        overlay.color = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.25)
        
        // add button holder
        let holder = SKSpriteNode(imageNamed: "pause_btn_holder")
        holder.name = "buttonHolder"
        overlay.addChild(holder)
        
        // add game over label
        let gameOverLabel = SKSpriteNode(imageNamed:"game_over_label")
        gameOverLabel.name = "gameOverLabel"
        holder.addChild(gameOverLabel)
        
        // add player score label
        let finalScore = SKLabelNode(fontNamed: "Chalkduster")
        finalScore.name = "finalScore"
        finalScore.fontSize = 22.0
        finalScore.fontColor = UIColor.blackColor()
        finalScore.text = "Final Score: \(self.currentScore)"
        holder.addChild(finalScore)
        
        // add home button
        let homeBtn = SKSpriteNode(imageNamed: "game_over_home_btn")
        homeBtn.name = "homeButton"
        holder.addChild(homeBtn)
        
        return overlay
    }
    
    func updateGameOverOverlay(){
        let holderMargin:CGFloat = 16.0
        let holderWidth:CGFloat = 300.0
        let buttonSize:CGSize = CGSizeMake(holderWidth - holderMargin*2,(holderWidth - holderMargin*2) * (200.0/614.0))
        
        if let overlay = self.childNodeWithName("newGameOverlay") as? MPGameOverOverlay{
            overlay.size = CGSizeMake(self.frame.width, self.frame.height)
            overlay.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            
            if let holder = overlay.childNodeWithName("buttonHolder") as? SKSpriteNode{
                holder.position = CGPointMake(0.0, 0.0)
                holder.size = CGSizeMake(holderWidth, holderWidth * (654.0/689.0))
                
                if let gameOverLabel = holder.childNodeWithName("gameOverLabel") as? SKSpriteNode{
                    gameOverLabel.size = CGSizeMake(holderWidth/2.0, (holderWidth/2.0) * (211.0/626.0))
                    gameOverLabel.position = CGPointMake(0.0, holder.size.height/2.0 - gameOverLabel.size.height/2.0 - holderMargin)
                    
                    if let homeButton = holder.childNodeWithName("homeButton") as? SKSpriteNode{
                        homeButton.size = buttonSize
                        homeButton.position = CGPointMake(0.0, buttonSize.height/2.0 + holderMargin - holder.size.height/2.0)
                        
                        if let finalScoreLabel = holder.childNodeWithName("finalScore") as? SKLabelNode{
                            finalScoreLabel.position = CGPointMake(0.0, ((homeButton.position.y + homeButton.size.height/2.0) + (gameOverLabel.position.y - gameOverLabel.size.height/2.0))/2.0)
                        }
                    }
                }
            }
        }
    }
    
    func saveScoreAndExitGame(){
        self.quit()
    }
    
    func saveScore(location: String){
        let playerName = (NSUserDefaults.standardUserDefaults().objectForKey(MP_PLAYER_NAME_DEFAULTS_KEY) as? String) ?? "Anonymous Monkey"
        
        // save locally
        if let basePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)).first{
            if let scores = NSKeyedUnarchiver.unarchiveObjectWithFile(basePath + "/localScores") as? [MPScore]{
                // append to already saved scores
                var localScores = scores
                localScores.append(MPScore(playerName: playerName, score: self.currentScore, location:location))
                NSKeyedArchiver.archiveRootObject(localScores, toFile: basePath + "/localScores")
            }else{
                // no scores are saved yet
                var localScores:[MPScore] = []
                localScores.append(MPScore(playerName: playerName, score: self.currentScore, location:location))
                NSKeyedArchiver.archiveRootObject(localScores, toFile: basePath + "/localScores")
            }
        }
        
        // save to the cloud
        let userScore = PFObject(className: "MPScore")
        userScore["score"] = self.currentScore
        userScore["playerName"] = playerName
        userScore["location"] = location
        userScore.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Score Saved!")
        }
        
        // release this scene now that saving is complete
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            print("released")
            appDelegate.releaseGameScene()
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        // support for rotation
        updateHUDLayout()
        updatePauseOverlay()
        updateGameOverOverlay()
    }
    
    func pause(){
        // stop ball and money bag generation
        self.isPausedState = true
        
        // stop ball movement
        self.enumerateChildNodesWithName("ball[0-9]") { (ball, ptr) in
            self.ballVelocities.append((ball.name!, ball.physicsBody?.velocity))
            ball.paused = true
            ball.physicsBody?.resting = true
            print(ball.name)
        }
        
        
        // stop player movement
        if let player = self.childNodeWithName("player") as? SKSpriteNode{
            lastTouch = CGPointMake(player.position.x, player.position.y)
            self.updatePlayer()
        }
    }
    
    // called after resume button is pressed on the pause overlay
    func unpause(){
        self.isPausedState = false
        
        // restart ball movement
        self.enumerateChildNodesWithName("ball[0-9]") { (ball, ptr) in
            ball.paused = false
            for entry in self.ballVelocities{
                if (entry.0 == ball.name){
                    if let velocity = entry.1{
                        ball.physicsBody?.velocity = velocity
                    }
                }
            }
            
        }
    }
    
    // called after quit button is pressed on pause overlay
    func quit(){
        let trans = SKTransition.crossFadeWithDuration(1.0)
        let homeScene = MPHomeScene(size:self.size)
        self.view?.presentScene(homeScene, transition:trans)
    }
    
    func incrementMoneyScore(amount:Int){
        self.moneyBagScore += amount
        if let HUD = self.childNodeWithName("HUD"){
            if let moneyLabel = HUD.childNodeWithName("playerMoney") as? SKLabelNode{
                moneyLabel.text = "x\(self.moneyBagScore)"
            }
        }
    }
    
    func incrementGameScore(amount:Int){
        self.currentScore += amount
        if let HUD = self.childNodeWithName("HUD"){
            if let scoreLabel = HUD.childNodeWithName("playerScore") as? SKLabelNode{
                scoreLabel.text = String(self.currentScore)
            }
        }
    }
    
    func loseLife(){
        self.livesLeft -= 1
        if let HUD = self.childNodeWithName("HUD"){
            if let lifeLabel = HUD.childNodeWithName("playerLives") as? SKLabelNode{
                lifeLabel.text = "x\(self.livesLeft)"
            }
        }
        
        if (self.livesLeft == 0){
            // update icon to be dead monkey face and enter game over behavior
            if let HUD = self.childNodeWithName("HUD"){
                if let lifeIcon = HUD.childNodeWithName("playerLifeIcon") as? SKSpriteNode{
                    lifeIcon.texture = SKTexture(imageNamed: "dead_monkey_icon")
                }
            }
            
            // pause the action
            self.pause()
            
            // bring in the game over overlay
            let overlay = self.newGameOverOverlay()
            overlay.userInteractionEnabled = true
            self.addChild(overlay)
            self.updateGameOverOverlay()
            overlay.runAction(SKAction.fadeInWithDuration(1.0))
            
            // go ahead and try to fetch user location to save along with their high score
            // initialization kicks off find location sequence
            self.locationFinder = MPLocationFinder(delegate: self)
            
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                print("retained")
                appDelegate.retainGameScene(self)
            }
        }
    }
    
    func addBowlBall(){
        guard ((self.bowlBallCount < MAX_NUM_BOWL_BALLS) && (self.isPausedState == false)) else{
            // we're at our maximum bowl_ball count already or game is paused . . .
            return
        }
        
        // create the ball
        let ball = SKSpriteNode(texture:SKTexture(imageNamed: "bowl_ball"), size:CGSizeMake(20.0,20.0))
        ball.name = "ball\(uniqueBallID)"
        uniqueBallID = (uniqueBallID + 1) % 10
        
        // randomize initial position along screen edge
        let choice:UInt32 = arc4random_uniform(4)
        switch choice {
        case 0:
            // along top edge
            ball.position = CGPointMake(MPGameScene.skRand(0.0, high: self.size.width), self.size.height)
        case 1:
            // along right edge
            ball.position = CGPointMake(self.size.width, MPGameScene.skRand(0.0, high: self.size.height))
        case 2:
            // along bottom edge
            ball.position =  CGPointMake(MPGameScene.skRand(0.0, high: self.size.width), 0.0)
        default:
            // along left edge
            ball.position = CGPointMake(0.0, MPGameScene.skRand(0.0, high: self.size.height))
        }
        
        // make the ball spin
        ball.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI)*2, duration: 1.0)))
        
        // set up physics body
        let physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "bowl_ball"), size: CGSizeMake(20.0,20.0))
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = ballCategory
        physicsBody.contactTestBitMask = monkeyCategory | pinCategory
        physicsBody.collisionBitMask = ballCategory | pinCategory
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.restitution = 1.0   // balls don't lose energy when they bounce off objects
        physicsBody.linearDamping = 0.0 // balls don't lose energy from air resistance
        ball.physicsBody = physicsBody
        
        // set initial velocity
        let currentPosition = ball.position
        let angle = atan2(currentPosition.y - self.frame.height/2.0, currentPosition.x - self.frame.width/2.0) + CGFloat(M_PI)
        
        let velocotyX = ballSpeed * cos(angle)
        let velocityY = ballSpeed * sin(angle)
        
        let newVelocity = CGVector(dx: velocotyX, dy: velocityY)
        ball.physicsBody!.velocity = newVelocity;
        
        // add ball to scene
        self.addChild(ball)
        self.bowlBallCount += 1
    }
    
    func addMoneyBag(){
        guard ((self.moneyBagCount < MAX_NUM_MONEY_BAGS) && (self.isPausedState == false)) else{
            // we're at our maximum money_bag count already or game is paused . . .
            return
        }
        
        let moneyBag = newMoneyBag()
        moneyBag.name = "money\(uniqueMoneyID)"
        // print("new money: \(uniqueMoneyID)")
        uniqueMoneyID = (uniqueMoneyID + 1) % 10
        
        // randomize initial position
        while (true){
            moneyBag.position = CGPointMake(MPGameScene.skRand(moneyBag.size.width, high: self.size.width-moneyBag.size.width), MPGameScene.skRand(moneyBag.size.height, high: self.size.height-moneyBag.size.height))
            
            if let player = self.childNodeWithName("player") as? SKSpriteNode{
                let distance = hypotf(Float(moneyBag.position.x - player.position.x), Float(moneyBag.position.y - player.position.y))
                if distance > Float(player.size.height){
                    break
                }
            }
        }
        
        self.addChild(moneyBag)
        self.moneyBagCount += 1
        
        // print("old money: money\((uniqueMoneyID - MAX_NUM_MONEY_BAGS + 10) % 10)")
        if let oldBag = self.childNodeWithName("money\((uniqueMoneyID - MAX_NUM_MONEY_BAGS + 10) % 10)") as? SKSpriteNode{
            self.initiateMoneyExpiration(oldBag)
        }
    }
    
    func initiateMoneyExpiration(node: SKSpriteNode){
        // walking animation
        var expirationAnimation:[SKTexture] = []
        expirationAnimation.append(SKTexture(imageNamed: "money_bag"))
        expirationAnimation.append(SKTexture(imageNamed: "transparent"))
        let expiration = SKAction.repeatAction(SKAction.animateWithTextures(expirationAnimation, timePerFrame: 0.0625), count: 32)
        node.runAction(expiration) { 
            node.removeFromParent()
            self.moneyBagCount -= 1
        }
    }
    
    func addSurvivorScore(){
        // 50 pts for survivor bonus every SURVIVOR_BONUS_INTERVAL seconds
        if (!self.isPausedState){
            self.incrementGameScore(50)
        }
    }
    
    
    // MARK: MPLocationFinderDelegate Methods
    func locationFinderDidFail(locationFinder: MPLocationFinder, isPermissionIssue issue: Bool) {
        if (issue){
            print("permission issue finder failed")
        }else{
            print("finder failed, not permission issue!")
        }
        self.saveScore("")
    }
    
    func locationFinder(locationFinder: MPLocationFinder, didFindLocation location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let _ = error{
                print("failed to geocode")
                self.saveScore("")
            }else if let results = placemarks{
                if results.count > 0{
                    print(results.first?.addressDictionary)
                    print(MPLocationFinder.leaderboardEntryForPlacemark(results[0]))
                    self.saveScore(MPLocationFinder.leaderboardEntryForPlacemark(results[0]))
                }else{
                    print("empty result")
                    self.saveScore("")
                }
            }else{
                print("should never happen")
                self.saveScore("")
            }
        }
    }
    
    // MARK: Touch Handling
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch:AnyObject in touches{
            let location = touch.locationInNode(self)
            if let tappedNode = self.nodeAtPoint(location) as? SKSpriteNode{
                if tappedNode.name == "pauseButton"{
                    tappedNode.runAction(SKAction.setTexture(SKTexture(imageNamed: "pause_btn_pressed")))
                    self.heldButton = tappedNode
                    return
                }
            }
        }
        
        handleTouches(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            // There is currently a focused button
            if let focusedButton = heldButton{
                if (touchedNode != focusedButton){
                    // restore normal image
                    focusedButton.runAction(SKAction.setTexture(SKTexture(imageNamed: "pause_btn")))
                    heldButton = nil
                }else{
                    // currently a focused button and the touches are still inside it
                    return
                }
            }else{
                // There is currently not a focused button
                if let touchedButton = touchedNode as? SKSpriteNode{
                    if touchedButton.name == "pauseButton" {
                        touchedButton.runAction(SKAction.setTexture(SKTexture(imageNamed: "pause_btn_pressed")))
                        self.heldButton = touchedButton
                        return
                    }
                }
            }
        }
        
        handleTouches(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if let releasedNode = self.nodeAtPoint(location) as? SKSpriteNode{
                // Check if the (child) node is a button and respond if necessary
                if (releasedNode.name == "pauseButton"){
                    releasedNode.runAction(SKAction.setTexture(SKTexture(imageNamed: "pause_btn")))
                    
                    self.pause()
                    let overlay = self.newPauseOverlay()
                    overlay.userInteractionEnabled = true
                    self.addChild(overlay)
                    self.updatePauseOverlay()
                    overlay.runAction(SKAction.fadeInWithDuration(1.0))
                    return
                }
            }
        }
        
        handleTouches(touches)
    }
    
    private func handleTouches(touches: Set<UITouch>) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            lastTouch = touchLocation
        }
    }
    
    // MARK - Updates
    override func didSimulatePhysics() {
        // clean up off-screen nodes . . .
        self.enumerateChildNodesWithName("ball[0-9]") { (node, stop) -> Void in
            if (node.position.y < 0 || node.position.y > self.frame.height ||
                node.position.x < 0 || node.position.x > self.frame.width){
                node.removeFromParent()
                self.bowlBallCount -= 1
            }
        }
        if let _ = self.childNodeWithName("player") as? SKSpriteNode {
            updatePlayer()
        }
    }
    
    // Determines if the player's position should be updated
    private func shouldMove(currentPosition currentPosition: CGPoint, touchPosition: CGPoint) -> Bool {
        guard let player = self.childNodeWithName("player") as? SKSpriteNode else{
            return false
        }
        
        return abs(currentPosition.x - touchPosition.x) > player.frame.width / 2 ||
                abs(currentPosition.y - touchPosition.y) > player.frame.height/2
        
    }
    
    // Updates the player's position by moving towards the last touch made
    func updatePlayer() {
        guard let player = self.childNodeWithName("player") as? SKSpriteNode else{
            return
        }
        
        if let emptyNode = self.childNodeWithName("emptyNode") as? SKSpriteNode{
            // during tank mode, keep these sprites directly on top of one another
            emptyNode.position = player.position
        }
        
        if let touch = lastTouch {
            let currentPosition = player.position
            if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
                
                let angle = atan2(currentPosition.y - touch.y, currentPosition.x - touch.x) + CGFloat(M_PI)
                let rotateAction = SKAction.rotateToAngle(angle + CGFloat(M_PI*0.5), duration: 0)
                
                player.runAction(rotateAction)
                
                let velocotyX = playerSpeed * cos(angle)
                let velocityY = playerSpeed * sin(angle)
                
                let newVelocity = CGVector(dx: velocotyX, dy: velocityY)
                player.physicsBody!.velocity = newVelocity
                
                if let emptyNode = self.childNodeWithName("emptyNode") as? SKSpriteNode{
                    // during tank mode, keep these sprites directly on top of one another
                    emptyNode.runAction(rotateAction)
                    emptyNode.physicsBody!.velocity = newVelocity
                }
                
            }else{
                player.physicsBody!.resting = true
                if let emptyNode = self.childNodeWithName("emptyNode") as? SKSpriteNode{
                    // during tank mode, keep these sprites directly on top of one another
                    emptyNode.physicsBody!.resting = true
                }
            }
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask == 1) && (secondBody.categoryBitMask == 2)){
            if let moneyNode = secondBody.node{
                self.collectMoney(moneyNode)
            }
        }else if ((firstBody.categoryBitMask == 1) && (secondBody.categoryBitMask == 4)){
            if let ballNode = secondBody.node{
                self.addBrokenPieces(ballNode.position)
                self.loseLife()
                ballNode.physicsBody = nil
                ballNode.removeFromParent()
                self.bowlBallCount -= 1
            }
        }else if ((firstBody.categoryBitMask == 1) && (secondBody.categoryBitMask == 8)){
            print("Monkey AND PIN")
            enterTankMode()
        }else if ((firstBody.categoryBitMask == 4) && (secondBody.categoryBitMask == 8)){
            print("BALL AND PIN")
        }else if ((firstBody.categoryBitMask == 2) && (secondBody.categoryBitMask == 8)){
            if let moneyNode = firstBody.node{
                self.collectMoney(moneyNode)
            }
        }else{
            print("another collision: \(firstBody.categoryBitMask)w/\(secondBody.categoryBitMask)")
        }
    }
    
    func addBrokenPieces(position:CGPoint){
        let rubble = SKSpriteNode(texture:SKTexture(imageNamed: "broken_ball"), size:CGSizeMake(15.0,15.0))
        rubble.position = position
        self.addChild(rubble)
        
        rubble.runAction(SKAction.waitForDuration(5.0)) { 
            rubble.removeFromParent()
        }
    }
    
    // helper - called after money contacts player or (in tank mode only) a pin
    func collectMoney(moneyBag: SKNode){
        self.incrementMoneyScore(1)
        moneyBag.physicsBody = nil
        moneyBag.removeFromParent()
        self.moneyBagCount -= 1
    }
}
