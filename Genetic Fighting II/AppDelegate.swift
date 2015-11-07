//
//  AppDelegate.swift
//  Genetic Fighting II
//
//  Created by Matthew Mohandiss on 9/6/15.
//  Copyright (c) 2015 Matthew Mohandiss. All rights reserved.
//


import Cocoa
import SpriteKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    var secondaryWindow:NSWindow?
    var secondaryView:SKView?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        let scene = GameScene(size: window.frame.size)
        print(window.frame)
        print(skView.frame)
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = SKSceneScaleMode.ResizeFill
            self.skView!.presentScene(scene)
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            self.skView!.ignoresSiblingOrder = true
            
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
        //launchFighterAdvancedView()
    }
    
    func launchFighterAdvancedView(fighter: Fighter) {
      let styleMasks = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
       secondaryWindow = NSWindow(contentRect: CGRectMake(0, 0, 800, 475), styleMask: styleMasks, backing: NSBackingStoreType.Buffered, `defer`: false)
       secondaryWindow!.center()
       secondaryWindow!.opaque = true
        secondaryWindow!.movableByWindowBackground = true
        secondaryWindow!.backgroundColor = NSColor(hue: 0, saturation: 1, brightness: 0, alpha: 0.7)
        //secondaryWindow.setContentSize(secondaryView.frame.size)
        secondaryView = SKView()
        secondaryWindow!.contentView = secondaryView
        secondaryWindow!.makeKeyAndOrderFront(nil)
        let scene = FighterAdvancedView(size: secondaryView!.bounds.size)
        print(secondaryWindow!.frame)
        print(secondaryView!.frame)
        //scene.position = secondaryWindow.frame.origin
        scene.scaleMode = .ResizeFill
        scene.userData = ["Data":fighter]
        secondaryView!.presentScene(scene)
        secondaryWindow!.setFrame(scene.frame, display: true)
        secondaryWindow!.center()
        //skView.backgroundFilters
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
