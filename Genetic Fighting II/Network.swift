//
//  Genes.swift
//  Genetic Fighting II
//
//  Created by Matthew Mohandiss on 9/8/15.
//  Copyright (c) 2015 Matthew Mohandiss. All rights reserved.
//

import Foundation

class Network {
    var inputs = [Int]()
    var hiddenNodes: Layer
    var outputs: Layer
    var nextMove = Int()
    
    init(imput: [[ObjectType]]) {
        inputs = translateInputs(imput)
        self.hiddenNodes = Layer(numNodes: 15, inputsPernode: inputs.count)
        self.outputs = Layer(numNodes: 5, inputsPernode: hiddenNodes.numNodes)
    }
    
    init(net1: Network, net2: Network) {
        self.hiddenNodes = Layer(numNodes: 15, inputsPernode: inputs.count)
        self.outputs = Layer(numNodes: 5, inputsPernode: hiddenNodes.numNodes)
        for nodeIndex in 0...self.hiddenNodes.nodes.count-1 {
            for weightIndex in 0...self.hiddenNodes.nodes[nodeIndex].weights.count-1{
                self.hiddenNodes.nodes[nodeIndex].weights[weightIndex] = (net1.hiddenNodes.nodes[nodeIndex].weights[weightIndex] + net2.hiddenNodes.nodes[nodeIndex].weights[weightIndex])/2
                let mod = (Double(arc4random()) / (0xFFFFFFFF/3)) - (0xFFFFFFFF/6)
                print(mod)
                if arc4random_uniform(10) == 0 {
                self.hiddenNodes.nodes[nodeIndex].weights[weightIndex] += mod
                    print("mutation occured")
                }
            }
        }
        for nodeIndex in 0...self.outputs.nodes.count-1 {
            for weightIndex in 0...self.outputs.nodes[nodeIndex].weights.count-1{
                self.outputs.nodes[nodeIndex].weights[weightIndex] = (net1.outputs.nodes[nodeIndex].weights[weightIndex] + net2.outputs.nodes[nodeIndex].weights[weightIndex])/2
                let mod = (Double(arc4random()) / (0xFFFFFFFF/3)) - (0xFFFFFFFF/6)
                self.outputs.nodes[nodeIndex].weights[weightIndex] += mod
            }
        }
    }
    
    init() {
        inputs = [Int](count: 24, repeatedValue: 0)
        self.hiddenNodes = Layer(numNodes: 15, inputsPernode: inputs.count)
        self.outputs = Layer(numNodes: 5, inputsPernode: hiddenNodes.numNodes)
    }
    
    func step (x: Double)-> Bool {
        if x >= 1 {
            return true
        } else {
            return false
        }
    }
    
    func calculate() {
        for node in hiddenNodes.nodes {
            var array = [Double]()
            for index in 0...inputs.count-1 {
                array.append(Double(self.inputs[index]) * node.weights[index])
            }
        node.output = average(array)
             //println(array) It's a printer
        }
        
        for node in outputs.nodes {
            var array = [Double]()
            for index in 0...hiddenNodes.nodes.count-1 {
                array.append(hiddenNodes.nodes[index].output * node.weights[index])
            }
            node.output = average(array)
        }
    }
    
    func think() {
        calculate()
        //var choice = outputs.nodes.first?.output
        var array = [Double]()
        for node in outputs.nodes {
            array.append(node.output)
            //print("[\(node.output)]")
        }
        
        array.sortInPlace(>)
        if outputs.nodes.first?.output == array.first { //up
            nextMove = 1
        } else if outputs.nodes[1].output == array.first { //down
            nextMove =  3
        } else if outputs.nodes[2].output == array.first { //left
            nextMove = 4
        } else if outputs.nodes[3].output == array.first {  //right
            nextMove = 2
        } else { // Do Nothing
            nextMove = 0
        }
    }
}

class Node {
    var numInputs = Int()
    
    var weights = [Double]()
    
    var output = Double()
    
    func setOutput(val: Double) {
        self.output = val
    }
    
    init(numInputs: Int) {
        self.numInputs = numInputs
        for _ in 1...numInputs {
            weights.append(Double(arc4random()) / 0xFFFFFFFF)
        }
    }
}

class Layer {
    var numNodes = Int()
    var nodes = [Node]()
    init(numNodes: Int, inputsPernode: Int) {
        self.numNodes = numNodes
        //let nodeCreate = Node(numInputs: inputsPernode)
        for _ in 1...numNodes {
            nodes.append(Node(numInputs: inputsPernode))
        }
    }
}

func average(imput: [Double])->Double {
    var val = 0.0
    for value in imput {
        val += value
    }
    return val/Double(imput.count)
}

func printArray(array: [Int]?) {
    if array != nil {
        for value in array! {
            print("[\(value)] ", terminator: "")
        }
        print("")
    } else {
        print("Array empty")
    }
}

func translateInputs(imput: [[ObjectType]])->[Int] {
    var array = [Int]()
    for column in 0...imput.first!.count-1 {
        for row in 0...imput.count-1 {
            array.append(imput[column][row].hashValue)
        }
    }
    array.removeAtIndex(12) //assuming radius of 2
    return array //store result of translation
}
