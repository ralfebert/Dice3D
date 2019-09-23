import SceneKit

@objc protocol JAQDiceProtocol: NSObjectProtocol {
    func diceView(_ view: JAQDiceView?, rolledWithFirstValue firstValue: Int, secondValue: Int)
}

class JAQDiceView: SCNView {

    weak var diceDelegate: JAQDiceProtocol?
    var maximumJumpHeight: CGFloat = 120
    var squareSizeHeight: CGFloat = 60
    var floorImage = UIImage(named: "woodTile")!

    @IBAction func rollTheDice(_: Any) {
        self.dice1.physicsBody?.applyTorque(SCNVector4Make(self.randomJump(), -12, 0, 10), asImpulse: true)
        self.dice2.physicsBody?.applyTorque(SCNVector4Make(self.randomJump(), +10, 0, 10), asImpulse: true)

        self.timesStopped = 0

        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkStatus(_:)), userInfo: nil, repeats: true)
    }

    private var dice1: SCNNode!
    private var dice2: SCNNode!
    private var camera: SCNNode!
    private var timer: Timer?
    private var timesStopped = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.black

        self.loadScene()
    }

    func loadScene() {

        let url = Bundle.main.url(forResource: "Dices", withExtension: "scn")!
        let scene = try! SCNScene(url: url)

        self.timesStopped = 0
        scene.physicsWorld.gravity = SCNVector3Make(0, -980, 0)

        let floorGeometry = SCNFloor()
        floorGeometry.firstMaterial?.diffuse.contents = self.floorImage
        floorGeometry.firstMaterial?.diffuse.mipFilter = .linear

        let floorNode = SCNNode()
        floorNode.geometry = floorGeometry
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        self.dice1 = scene.rootNode.childNode(withName: "Dice_1", recursively: true)
        self.dice1.physicsBody = SCNPhysicsBody.dynamic()

        self.dice2 = scene.rootNode.childNode(withName: "Dice_2", recursively: true)
        self.dice2.physicsBody = SCNPhysicsBody.dynamic()

        self.camera = SCNNode()
        self.camera.camera = SCNCamera()
        self.camera.camera?.zFar = Double(self.maximumJumpHeight * 2)
        self.camera.eulerAngles = SCNVector3Make(-.pi / 2, 0, 0)
        self.camera.rotation = SCNVector4Make(-1, 0, 0, .pi / 3)
        self.camera.position = SCNVector3Make(0, Float(self.maximumJumpHeight - 30), 40)
        scene.rootNode.addChildNode(self.camera)

        let diffuseLightFrontNode = SCNNode()
        diffuseLightFrontNode.light = SCNLight()
        diffuseLightFrontNode.light?.type = .omni
        diffuseLightFrontNode.position = SCNVector3Make(0, Float(self.maximumJumpHeight), Float(self.maximumJumpHeight / 3))
        scene.rootNode.addChildNode(diffuseLightFrontNode)

        self.placeWalls(in: scene, sizeBox: self.squareSizeHeight)

        pointOfView = self.camera
        allowsCameraControl = false

        self.scene = scene

    }

    func placeWalls(in scene: SCNScene, sizeBox size: CGFloat) {
        let left = SCNNode()
        left.position = SCNVector3Make(Float(-size / 2), Float(size / 2), 0)
        left.geometry = SCNBox(width: 1, height: size, length: size, chamferRadius: 0)
        scene.rootNode.addChildNode(left)

        let front = SCNNode()
        front.position = SCNVector3Make(0, Float(size / 2), Float(-size / 2))
        front.geometry = SCNBox(width: size, height: size, length: 1, chamferRadius: 0)
        scene.rootNode.addChildNode(front)

        let right = SCNNode()
        right.position = SCNVector3Make(Float(size / 2), Float(size / 2), 0)
        right.geometry = SCNBox(width: 1, height: size, length: size, chamferRadius: 0)
        scene.rootNode.addChildNode(right)

        let back = SCNNode()
        back.position = SCNVector3Make(0, Float(size / 2), Float(size / 2))
        back.geometry = SCNBox(width: size, height: size, length: 1, chamferRadius: 0)
        scene.rootNode.addChildNode(back)

        let top = SCNNode()
        top.position = SCNVector3Make(0, Float(size), 0)
        top.geometry = SCNBox(width: size, height: 1, length: size, chamferRadius: 0)
        scene.rootNode.addChildNode(top)

        self.applyRigidPhysics(left)
        self.applyRigidPhysics(front)
        self.applyRigidPhysics(right)
        self.applyRigidPhysics(back)
        self.applyRigidPhysics(top)
    }

    func applyRigidPhysics(_ node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node, options: nil))
        node.opacity = 0.0
    }

    func randomJump() -> Float {
        let lowerBound = 260
        let upperBound = 320
        return Float(lowerBound + Int(arc4random()) % (upperBound - lowerBound))
    }

    @objc func checkStatus(_: Any?) {
        let result = self.dice1.jaq_rotatedVector().x
        if (result > 0.95 && result < 1.05) || (result < 0.05 && result > -0.05) || (result > -1.05 && result < -0.95) {

            self.timesStopped += 1

            var threshold = 8
            #if TARGET_IPHONE_SIMULATOR
                threshold = 25
            #endif
            if self.timesStopped > threshold {
                self.timer?.invalidate()
                self.diceDelegate?.diceView(self, rolledWithFirstValue: self.dice1.jaq_boxUpIndex(), secondValue: self.dice2.jaq_boxUpIndex())
            }
        } else {
            self.timesStopped = 0
        }
    }
}
