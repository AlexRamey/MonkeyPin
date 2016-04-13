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
    var moneyBagCount:Int = 0
    var currentScore:Int = 0
    var playerSpeed:CGFloat = 50.0
    var ballSpeed:CGFloat = 50.0
    let HUDHeight:CGFloat = 52.0
    
    let monkeyCategory: UInt32 = 0x1 << 0
    let moneyCategory: UInt32 = 0x1 << 1
    let ballCategory: UInt32 = 0x1 << 2
    
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
        let HUD = newHUD()
        self.addChild(HUD)
        updateHUDLayout()
        
        let monkey = newMonkeyPlayer()
        self.addChild(monkey)
        
        let moneyBag = newMoneyBag()
        self.addChild(moneyBag)
        
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
        moneyBag.name = "moneybag_\(self.moneyBagCount)"
        
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
    
    func newHUD()->SKSpriteNode{
        let HUD = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(self.frame.size.width, HUDHeight))
        HUD.name = "HUD"
        
        // note: anchorPoint coordinates are percentages, not literal values
        HUD.anchorPoint = CGPointMake(0.0,1.0)
        
        for i in 0...2{
            HUD.addChild(newMonkeyLifeNodeAtIndex(i))
        }
        
        HUD.addChild(newPauseButton())
        HUD.addChild(newScoreLabel(0));
        
        return HUD
    }
    
    func newMonkeyLifeNodeAtIndex(index_in: Int)->SKSpriteNode{
        let monkeyLife = SKSpriteNode(texture:SKTexture(imageNamed: "player_monkey"))
        monkeyLife.name = "life\(index_in)"
        // note: anchorPoint coordinates are percentages, not literal values
        monkeyLife.anchorPoint = CGPointMake(0.0,1.0)
        return monkeyLife
    }
    
    func newPauseButton()->SKSpriteNode{
        let pauseButton = SKSpriteNode(texture:SKTexture(imageNamed: "pause_btn"))
        pauseButton.name = "pauseButton"
        // note: anchorPoint coordinates are percentages, not literal values
        pauseButton.anchorPoint = CGPointMake(0.0,1.0)
        return pauseButton
    }
    
    func newScoreLabel(score: Int)->SKLabelNode{
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 28.0
        scoreLabel.name = "playerScore"
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.text = String(score)
        return scoreLabel
    }
    
    func updateHUDLayout(){
        let margin:CGFloat = 22.0
        let tokenDim:CGFloat = 30.0
        let spacing:CGFloat = 8.0
        
        // verify there exists a HUD
        guard let HUD = self.childNodeWithName("HUD") as? SKSpriteNode else{
            return
        }
        
        HUD.position = CGPointMake(0.0, self.frame.height)
        HUD.size = CGSizeMake(self.frame.size.width, HUDHeight)
        
        // update the position of the score label
        if let scoreLabel = HUD.childNodeWithName("playerScore"){
            // it seems that the anchor point of an SKLabelNode is (0.0,0.0), meaning it's position
            // is defined by its lower left corner
            scoreLabel.position = CGPointMake(self.frame.width - (scoreLabel.frame.width/2.0) - margin - tokenDim - spacing, -HUDHeight)
        }
        
        // update the position of the pause button
        if let pauseBtn = HUD.childNodeWithName("pauseButton") as? SKSpriteNode{
            pauseBtn.size = CGSizeMake(tokenDim, tokenDim)
            pauseBtn.position = CGPointMake(self.frame.width - tokenDim - margin, -margin)
        }
        
        // update the position of the monkey lives
        for i in 0...2{
            let index = CGFloat(i)
            if let monkeyLife = HUD.childNodeWithName("life\(i)") as? SKSpriteNode{
                monkeyLife.size = CGSizeMake(tokenDim, tokenDim)
                monkeyLife.position = CGPointMake(margin + (index * spacing) + (tokenDim * index), -margin)
            }
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        // support for rotation
        updateHUDLayout()
    }
    
    func incrementScore(amount:Int){
        self.currentScore += amount
        
        if let HUD = self.childNodeWithName("HUD"){
            if let scoreLabel = HUD.childNodeWithName("playerScore") as? SKLabelNode{
                scoreLabel.text = String(self.currentScore)
            }
        }
    }
    
    func addBowlBall(){
        // create the ball
        let ball = SKSpriteNode(texture:SKTexture(imageNamed: "bowl_ball"), size:CGSizeMake(20.0,20.0))
        ball.name = "ball"
        
        // randomize initial position along screen edge
        let choice:UInt32 = arc4random_uniform(4)
        switch choice {
        case 0:
            // along top edge
            ball.position = CGPointMake(MPGameScene.skRand(0.0, high: self.size.width), self.size.height-HUDHeight)
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
                    let trans = SKTransition.crossFadeWithDuration(1.0)
                    let homeScene = MPHomeScene(size:self.size)
                    self.view?.presentScene(homeScene, transition:trans)
                    print("pause pressed!")
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
        self.enumerateChildNodesWithName("ball") { (node, stop) -> Void in
            if (node.position.y < 0 || node.position.y > self.frame.height ||
                node.position.x < 0 || node.position.x > self.frame.width){
                node.removeFromParent()
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
                self.incrementScore(1)
                moneyNode.removeFromParent()
            }
        }else if ((firstBody.categoryBitMask == 1) && (secondBody.categoryBitMask == 4)){
            print("GAME OVER")
        }else{
            print("another collision")
        }
    }
}
