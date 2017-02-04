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
    let cellsize = 25
    let gridOrigin = CGPoint(x: 500, y: 400)
    var fightersInView = [SKSpriteNode]()
    var deadLabel = SKLabelNode(text: "Dead = False")
    var stagnantLabel = SKLabelNode(text: "Stagnant = ?")
    
    override func didMove(to view: SKView) {
        if let data = userData?.object(forKey: "Data") as? Fighter {
            fighter = data
        }
        
        displayBrain()
        let frame = CGRect(x: 0, y: 0, width: self.view!.window!.frame.size.width + 50, height: CGFloat((inputs.count+2)*20 + 200)) //inputs.first!.frame.height * CGFloat(inputs.count)
        self.view!.window!.setFrame(frame, display: true)
        drawGrid()
        displayInfo()
        update()
    }
    override func mouseDown(with theEvent: NSEvent) {
        //print(theEvent.locationInNode(self))
        //print("location", inputs.last!.position.y, inputs.last!.frame.maxY)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        if fighter.scene != nil {
            fighter.scene!.keyDown(with: theEvent)
        }
    }
    
    func displayInfo() {
        let idText = SKLabelNode(text: "ID: \(fighter.id)")
        idText.horizontalAlignmentMode = .left
        idText.position = CGPoint(x: 5, y: 500)
        self.addChild(idText)
        let colorText = SKLabelNode(text: "Color: \(fighter.color.redComponent), \(fighter.color.greenComponent), \(fighter.color.blueComponent)")
        colorText.horizontalAlignmentMode = .left
        colorText.position = CGPoint(x: 5, y: 550)
        self.addChild(colorText)
        stagnantLabel.horizontalAlignmentMode = .left
        stagnantLabel.position = CGPoint(x: 5, y: 600)
        self.addChild(stagnantLabel)
        deadLabel.horizontalAlignmentMode = .left
        deadLabel.position = CGPoint(x: 5, y: 650)
        self.addChild(deadLabel)
    }
    
    func drawConnections() {
        for index in 0...fighter.brain.inputs.count-1 {
            for index2 in 0...fighter.brain.hiddenNodes.nodes.count-1 {
                let pathToDraw = CGMutablePath()
                let line = SKShapeNode(path:pathToDraw)
                pathToDraw.move(to: CGPoint(x: inputs.first!.frame.maxX, y: inputs[index].frame.midY))
                pathToDraw.addLine(to: CGPoint(x: hiddenNodes.first!.frame.minX, y: hiddenNodes[index2].frame.midY))
                line.path = pathToDraw
                line.strokeColor = SKColor.gray
                line.lineWidth = 0.5
                line.isAntialiased = false
                self.addChild(line)
                connectionsLayerOne.append(line)
            }
        }
        for index in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            for index2 in 0...fighter.brain.outputs.nodes.count-1 {
                let pathToDraw = CGMutablePath()
                let line = SKShapeNode(path:pathToDraw)
                pathToDraw.move(to: CGPoint(x: hiddenNodes.first!.frame.maxX, y: hiddenNodes[index].frame.midY))
                pathToDraw.addLine(to: CGPoint(x: outputs.first!.frame.minX, y: outputs[index2].frame.midY))
                line.path = pathToDraw
                line.strokeColor = SKColor.gray
                line.lineWidth = 0.5
                line.isAntialiased = false
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
        
        //        for connection in connectionsLayerOne {
        //            connection.strokeColor = SKColor(calibratedWhite: 1, alpha: )
        //        }
        for fighter in fightersInView {
            fighter.removeFromParent()
        }
        fightersInView.removeAll()
        
        let surroundings = fighter.getSurroundings()
        for row in 0...(fighter.radius*2) {
            for column in 0...(fighter.radius*2) {
                if surroundings[row][column] == ObjectType.fighter {
                    let absoluteLocation = GridCoordinate.init(x: (self.fighter.location.x - self.fighter.radius) + row, y: (self.fighter.location.x - self.fighter.radius) + row)
                    let retrivedFighter = (self.fighter.parent as! GameScene).fighterAt(absoluteLocation)
                    print("found fighter at (\((self.fighter.location.x - self.fighter.radius) + column), \((self.fighter.location.y - self.fighter.radius) + row)")
                    let fighter = SKSpriteNode(color: retrivedFighter!.color, size: CGSize(width: CGFloat(cellsize), height: CGFloat(cellsize)))
                    fighter.anchorPoint = CGPoint(x: 1, y: 1)
                    fighter.position = CGPoint(x: gridOrigin.x + CGFloat(row * cellsize), y: gridOrigin.y + CGFloat(column * cellsize))
                    self.addChild(fighter)
                    fightersInView.append(fighter)
                } else if surroundings[row][column] == ObjectType.invalid {
                    let wall = SKSpriteNode(texture: SKTexture(imageNamed: ""), size: CGSize(width: CGFloat(cellsize), height: CGFloat(cellsize)))
                    wall.anchorPoint = CGPoint(x: 1, y: 1)
                    wall.position = CGPoint(x: gridOrigin.x + CGFloat(row * cellsize), y: gridOrigin.y + CGFloat(column * cellsize))
                    self.addChild(wall)
                    fightersInView.append(wall)
                }
            }
        }
        stagnantLabel.text = "Stagnant = \(fighter.isStagnant())"
        if fighter.dead {
            deadLabel.text = "Dead = true"
        }
    }
    
    func displayBrain() {
        self.removeAllChildren()
        for index in 0...fighter.brain.inputs.count-1 {
            let label = SKLabelNode(text: "\(fighter.brain.inputs[index])")
            label.fontSize = fontSize
            label.position = CGPoint(x: 50, y: CGFloat(20*index))
            inputs.append(label)
            self.addChild(label)
        }
        
        for index in 0...fighter.brain.hiddenNodes.nodes.count-1 {
            let label = SKLabelNode(text: String(format: "%.16f", fighter.brain.hiddenNodes.nodes[index].output))
            label.horizontalAlignmentMode = .left
            label.fontSize = fontSize
            label.position = CGPoint(x: 250, y: CGFloat(80 + CGFloat(20*index)))
            hiddenNodes.append(label)
            self.addChild(label)
        }
        
        for index in 0...fighter.brain.outputs.nodes.count-1 {
            let label = SKLabelNode(text: String(format: "%.16f", fighter.brain.outputs.nodes[index].output))
            label.horizontalAlignmentMode = .left
            label.fontSize = fontSize
            label.position = CGPoint(x: 500, y: CGFloat(180 + CGFloat(20*index)))
            outputs.append(label)
            self.addChild(label)
        }
        
        drawConnections()
    }
    
    func drawGrid() {
        let diameter = fighter.radius * 2 + 1
        for column in 0...diameter {
            let pathToDraw = CGMutablePath()
            let line = SKShapeNode(path:pathToDraw)
            let xlocation = gridOrigin.x + CGFloat((column) * cellsize)
            
            pathToDraw.move(to: CGPoint(x: xlocation, y: gridOrigin.y))
                pathToDraw.addLine(to: CGPoint(x: xlocation, y: gridOrigin.y + CGFloat(cellsize * diameter)))
            
            line.path = pathToDraw
            line.strokeColor = SKColor.gray
            //line.lineWidth = 0.8
            line.isAntialiased = false
            self.addChild(line)
        }
        
        for row in 0...diameter {
            let pathToDraw = CGMutablePath()
            let line = SKShapeNode(path:pathToDraw)
            
            let ylocation = gridOrigin.y + CGFloat((row) * cellsize)
            pathToDraw.move(to: CGPoint(x: gridOrigin.x, y: ylocation))
            pathToDraw.addLine(to: CGPoint(x: gridOrigin.x + CGFloat(cellsize * diameter), y: ylocation))
            
            line.path = pathToDraw
            line.strokeColor = SKColor.gray
            //line.lineWidth = 0.8
            line.isAntialiased = false
            self.addChild(line)
        }
        let me = SKSpriteNode(texture: SKTexture(imageNamed: "Star"), size: CGSize(width: CGFloat(cellsize), height: CGFloat(cellsize)))
        me.anchorPoint = CGPoint(x: 1,y: 1)
        me.position = CGPoint(x: gridOrigin.x + CGFloat(fighter.radius + 1) * CGFloat(cellsize), y: gridOrigin.y + CGFloat(fighter.radius + 1) * CGFloat(cellsize))
        self.addChild(me)
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
