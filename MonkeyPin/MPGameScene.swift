//
//  MPGameScene.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/6/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import SpriteKit

class MPGameScene: SKScene, SKPhysicsContactDelegate {
    var contentCreated:Bool = false
    var lastTouch: CGPoint? = nil
    var heldButton:SKSpriteNode? = nil
    var uniqueBallID:Int = 0
    
    // Constants
    var playerSpeed:CGFloat = 75.0
    var ballSpeed:CGFloat = 70.0
    let HUDHeight:CGFloat = 52.0
    let MAX_NUM_BOWL_BALLS = 5
    
    // Collision Categories
    let monkeyCategory: UInt32 = 0x1 << 0
    let moneyCategory: UInt32 = 0x1 << 1
    let ballCategory: UInt32 = 0x1 << 2
    
    // Game State
    var moneyBagCount:Int = 0
    var bowlBallCount:Int = 0
    var currentScore:Int = 0
    var isPausedState:Bool = false
    
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
        
        // test money bag
        let moneyBag = newMoneyBag()
        self.addChild(moneyBag)
        
        // initiate bowl ball sequence
        let makeBalls = SKAction.sequence([SKAction.performSelector("addBowlBall", onTarget: self),SKAction.waitForDuration(5.0, withRange: 2.0)])
        self.runAction(SKAction.repeatActionForever(makeBalls))
    }
    
    func newMonkeyPlayer()->SKSpriteNode{
        let playerMonkey = SKSpriteNode(texture: SKTexture(imageNamed: "player_monkey"), size:CGSizeMake(50, 50))
        playerMonkey.name = "player"
        playerMonkey.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        let physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "player_monkey"), size: CGSizeMake(50,50))
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = monkeyCategory
        physicsBody.contactTestBitMask = moneyCategory | ballCategory
        physicsBody.collisionBitMask = monkeyCategory
        physicsBody.usesPreciseCollisionDetection = true
        playerMonkey.physicsBody = physicsBody
        return playerMonkey
    }
    
    func newMoneyBag()->SKSpriteNode{
        let moneyBag = SKSpriteNode(texture:SKTexture(imageNamed: "money_bag"), size:CGSizeMake(30,30))
        
        moneyBag.position = CGPointMake(CGRectGetMidX(self.frame), 100.0)
        let physicsBody = SKPhysicsBody(texture:SKTexture(imageNamed:"money_bag"), size:CGSizeMake(30,30))
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = moneyCategory
        physicsBody.contactTestBitMask = monkeyCategory
        physicsBody.collisionBitMask = moneyCategory
        physicsBody.usesPreciseCollisionDetection = true
        moneyBag.physicsBody = physicsBody
        
        return moneyBag
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
    
    override func didChangeSize(oldSize: CGSize) {
        // support for rotation
        updateHUDLayout()
        updatePauseOverlay()
    }
    
    func pause(){
        // stop ball generation
        self.isPausedState = true
        
        // stop ball movement
        self.enumerateChildNodesWithName("ball[0-99]") { (ball, ptr) in
            self.ballVelocities.append((ball.name!, ball.physicsBody?.velocity))
            ball.paused = true
            ball.physicsBody?.resting = true
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
        self.enumerateChildNodesWithName("ball[0-99]") { (ball, ptr) in
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
    
    func incrementScore(amount:Int){
        self.currentScore += amount
        
        if let HUD = self.childNodeWithName("HUD"){
            if let scoreLabel = HUD.childNodeWithName("playerScore") as? SKLabelNode{
                scoreLabel.text = String(self.currentScore)
            }
        }
    }
    
    func incrementMoney(amount:Int){
        self.moneyBagCount += amount
        
        if let HUD = self.childNodeWithName("HUD"){
            if let moneyLabel = HUD.childNodeWithName("playerMoney") as? SKLabelNode{
                moneyLabel.text = "x\(self.moneyBagCount)"
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
        uniqueBallID = (uniqueBallID + 1) % 100
        
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
        physicsBody.contactTestBitMask = monkeyCategory
        physicsBody.collisionBitMask = ballCategory
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
        self.enumerateChildNodesWithName("ball[0-99]") { (node, stop) -> Void in
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
        
        if let touch = lastTouch {
            let currentPosition = player.position
            if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
                
                let angle = atan2(currentPosition.y - touch.y, currentPosition.x - touch.x) + CGFloat(M_PI)
                let rotateAction = SKAction.rotateToAngle(angle + CGFloat(M_PI*0.5), duration: 0)
                
                player.runAction(rotateAction)
                
                let velocotyX = playerSpeed * cos(angle)
                let velocityY = playerSpeed * sin(angle)
                
                let newVelocity = CGVector(dx: velocotyX, dy: velocityY)
                player.physicsBody!.velocity = newVelocity;
            } else {
                player.physicsBody!.resting = true
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
                self.incrementMoney(1)
                moneyNode.removeFromParent()
            }
        }else if ((firstBody.categoryBitMask == 1) && (secondBody.categoryBitMask == 4)){
            print("GAME OVER")
        }else{
            print("another collision")
        }
    }
}
