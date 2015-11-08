//
//  GameScene.swift
//  Genetic Fighting II
//
//  Created by Matthew Mohandiss on 9/6/15.
//  Copyright (c) 2015 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

var gameGrid = Grid(columns: 50, rows: 50)

class GameScene: SKScene {
    let numFighters = 50
    var toggleTick = true
    let tickInterval = 0.1
    let numTicks = 80
    var tickCount = 0
    var genText = SKLabelNode(text: "Generation 1")
    var generation = 1
    var fighters = [Fighter]()
    let killBonus = 50
    let pointsEveryTick = false //if fighter moveType != "continue" this should be false
    var topFitnessLabel = SKLabelNode(text: "Top Fitness: 0")
    var topFitness = 0
    var selectedFighter = Fighter()
    
    override func didMoveToView(view: SKView) {
        drawGrid()
        genText.text = "Generation \(generation)"
        genText.fontSize = 22
        genText.position = CGPointMake(self.frame.midX - 75, self.frame.maxY - 50)
        topFitnessLabel.text = "Top Fitness: \(topFitness)"
        topFitnessLabel.fontSize = 22
        topFitnessLabel.position = CGPointMake(self.frame.midX + 70, self.frame.maxY - 50)
        self.addChild(genText)
        self.addChild(topFitnessLabel)
        spawnFighters()
        tick()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        self.enumerateChildNodesWithName("fighter", usingBlock: { (node, stop) in
            if let fighter = node as? Fighter {
                if fighter.containsPoint(theEvent.locationInNode(self)) {
                    print(fighter.isStagnant())
                    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                    self.selectedFighter = fighter
                    if appDelegate.secondaryWindow == nil { // dont open window if there is already one
                        appDelegate.launchFighterAdvancedView(fighter)
                    } else {
                        print("there is already a window open")
                    }
                }
            }
        })
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    override func keyDown(theEvent: NSEvent) {
        let fighter = self.childNodeWithName("fighter") as! Fighter
        //print(theEvent.keyCode)
        switch theEvent.keyCode {
        case 126: //up
            fighter.moveUp()
        case 125: //down
            fighter.moveDown()
        case 124: //left
            fighter.moveRight()
        case 123: //right
            fighter.moveLeft()
        case 5: //g
            printGrid(gameGrid.grid)
        case 45: //n
            printArray(fighter.brain.inputs)
        case 17: //t
            if toggleTick {
                toggleTick = false
            } else {
                toggleTick = true
            }
            //testTick(fighter)
        case 3: //f
            print(fighters.count)
        case 9: //v
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            if appDelegate.secondaryWindow != nil {
                print(appDelegate.secondaryWindow!.frame)
                print(appDelegate.secondaryView!.frame)
            } else {
                print("there is no window")
            }
        default:
            break
        }
    }
    
    func spawnFighters(fighters: Fighter...) {
        for _ in 1...numFighters {
            var warrior = Fighter()
            if fighters.count == 2 {
                warrior = Fighter(fighter1: fighters.first!, fighter2: fighters.last!)
            }
            gameGrid.addFighter(warrior)
            self.fighters.append(warrior)
            self.addChild(warrior)
        }
    }
    
    func didKillAtPoint(coord: GridCoordinate) -> Bool {
        var bool = false
        self.enumerateChildNodesWithName("fighter") {
            node, stop in
            let fighter = node as! Fighter
            if fighter.location == coord{
                self.removeFighter(fighter)
                bool = true
                stop.memory = true
            }
        }
        return bool
    }
    
    func removeFighter(fighter: Fighter) {
        for index in 0...fighters.count-1 {
            if fighters[index] == fighter {
                //fighters.removeAtIndex(index)
                fighter.removeFromParent()
                break
            }
        }
    }
    
    func tick() {
        if toggleTick && (tickCount <= numTicks) && (fighters.count > 2) {
            let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            if appDelegate.secondaryView != nil {
                //print(appDelegate.secondaryView)
                let scene = appDelegate.secondaryView!.scene as! FighterAdvancedView
                scene.fighter = self.selectedFighter
                scene.update()
            }
            self.enumerateChildNodesWithName("fighter") {
                node, stop in
                let fighter = node as! Fighter
                fighter.brain.inputs = translateInputs(fighter.getSurroundings())
                fighter.brain.think()
                if fighter.fitness > self.topFitness {
                    self.topFitness = fighter.fitness
                    self.topFitnessLabel.text = "Top Fitness: \(self.topFitness)"
                }
            } //think and calculate fittest
            self.enumerateChildNodesWithName("fighter") {
                node, stop in
                let fighter = node as! Fighter
                var willAwardPoints = Bool()
                switch fighter.brain.nextMove {
                case 1:
                    willAwardPoints = self.didKillAtPoint(GridCoordinate(x: fighter.location.x, y: fighter.location.y+1))
                    fighter.moveUp()
                case 2:
                    willAwardPoints = self.didKillAtPoint(GridCoordinate(x: fighter.location.x+1, y: fighter.location.y))
                    fighter.moveRight()
                case 3:
                    willAwardPoints = self.didKillAtPoint(GridCoordinate(x: fighter.location.x, y: fighter.location.y-1))
                    fighter.moveDown()
                case 4:
                    willAwardPoints = self.didKillAtPoint(GridCoordinate(x: fighter.location.x-1, y: fighter.location.y))
                    fighter.moveLeft()
                case 0:
                    break
                default:
                    print("ERROR: fighter choose invalid move")
                }
                if willAwardPoints {fighter.fitness += self.killBonus}
            } //award point for kills
            self.enumerateChildNodesWithName("fighter") {
                node, stop in
                let fighter = node as! Fighter
                if self.pointsEveryTick {fighter.fitness++}
            } //award points every tick
        }
        var stagnant = true
        self.enumerateChildNodesWithName("fighter") {
            node, stop in
            let fighter = node as! Fighter
            if !fighter.isStagnant() {
                stagnant = false
                stop.memory = true
            }
        }
        if stagnant {
            print("everyone is stagnant")
        }
            if tickCount > numTicks || stagnant {
//                self.enumerateChildNodesWithName("fighter") {
//                    node, stop in
//                    let fighter = node as! Fighter
//                    fighter.fitness += 20 //??
//                }
                let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                if appDelegate.secondaryWindow != nil {
                    appDelegate.secondaryWindow?.releasedWhenClosed = false
                    appDelegate.secondaryWindow!.close()
                    //appDelegate.secondaryView = nil
                    appDelegate.secondaryWindow = nil
                    print(appDelegate.secondaryWindow == nil)
                } // close advancedView window
                nextGeneration() //end generation
            } else {
                self.runAction(SKAction.waitForDuration(tickInterval), completion: {
                    if self.toggleTick {self.tickCount++}
                    self.tick()})
            }
    }
    
    func nextGeneration() {
        fighters.sortInPlace({ $0.fitness > $1.fitness })
        let chosenOnes = [fighters.first!, fighters[1]]
        self.enumerateChildNodesWithName("fighter") {
            node, stop in
            let fighter = node as! Fighter
            self.removeFighter(fighter)
        }
        fighters.removeAll()
        spawnFighters(chosenOnes.first!, chosenOnes.last!)
        generation++
        genText.text = "Generation \(generation)"
        tickCount = 0
        topFitness = 0
        tick()
    }
    
    func testTick(fighter: Fighter) {
        fighter.brain.inputs = translateInputs(fighter.getSurroundings())
        fighter.brain.think()
        
        switch fighter.brain.nextMove {
        case 1:
            fighter.moveUp()
        case 2:
            fighter.moveRight()
        case 3:
            fighter.moveDown()
        case 4:
            fighter.moveLeft()
        case 0:
            break
        default:
            print("ERROR: fighter choose invalid move")
        }
        
    }
    
    func drawGrid() {
        
        gameGrid.cellSize = CGSizeMake(floor((self.view!.frame.maxX / CGFloat(gameGrid.columns))), floor((self.view!.frame.maxY / CGFloat(gameGrid.rows))))
        
        for column in 0...(gameGrid.columns) {
            let pathToDraw = CGPathCreateMutable()
            let line = SKShapeNode(path:pathToDraw)
            let xlocation = CGFloat((column) * (Int(self.view!.frame.maxX) / gameGrid.columns))
            CGPathMoveToPoint(pathToDraw, nil, xlocation, self.view!.frame.minY)
            CGPathAddLineToPoint(pathToDraw, nil, xlocation, gameGrid.cellSize.height * CGFloat(gameGrid.rows))
            
            line.path = pathToDraw
            line.strokeColor = SKColor.grayColor()
            line.lineWidth = 0.25
            line.antialiased = false
            self.addChild(line)
        }
        
        for row in 0...(gameGrid.rows) {
            let pathToDraw = CGPathCreateMutable()
            let line = SKShapeNode(path:pathToDraw)
            
            let ylocation = CGFloat((row) * (Int(self.view!.frame.maxY) / gameGrid.rows))
            CGPathMoveToPoint(pathToDraw, nil, self.view!.frame.minX, ylocation)
            CGPathAddLineToPoint(pathToDraw, nil, gameGrid.cellSize.width * CGFloat(gameGrid.columns), ylocation)
            
            line.path = pathToDraw
            line.strokeColor = SKColor.grayColor()
            line.lineWidth = 0.25
            line.antialiased = false
            self.addChild(line)
        }
    }
}
