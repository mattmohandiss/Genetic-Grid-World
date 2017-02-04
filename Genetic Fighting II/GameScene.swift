//
//  GameScene.swift
//  Genetic Fighting II
//
//  Created by Matthew Mohandiss on 9/6/15.
//  Copyright (c) 2015 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

var gameGrid = Grid(columns: 10, rows: 10)

class GameScene: SKScene {
    let numFighters = 2 //cannot be 1
    var toggleTick = true
    let tickInterval = 0.1
    let numTicks = 80
    var tickCount = 0
    var genText = SKLabelNode(text: "Generation 1")
    var generation = 1
    var fighters = [Fighter]()
    let killBonus = 50
    let pointsEveryTick = true //if fighter moveType != "continue" this should be false
    var topFitnessLabel = SKLabelNode(text: "Top Fitness: 0")
    var topFitness = 0
    var selectedFighter = Fighter()
    var tickText = SKLabelNode(text: "tick")
    let drawgrid = true
    let numberCells = false //for debugging
    var gridLines = [SKShapeNode]()
    
    override func didMove(to view: SKView) {
        backgroundColor = NSColor.black
        drawGrid()
        genText.text = "Generation \(generation)"
        genText.fontSize = 22
        genText.position = CGPoint(x: self.frame.midX - 75, y: self.frame.maxY - 50)
        topFitnessLabel.text = "Top Fitness: \(topFitness)"
        topFitnessLabel.fontSize = 22
        topFitnessLabel.position = CGPoint(x: self.frame.midX + 70, y: self.frame.maxY - 50)
        tickText.text = "tick: \(tickCount)"
        tickText.horizontalAlignmentMode = .left
        tickText.position = CGPoint(x: self.frame.minX, y: self.frame.minY)
        self.addChild(genText)
        self.addChild(topFitnessLabel)
        self.addChild(tickText)
        spawnFighters()
        tick()
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        print("Grid Coordinate: (\(Int(floor(location.x/gameGrid.cellSize.width))), \(Int(floor(location.y/gameGrid.cellSize.height))))")
        
        self.enumerateChildNodes(withName: "fighter", using: { (node, stop) in
            if let fighter = node as? Fighter {
                if fighter.contains(location) {
                    let appDelegate = NSApplication.shared().delegate as! AppDelegate
                    self.selectedFighter = fighter
                    fighter.texture = SKTexture(imageNamed: "Star")
                    if appDelegate.secondaryWindow == nil { // dont open window if there is already one
                        appDelegate.launchFighterAdvancedView(fighter)
                    } else {
                        print("there is already a window open")
                    }
                }
            }
        })
    }
    
    func fighterAt(_ location: GridCoordinate) -> Fighter? {
        for fighter in fighters {
            if fighter.location == location {
                return fighter
            }
        }
        return nil
    }
    
    override func keyDown(with theEvent: NSEvent) {
        let fighter = selectedFighter
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
            //printArray(fighter.brain.inputs)
            printGrid((fighter.getSurroundings()))
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
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            if appDelegate.secondaryWindow != nil {
                print(appDelegate.secondaryWindow!.frame)
                print(appDelegate.secondaryView!.frame)
            } else {
                print("there is no window")
            }
        case 49: //space
            if !toggleTick {
                toggleTick = true
                self.run(SKAction.wait(forDuration: tickInterval), completion: {
                    self.toggleTick = false
                })
            }
        default:
            break
        }
    }
    
    func spawnFighters(_ fighters: Fighter...) {
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
    
    func didKillAtPoint(_ coord: GridCoordinate) -> Bool {
        var bool = false
        self.enumerateChildNodes(withName: "fighter") {
            node, stop in
            let fighter = node as! Fighter
            if fighter.location == coord{
                fighter.dead = true
                self.removeFighter(fighter)
                bool = true
                stop.pointee = true
            }
        }
        return bool
    }
    
    func removeFighter(_ fighter: Fighter) {
        for index in 0...fighters.count-1 {
            if fighters[index] == fighter {
                fighters.remove(at: index)
                fighter.removeFromParent()
                break
            }
        }
    }
    
    func tick() {
        if toggleTick && (tickCount <= numTicks) && (fighters.count > 2) {
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            if appDelegate.secondaryView != nil {
                //print(appDelegate.secondaryView)
                let scene = appDelegate.secondaryView!.scene as! FighterAdvancedView
                scene.fighter = self.selectedFighter
                scene.update()
            }
            self.enumerateChildNodes(withName: "fighter") {
                node, stop in
                let fighter = node as! Fighter
                fighter.brain.inputs = translateInputs(fighter.getSurroundings())
                fighter.brain.think()
                if fighter.fitness > self.topFitness {
                    self.topFitness = fighter.fitness
                    self.topFitnessLabel.text = "Top Fitness: \(self.topFitness)"
                }
            } //think and calculate fittest
            self.enumerateChildNodes(withName: "fighter") {
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
            self.enumerateChildNodes(withName: "fighter") {
                node, stop in
                let fighter = node as! Fighter
                if self.pointsEveryTick {fighter.fitness += 1}
            } //award points every tick
        }
        var stagnant = true
        self.enumerateChildNodes(withName: "fighter") {
            node, stop in
            let fighter = node as! Fighter
            if !fighter.isStagnant() {
                stagnant = false
                stop.pointee = true
            }
        }
        if stagnant {
            //print("everyone is stagnant")
        }
        if tickCount > numTicks {//|| stagnant {
            //                self.enumerateChildNodesWithName("fighter") {
            //                    node, stop in
            //                    let fighter = node as! Fighter
            //                    fighter.fitness += 20 //??
            //                }
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            if appDelegate.secondaryWindow != nil {
                appDelegate.secondaryWindow!.close()
                //appDelegate.secondaryView = nil
                appDelegate.secondaryWindow = nil
                print(appDelegate.secondaryWindow == nil)
            } // close advancedView window
            nextGeneration() //end generation
        } else {
            self.run(SKAction.wait(forDuration: tickInterval), completion: {
                if self.toggleTick {self.tickCount += 1}
                self.tickText.text = "Tick: \(self.tickCount)"
                self.tick()})
        }
    }
    
    func nextGeneration() {
        fighters.sort(by: { $0.fitness > $1.fitness })
        let chosenOnes = [fighters.first!, fighters[1]]
        self.enumerateChildNodes(withName: "fighter") {
            node, stop in
            let fighter = node as! Fighter
            self.removeFighter(fighter)
        }
        fighters.removeAll()
        spawnFighters(chosenOnes.first!, chosenOnes.last!)
        generation += 1
        genText.text = "Generation \(generation)"
        tickCount = 0
        topFitness = 0
        tick()
    }
    
    func testTick(_ fighter: Fighter) {
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
    
    override func didChangeSize(_ oldSize: CGSize) {
        if self.size != oldSize {
            for line in gridLines {
                line.removeFromParent()
            }
            drawGrid()
            for fighter in fighters {
                fighter.size = gameGrid.cellSize
                fighter.position = CGPoint(x: gameGrid.cellSize.width * CGFloat(fighter.location.x), y: gameGrid.cellSize.height * CGFloat(fighter.location.y))
            }
        }
    }
    
    func drawGrid() {
        if self.view != nil {
            gameGrid.cellSize = CGSize(width: floor((self.view!.frame.maxX / CGFloat(gameGrid.columns))), height: floor((self.view!.frame.maxY / CGFloat(gameGrid.rows))))
            if drawgrid {
                for column in 0...(gameGrid.columns) {
                    let pathToDraw = CGMutablePath()
                    let line = SKShapeNode(path:pathToDraw)
                    let xlocation = CGFloat((column) * (Int(self.view!.frame.maxX) / gameGrid.columns))
                    pathToDraw.move(to: CGPoint(x: xlocation, y: self.view!.frame.minY))
                    pathToDraw.addLine(to: CGPoint(x: xlocation, y: gameGrid.cellSize.height * CGFloat(gameGrid.rows)))
                    
                    line.path = pathToDraw
                    line.strokeColor = SKColor.gray
                    //line.lineWidth = 0.8
                    line.isAntialiased = false
                    self.addChild(line)
                    gridLines.append(line)
                }
                
                for row in 0...(gameGrid.rows) {
                    let pathToDraw = CGMutablePath()
                    let line = SKShapeNode(path:pathToDraw)
                    
                    let ylocation = CGFloat((row) * (Int(self.view!.frame.maxY) / gameGrid.rows))
                    pathToDraw.move(to: CGPoint(x: self.view!.frame.minX, y: ylocation))
                    pathToDraw.addLine(to: CGPoint(x: gameGrid.cellSize.width * CGFloat(gameGrid.columns), y: ylocation))
                    
                    line.path = pathToDraw
                    line.strokeColor = SKColor.gray
                    //line.lineWidth = 0.8
                    line.isAntialiased = false
                    self.addChild(line)
                    gridLines.append(line)
                }
            }
            
            if numberCells {
                var count = 0
                for row in 1...gameGrid.rows {
                    for column in 1...gameGrid.columns {
                        count += 1
                        let number = SKLabelNode(text: "\(count)")
                        number.fontName = "Arial-BoldMT"
                        number.fontSize = 12
                        number.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
                        number.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
                        number.position = CGPoint(x: CGFloat(column) * gameGrid.cellSize.width, y: CGFloat(row) * gameGrid.cellSize.height)
                        self.addChild(number)
                    }
                }
            }
        }
    }
}
