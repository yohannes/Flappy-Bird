//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Yohannes Wijaya on 8/11/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Local Properties
    
    var background: SKSpriteNode!
    var bird: SKSpriteNode!
    var ground: SKNode!
    var skyLimit: SKNode!
    var pipe: SKSpriteNode!
    var labelHolder = SKSpriteNode()
    
    let skyGroup: UInt32 = 1
    let birdGroup: UInt32 = 2
    let physicalObjectGroup: UInt32 = 3
    let invisibleVerticalGapBetweenPipesGroup: UInt32 = 0
    
    var isGameOver = false
    let backgroundAndPipesGroupingNode = SKNode()
    
    var gameScore = 0
    var gameScoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    
    // MARK: - Methods Override
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -2.0) // <-- default is (0.0, -9.8)
        self.addChild(self.backgroundAndPipesGroupingNode)
        self.addChild(self.labelHolder)
        
        // **********************
        // ***** MARK: Background
        // **********************
        
        self.generateBackground()
        
        // **********************
        // MARK: Game Score Label
        // **********************
        
        self.gameScoreLabel = SKLabelNode()
        self.gameScoreLabel.fontName = "Avenir"
        self.gameScoreLabel.fontSize = 65
        self.gameScoreLabel.text = "0"
        self.gameScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        self.addChild(self.gameScoreLabel)
        
        // **********************
        // *********** MARK: Bird
        // **********************
        
        let birdTexture1 = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        let animateBirdTextures = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        let repeatAnimateBirdTexturesForever = SKAction.repeatActionForever(animateBirdTextures)
        
        self.bird = SKSpriteNode(texture: birdTexture1)
        self.bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.bird.runAction(repeatAnimateBirdTexturesForever)
        
        // applying physics (i.e., physics, inertia) to birdie
        self.bird.physicsBody = SKPhysicsBody(circleOfRadius: self.bird.size.height / 2)
        self.bird.physicsBody!.dynamic = true
        self.bird.physicsBody!.allowsRotation = false // <-- disallow the bird to spin
        self.bird.physicsBody!.categoryBitMask = self.birdGroup
//        self.bird.physicsBody!.collisionBitMask = self.birdGroup
        self.bird.physicsBody!.contactTestBitMask = self.physicalObjectGroup
        self.bird.zPosition = 1 // <-- making it the foremost sprite in the view stack
        self.addChild(self.bird)
        
        // **********************
        // ********* MARK: Ground
        // **********************
        
        self.ground = SKNode()
        self.ground.position = CGPoint(x: 0, y: 0)
        self.ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: 1))
        self.ground.physicsBody!.dynamic = false // <-- making it immune against gravity
        self.ground.physicsBody!.categoryBitMask = self.physicalObjectGroup
        self.addChild(self.ground)
        
        // **********************
        // ************ MARK: Sky
        // **********************
        
        self.skyLimit = SKNode()
        self.skyLimit.position = CGPoint(x: 0, y: self.frame.size.height)
        self.skyLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: 1))
        self.skyLimit.physicsBody!.dynamic = false
        self.skyLimit.physicsBody!.categoryBitMask = self.skyGroup
        self.addChild(self.skyLimit)
        
        // **********************
        // ********** MARK: Pipes
        // **********************
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "generatePipes", userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !self.isGameOver {
            self.bird.physicsBody!.velocity = CGVectorMake(0, 0) // <-- set the bird's velocity to 0 so it doesn't fly off the screen when tapped
            self.bird.physicsBody!.applyImpulse(CGVectorMake(0, 30)) // <-- apply momentum vertically to make the bird "jump"
        }
        else {
            
            // **********************
            // *** MARK: Restart Game
            // **********************
            
            self.gameScore = 0
            self.gameScoreLabel.text = "0"
            self.backgroundAndPipesGroupingNode.removeAllChildren()
            self.generateBackground()
            self.bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidX(self.frame))
            self.bird.physicsBody!.velocity = CGVectorMake(0, 0)
            self.labelHolder.removeAllChildren()
            self.isGameOver = false
            self.backgroundAndPipesGroupingNode.speed = 1
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask  == self.invisibleVerticalGapBetweenPipesGroup || contact.bodyB.categoryBitMask == self.invisibleVerticalGapBetweenPipesGroup {
            ++gameScore
            self.gameScoreLabel.text = "\(self.gameScore)"
        }
        else if contact.bodyA.categoryBitMask == self.skyGroup || contact.bodyB.categoryBitMask == self.skyGroup {
            return
        }
        else {
            self.isGameOver = true
            self.bird.speed = 0
            self.backgroundAndPipesGroupingNode.speed = 0
            
            // **********************
            // MARK: Game Over Label
            // **********************
            
            self.gameOverLabel = SKLabelNode()
            self.gameOverLabel.fontName = "Avenir"
            self.gameOverLabel.fontSize = 30
            self.gameOverLabel.text = "Game Over! Tap to play again."
            self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            self.labelHolder.addChild(self.gameOverLabel)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: - Custom Methods
    
    func generateBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        let animateBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        let animateBackgroundReplacement = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        let repeatAnimateBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([animateBackground, animateBackgroundReplacement]))
        
        for index in 0...2 {
            self.background = SKSpriteNode(texture: backgroundTexture)
            self.background.position = CGPoint(x: backgroundTexture.size().width / 2 + backgroundTexture.size().width * CGFloat(index), y: CGRectGetMidY(self.frame))
            self.background.size.height = self.frame.height
            self.background.runAction(repeatAnimateBackgroundForever)
            self.backgroundAndPipesGroupingNode.addChild(self.background)
        }
    }
    
    func generatePipes() {
        let verticalGapSizeBetweenPipes: CGFloat = self.bird.size.height * 4
        // each pipe can move (max) up / down 1/4 of the screen's height, which leaves 1/2 of screen's height remaining for gap (1/4 + 1/4 + 1/2 = 1)
        let rangeOfPipesVerticalMovement = arc4random() % UInt32(self.frame.size.height / 2) // <-- between 0 and 1/2 of the screen's height
        let pipesVerticalMovementOffset = CGFloat(rangeOfPipesVerticalMovement) - self.frame.size.height / 4 // shifting it down by another 1/4 of the screen's height if needed. meaning it can have a max value of a 1/4 screen's height up & a min value of a 1/4 screen's height down.
        
        let animatePipe = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100)) // <-- 100pxl/sec
        let removePipes = SKAction.removeFromParent()
        let animateAndRemovePipes = SKAction.sequence([animatePipe, removePipes])
        
        self.setupEachPipe("pipe1", verticalGapSizeBetweenPipes: verticalGapSizeBetweenPipes, pipesVerticalMovementOffset: pipesVerticalMovementOffset, animateAndRemovePipes: animateAndRemovePipes)
        self.setupEachPipe("pipe2", verticalGapSizeBetweenPipes: verticalGapSizeBetweenPipes, pipesVerticalMovementOffset: pipesVerticalMovementOffset, animateAndRemovePipes: animateAndRemovePipes)
        
        // **********************
        // Invisible Vertical Gaps
        // **********************
        
        let verticalGapBetweenPipes = SKNode()
        verticalGapBetweenPipes.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipesVerticalMovementOffset)
        verticalGapBetweenPipes.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.pipe.size.width, verticalGapSizeBetweenPipes))
        verticalGapBetweenPipes.runAction(animateAndRemovePipes)
        verticalGapBetweenPipes.physicsBody!.dynamic = false
//        verticalGapBetweenPipes.physicsBody!.collisionBritMask = self.birdAndInvisibleVerticalGapBetweenPipesGroup // <-- any 2 object that applies this bitmask will not collide w/ each other but will pass through each other
        verticalGapBetweenPipes.physicsBody!.categoryBitMask = self.invisibleVerticalGapBetweenPipesGroup
        verticalGapBetweenPipes.physicsBody!.contactTestBitMask = self.birdGroup
        self.backgroundAndPipesGroupingNode.addChild(verticalGapBetweenPipes)
    }
    
    func setupEachPipe(textureName: String, verticalGapSizeBetweenPipes: CGFloat, pipesVerticalMovementOffset: CGFloat, animateAndRemovePipes: SKAction) {
        let pipeTexture = SKTexture(imageNamed: textureName)
        self.pipe = SKSpriteNode(texture: pipeTexture)
        self.pipe.position = textureName == "pipe1"
            ?
            CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + self.pipe.size.height / 2 + verticalGapSizeBetweenPipes / 2 + pipesVerticalMovementOffset)
            :
            CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - self.pipe.size.height / 2 - verticalGapSizeBetweenPipes / 2 + pipesVerticalMovementOffset)
        self.pipe.physicsBody = SKPhysicsBody(rectangleOfSize: self.pipe.size)
        self.pipe.physicsBody!.dynamic = false
        self.pipe.physicsBody!.categoryBitMask = self.physicalObjectGroup
        self.pipe.runAction(animateAndRemovePipes)
        self.backgroundAndPipesGroupingNode.addChild(self.pipe)
    }
}
