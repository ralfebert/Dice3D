import UIKit

class JAQViewController: UIViewController, JAQDiceProtocol {

    @IBOutlet var playground: JAQDiceView!
    @IBOutlet var result: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.playground.diceDelegate = self
    }

    @objc func diceView(_ view: JAQDiceView?, rolledWithFirstValue firstValue: Int, secondValue: Int) {
        self.result.text = String(firstValue + secondValue)
        self.addPopAnimation(to: self.result.layer, withBounce: 0.1, damp: 0.02)
    }

    func addPopAnimation(to aLayer: CALayer?, withBounce bounce: CGFloat, damp: CGFloat) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 1

        let steps = 100
        var values = [NSNumber](repeating: 0, count: steps)
        var value: CGFloat = 0
        let e: CGFloat = 2.71
        for t in 0 ..< 100 {
            value = pow(e, -damp * CGFloat(t)) * sin(bounce * CGFloat(t)) + 1
            values.append(NSNumber(value: Double(value)))
        }
        animation.values = values
        aLayer?.add(animation, forKey: "appearAnimation")
    }
}
