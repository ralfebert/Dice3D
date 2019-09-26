//
//  GameScene.swift
//  Dice3D
//
//  Created by Ralf Ebert on 25.09.19.
//  Copyright © 2019 Ralf Ebert. All rights reserved.
//

import SceneKit

class GameScene: SCNScene {
    override init() {
        super.init()

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        rootNode.addChildNode(cameraNode)

        let cubeNode = SCNScene(named: "art.scnassets/dice.dae")!.rootNode.childNode(withName: "Dice_1", recursively: false)!
        cubeNode.position.y += 3
        cubeNode.physicsBody = .dynamic()
        rootNode.addChildNode(cubeNode)

        let floorNode = SCNNode()
        floorNode.geometry = SCNFloor()
        floorNode.physicsBody = .static()
        rootNode.addChildNode(floorNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 10)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}
