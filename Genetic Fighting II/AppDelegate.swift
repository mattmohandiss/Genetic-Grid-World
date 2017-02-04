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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* Pick a size for the scene */
        let scene = GameScene(size: window.frame.size)
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = SKSceneScaleMode.resizeFill
        self.skView!.presentScene(scene)
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
        //launchFighterAdvancedView()
    }
    
    func launchFighterAdvancedView(_ fighter: Fighter) {
        secondaryWindow = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 1000, height: 800), styleMask: NSWindowStyleMask.fullSizeContentView, backing: NSBackingStoreType.buffered, defer: false)
        secondaryWindow?.isReleasedWhenClosed = false
        secondaryWindow!.center()
        secondaryWindow!.isOpaque = true
        secondaryWindow!.isMovableByWindowBackground = true
        secondaryWindow!.backgroundColor = NSColor(hue: 0, saturation: 1, brightness: 0, alpha: 0.7)
        //secondaryWindow.setContentSize(secondaryView.frame.size)
        secondaryView = SKView()
        secondaryWindow!.contentView = secondaryView
        secondaryWindow!.makeKeyAndOrderFront(nil)
        let scene = FighterAdvancedView(size: secondaryView!.bounds.size)
        //scene.position = secondaryWindow.frame.origin
        scene.scaleMode = .resizeFill
        scene.userData = ["Data":fighter]
        secondaryView!.presentScene(scene)
        secondaryWindow!.setFrame(scene.frame, display: true)
        secondaryWindow!.center()
        //skView.backgroundFilters
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
