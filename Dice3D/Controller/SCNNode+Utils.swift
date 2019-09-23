import GLKit
import SceneKit

extension SCNNode {
    func jaq_boxUpIndex() -> Int {
        let rotatedUp = self.jaq_rotatedVector()
        let boxNormals = [
            GLKVector3Make(0, -1, 0),
            GLKVector3Make(0, 0, 1),
            GLKVector3Make(-1, 0, 0),
            GLKVector3Make(1, 0, 0),
            GLKVector3Make(0, 0, -1),
            GLKVector3Make(0, 1, 0),
        ]

        var bestIndex = 0
        var maxDot: Float = -1

        for i in 0 ..< 6 {
            let dot = GLKVector3DotProduct(boxNormals[i], rotatedUp)
            if dot > maxDot {
                maxDot = dot
                bestIndex = i
            }
        }

        bestIndex += 1
        return bestIndex
    }

    func jaq_rotatedVector() -> GLKVector3 {
        let rotation = presentation.rotation
        var invRotation = rotation
        invRotation.w = -invRotation.w
        let up = SCNVector3Make(0, 1, 0)
        let transform = SCNMatrix4MakeRotation(invRotation.w, invRotation.x, invRotation.y, invRotation.z)
        let glkTransform = SCNMatrix4ToGLKMatrix4(transform)
        let glkUp = SCNVector3ToGLKVector3(up)
        return GLKMatrix4MultiplyVector3(glkTransform, glkUp)
    }
}
