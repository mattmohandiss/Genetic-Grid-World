//
//  FighterAdvancedView.swift
//  Genetic Fighting II
//
//  Created by Matthew Mohandiss on 9/14/15.
//  Copyright (c) 2015 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class FighterAdvancedView: SKScene {
    var fighter = Fighter()
    var inputs = [SKLabelNode]()
    var hiddenNodes = [SKLabelNode]()
    var outputs = [SKLabelNode]()
    var connectionsLayerOne = [SKShapeNode]()
    var connectionsLayerTwo = [SKShapeNode]()
    let fontSize:CGFloat = 20
    
    override func didMoveToView(view: SKView) {
        if let data = userData?.objectForKey("Data") as? Fighter {
            fighter = data
        }
        displayBrain()
        let frame = CGRectMake(0, 0, self.view!.window!.frame.size.width, CGFloat((inputs.count+2)*20)) //inputs.first!.frame.height * CGFloat(inputs.count)
        self.view!.window!.setFrame(frame, display: true)
    }
    override func mouseDown(theEvent: NSEvent) {
        print(theEvent.locationInNode(self))
        print("location", inputs.last!.position.y, inputs.last!.frame.maxY)
    }
    
    func drawConnections() {
            for index in 0...fighter.brain.inputs.count-1 {
                for index2 in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            let pathToDraw = CGPathCreateMutable()
            let line = SKShapeNode(path:pathToDraw)
            CGPathMoveToPoint(pathToDraw, nil, inputs.first!.frame.maxX, inputs[index].frame.midY)
            CGPathAddLineToPoint(pathToDraw, nil, hiddenNodes.first!.frame.minX, hiddenNodes[index2].frame.midY)
            line.path = pathToDraw
            line.strokeColor = SKColor.grayColor()
            line.lineWidth = 0.5
            line.antialiased = false
            self.addChild(line)
                    connectionsLayerOne.append(line)
                }
            }
        for index in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            for index2 in 0...fighter.brain.outputs.nodes.count-1 {
                let pathToDraw = CGPathCreateMutable()
                let line = SKShapeNode(path:pathToDraw)
                CGPathMoveToPoint(pathToDraw, nil, hiddenNodes.first!.frame.maxX, hiddenNodes[index].frame.midY)
                CGPathAddLineToPoint(pathToDraw, nil, outputs.first!.frame.minX, outputs[index2].frame.midY)
                line.path = pathToDraw
                line.strokeColor = SKColor.grayColor()
                line.lineWidth = 0.5
                line.antialiased = false
                self.addChild(line)
                connectionsLayerTwo.append(line)
            }
        }
    }
    
    func update() {
        for index in 0...fighter.brain.inputs.count-1 {
            inputs[index].text = "\(fighter.brain.inputs[index])"
        }
        
        for index in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            hiddenNodes[index].text = String(format: "%.16f", fighter.brain.hiddenNodes.nodes[index].output)
        }
        
        for index in 0...fighter.brain.outputs.nodes.count-1 {
            outputs[index].text = String(format: "%.16f", fighter.brain.outputs.nodes[index].output)
        }
    }
    
    func displayBrain() {
        self.removeAllChildren()
        for index in 0...fighter.brain.inputs.count-1 {
            let label = SKLabelNode(text: "\(fighter.brain.inputs[index])")
            label.fontSize = fontSize
            label.position = CGPointMake(50, CGFloat(20*index))
            inputs.append(label)
           self.addChild(label)
        }
        
        for index in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            let label = SKLabelNode(text: String(format: "%.16f", fighter.brain.hiddenNodes.nodes[index].output))
            label.horizontalAlignmentMode = .Left
            label.fontSize = fontSize
            label.position = CGPointMake(250, CGFloat(80 + CGFloat(20*index)))
            hiddenNodes.append(label)
            self.addChild(label)
        }
        
        for index in 0...fighter.brain.outputs.nodes.count-1 {
            let label = SKLabelNode(text: String(format: "%.16f", fighter.brain.outputs.nodes[index].output))
            label.horizontalAlignmentMode = .Left
            label.fontSize = fontSize
            label.position = CGPointMake(500, CGFloat(180 + CGFloat(20*index)))
            outputs.append(label)
            self.addChild(label)
        }
        
        drawConnections()
    }
}


class displayNode: SKShapeNode {
    var output = Double()
    var weights = [Double]()
    
    convenience init(node: Node) {
        self.init()
        //self.path = CGPath(
    }
}

/* 
                Todo
_________________________________________________
|    1. Finish FighterAdvancedView Class        |
|    2. Add Another Hidden layer?               |
|    3. Player Control for 1 fighter            |
|    4. Graph of avg fitness over time          |
|    5. More ways to earn fitness (least moves?)|
|_______________________________________________|

***Do not remove fighters from fighters array. They will not be counted in running for nextGeneration

A few biases:
    1. when two fighters collide head on, the first fighter to be processed kills the other one
    2. when all oputputs of a network are equal (most likley 0.0) the fighter chooses the first action (move up)
*/