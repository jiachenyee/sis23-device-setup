//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, if, func, for, while, (, ), (), var, let, ., =, <, >, ==, !=, +=, +, -, >=, <=, true, false, swarm, tellos, &&, ||, !)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyUp(cm:), flyDown(cm:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))

_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/

//#-editable-code Tap to enter code.
takeOff()
turnRight(degree: 90)
flyForward(cm: 90)
turnLeft(degree: 90)
flyForward(cm: 200)
turnLeft(degree: 90)
flyForward(cm: 60)
turnLeft(degree: 90)
flyForward(cm: 180)
turnRight(degree: 90)
flyForward(cm: 60)
turnRight(degree: 90)
flyForward(cm: 180)
turnLeft(degree: 90)
flyForward(cm: 60)
turnLeft(degree: 90)
flyForward(cm: 200)
turnLeft(degree: 90)
flyForward(cm: 90)
land()

//#-end-editable-code

//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Flying a drone?\nMove on to learn more skills.\n\n[**Next Page**](@next)",
    comment: "Rotate page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyForward(cm: 200), [
        NSLocalizedString("First you will turn clockwise using `.flyForward(cm: 200)`.", comment: "flyForward(cm:) hint1"),
        NSLocalizedString("Then you will turn counterclockwise using `turnLeft(degree: 90)`.", comment: "turnLeft(degree:) hint2")
        ]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turn(direction TurnDirection.left, angle: 180)` to turn counterclockwise.", comment: "turn(.left) hint")
        ]),
    (.flyForward(cm: 50), [
        NSLocalizedString("First you will turn clockwise using `.flyForward(cm: 200)`.", comment: "flyForward(cm:) hint1"),
        NSLocalizedString("Then you will turn counterclockwise using `turnLeft(degree: 90)`.", comment: "turnLeft(degree:) hint2")
        ]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turn(direction TurnDirection.left, angle: 180)` to turn counterclockwise.", comment: "turn(.left) hint")
        ]),
    (.flyForward(cm: 200), [
        NSLocalizedString("First you will turn clockwise using `.flyForward(cm: 200)`.", comment: "flyForward(cm:) hint1"),
        NSLocalizedString("Then you will turn counterclockwise using `turnLeft(degree: 90)`.", comment: "turnLeft(degree:) hint2")
        ]),
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turn(direction TurnDirection.left, angle: 180)` to turn counterclockwise.", comment: "turn(.left) hint")
        ]),
    (.flyForward(cm: 50), [
        NSLocalizedString("First you will turn clockwise using `.flyForward(cm: 200)`.", comment: "flyForward(cm:) hint1"),
        NSLocalizedString("Then you will turn counterclockwise using `turnLeft(degree: 90)`.", comment: "turnLeft(degree:) hint2")
        ]),
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turn(direction TurnDirection.left, angle: 180)` to turn counterclockwise.", comment: "turn(.left) hint")
        ]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)

//#-end-hidden-code
