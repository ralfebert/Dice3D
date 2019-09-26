//
//  GameViewController.swift
//  Dice3D
//
//  Created by Ralf Ebert on 25.09.19.
//  Copyright © 2019 Ralf Ebert. All rights reserved.
//

import QuartzCore
import SceneKit
import UIKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        let scene = GameScene()

        // retrieve the SCNView
        let scnView = view as! SCNView

        // set the scene to the view
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        scnView.autoenablesDefaultLighting = true

        // configure the view
        scnView.backgroundColor = UIColor.red

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = view as! SCNView

        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])

        guard let firstHit = hitResults.first, let nodeName = firstHit.node.name, nodeName == "Dice_White_1-Pivot" else { return }

        // throw dice
        let dice = firstHit.node.parent!
        dice.physicsBody = .none

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        dice.position.y = Float.random(in: 4 ... 8)
        let range = -3 * Float.pi ... 3 * Float.pi
        dice.eulerAngles = SCNVector3Make(Float.random(in: range), Float.random(in: range), Float.random(in: range))

        SCNTransaction.completionBlock = {
            dice.physicsBody = .dynamic()
        }
        SCNTransaction.commit()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
