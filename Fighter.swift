//
//  Fighter.swift
//  Genetic Fighting II
//
//  Created by Matthew Mohandiss on 9/6/15.
//  Copyright (c) 2015 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class Fighter: SKSpriteNode {
    var fitness = Int()
    var location = GridCoordinate(x: 0, y: 0)
    var brain = Network()
    var id = Int()
    var moveType = "continue" //stop, rebound, or continue
    var lastFourPositions = [GridCoordinate?](count: 4, repeatedValue: nil)
    func moveUp() {
        if location.y < gameGrid.rows-1 {
            gameGrid.moveFighter(self, direction: "up")
            updatePosition()
        } else if moveType == "rebound" {
            gameGrid.moveFighter(self, direction: "down")
        } else if let parent = parent as? GameScene {
            if moveType == "continue" {
                parent.removeFighter(self)
            }
        }
    }
    
    func moveDown() {
        if location.y > 0 {
            gameGrid.moveFighter(self, direction: "down")
            updatePosition()
        } else if moveType == "rebound" {
            gameGrid.moveFighter(self, direction: "up")
        } else if let parent = parent as? GameScene {
            if moveType == "continue" {
                parent.removeFighter(self)
            }
        }
    }
    
    func moveLeft() {
        if location.x > 0 {
            gameGrid.moveFighter(self, direction: "left")
            updatePosition()
        } else if moveType == "rebound" {
            gameGrid.moveFighter(self, direction: "right")
        } else if let parent = parent as? GameScene {
            if moveType == "continue" {
                parent.removeFighter(self)
            }
        }
    }
    
    func moveRight() {
        if location.x < gameGrid.columns-1 {
            gameGrid.moveFighter(self, direction: "right")
            updatePosition()
        } else if moveType == "rebound" {
            gameGrid.moveFighter(self, direction: "left")
        } else if let parent = parent as? GameScene {
            if moveType == "continue" {
                parent.removeFighter(self)
            }
        }
    }
    
    func updatePosition() {
        self.position = CGPointMake(gameGrid.cellSize.width * CGFloat(location.x), gameGrid.cellSize.height * CGFloat(location.y))
        //for use in determining if stagnant
        lastFourPositions[3] = lastFourPositions[2]
        lastFourPositions[2] = lastFourPositions[1]
        lastFourPositions[1] = lastFourPositions[0]
        lastFourPositions[0] = self.location
    }
    
    func isStagnant()-> Bool {
        var bool = false
        if lastFourPositions.first != nil && lastFourPositions[1] != nil && lastFourPositions[2] != nil && lastFourPositions[3] != nil && lastFourPositions.last != nil {
            if (lastFourPositions[0] == lastFourPositions[2])&&(lastFourPositions[1] == lastFourPositions[3]) {
                bool = true
            } else if (lastFourPositions[0] == lastFourPositions[1]) && (lastFourPositions[1] == lastFourPositions[2]) && (lastFourPositions[2] == lastFourPositions[3]) && (lastFourPositions[3] == lastFourPositions[4]) {
                bool = true
            }
        }
        return bool
    }
    
    func getSurroundings() -> [[ObjectType]] {
        let radius = 6 //only even numbers
        var array = [[ObjectType]](count: radius*2 + 1, repeatedValue: [ObjectType](count: radius*2 + 1, repeatedValue: ObjectType.empty))
        //let arrStart = GridCoordinate(x: location.x - radius, y: location.y - radius)
        for column in 0...(radius*2) {
            for row in 0...(radius*2) {
                let checkLoc = GridCoordinate(x: (location.x - radius) + row, y: (location.y - radius) + column)
                if checkLoc.x >= 0 && checkLoc.y >= 0 && checkLoc.x <= (gameGrid.rows - 1) && checkLoc.y <= (gameGrid.columns - 1) {
                    if gameGrid.grid[checkLoc.x][checkLoc.y] == ObjectType.fighter {
                        array[column][row] = ObjectType.fighter
                    }
                } else {
                    array[column][row] = ObjectType.invalid
                }
            }
        }
        array[radius][radius] = ObjectType.me
        return array
    }
    
    convenience init() {
        let color = NSColor(red: CGFloat(Double(arc4random()) / 0xFFFFFFFF), green: CGFloat(Double(arc4random()) / 0xFFFFFFFF), blue: CGFloat(Double(arc4random()) / 0xFFFFFFFF), alpha: 1)
        self.init(texture: nil, color: color, size: gameGrid.cellSize)
        
        self.location = GridCoordinate(x: Int(arc4random_uniform(UInt32(gameGrid.columns-1))), y: Int(arc4random_uniform(UInt32(gameGrid.rows-1))))
        self.anchorPoint = CGPointZero
        updatePosition()
        self.name = "fighter"
        self.brain = Network(imput: getSurroundings())
        self.id = Int(arc4random_uniform(1000))
    }
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(fighter1: Fighter, fighter2: Fighter) {
        //let color = SKColor(red: (fighter1.color.redComponent + fighter2.color.redComponent)/2, green: (fighter1.color.greenComponent + fighter2.color.greenComponent)/2, blue: (fighter1.color.blueComponent + fighter2.color.blueComponent)/2, alpha: 1)
        let color = SKColor(red: CGFloat(Double(arc4random()) / 0xFFFFFFFF), green: CGFloat(Double(arc4random()) / 0xFFFFFFFF), blue: CGFloat(Double(arc4random()) / 0xFFFFFFFF), alpha: 1)
        let texture:SKTexture? = nil
        self.init(texture: texture, color: color, size: gameGrid.cellSize)
        self.location = GridCoordinate(x: Int(arc4random_uniform(UInt32(gameGrid.columns-1))), y: Int(arc4random_uniform(UInt32(gameGrid.rows-1))))
        self.anchorPoint = CGPointZero
        updatePosition()
        self.name = "fighter"
        self.brain = Network(imput: getSurroundings())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
