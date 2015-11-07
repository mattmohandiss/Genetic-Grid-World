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
    
    override func didMoveToView(view: SKView) {
        if let data = userData?.objectForKey("Data") as? Fighter {
            fighter = data
        }
        displayBrain()
    }
    override func mouseDown(theEvent: NSEvent) {
        print(theEvent.locationInNode(self))
    }
    
    func displayBrain() {
        let fontSize = CGFloat(20)
        self.removeAllChildren()
        for index in 0...fighter.brain.inputs.count-1 {
            let label = SKLabelNode(text: "\(fighter.brain.inputs[index])")
            label.fontSize = fontSize
            label.position = CGPointMake(50, CGFloat(20*index))
            inputs.append(label)
           self.addChild(label)
            //drawConnections()
        }
        
        func drawConnections() {
            for index in 0...24 {
                let pathToDraw = CGPathCreateMutable()
                let line = SKShapeNode(path:pathToDraw)
                CGPathMoveToPoint(pathToDraw, nil, CGFloat(10*index), 0)
                CGPathAddLineToPoint(pathToDraw, nil, CGFloat(10*index), 10)
                line.path = pathToDraw
                line.strokeColor = SKColor.grayColor()
                line.lineWidth = 0.25
                line.antialiased = false
                self.addChild(line)
            }
        }
        
        for index in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            let label = SKLabelNode(text: "\(fighter.brain.hiddenNodes.nodes[index].output)")
            label.horizontalAlignmentMode = .Left
            label.fontSize = fontSize
            label.position = CGPointMake(150, CGFloat(80 + CGFloat(20*index)))
            hiddenNodes.append(label)
            self.addChild(label)
        }
        
        for index in 0...fighter.brain.outputs.nodes.count-1 {
            let label = SKLabelNode(text: "\(fighter.brain.outputs.nodes[index].output)")
            label.horizontalAlignmentMode = .Left
            label.fontSize = fontSize
            label.position = CGPointMake(400, CGFloat(180 + CGFloat(20*index)))
            outputs.append(label)
            self.addChild(label)
        }
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
*/