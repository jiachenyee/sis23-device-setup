//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(literal, show, array)
//#-code-completion(currentmodule, show)
//#-code-completion(description, show, "[Int]")
//#-code-completion(identifier, show, if, func, for, while, (, ), (), var, let, ., =, <, >, ==, !=, +=, +, -, >=, <=, true, false, swarm, tellos, &&, ||, !)

//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
//#-code-completion(identifier, show, sync(seconds:))
//#-code-completion(identifier, show, transit(x:y:z:pad1:pad2:))
//#-code-completion(identifier, show, scan(number:))
//_setup()
_setupMultipleDronesEnv()
startMultipleDronesAssessor()
let swarm = TelloManager
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 */

//#-editable-code Tap to enter code.
swarm.scan(number: 2)
swarm.tellos.takeOff()
swarm.tellos[0].flyUp(cm:25)
swarm.tellos[1].flyDown(cm:25)

swarm.sync(seconds: 10)
for i in 1..<3 {
    swarm.tellos[0].flyDown(cm:50)
    swarm.tellos[1].flyUp(cm:50)
    
    swarm.sync(seconds: 10)
    
    swarm.tellos[0].flyUp(cm:50)
    swarm.tellos[1].flyDown(cm:50)
    
    swarm.sync(seconds: 10)
}
swarm.tellos[0].flyDown(cm:25)
swarm.tellos[1].flyUp(cm:25)
swarm.sync(seconds: 10)
swarm.tellos.land()
//#-end-editable-code


//#-hidden-code
_cleanMultipleDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou just made multiple drones dance!\n\n[**Next Page**](@next)",
    comment: "3.Control the Flow page success")

var expected: [Assessor.Assessment] = []

for _ in 0..<swarm.tellos.count {
    expected.append((.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]))
}

expected.append((
    .flyUp(cm: 25),
    [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
))

expected.append((
    .flyDown(cm: 25),
    [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
))

for _ in 1..<3 {
    expected.append((.flyDown(cm: 50),
                     [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
    ))
    expected.append((.flyUp(cm: 50),
                     [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
    ))

    expected.append((.flyUp(cm: 50),
                     [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
    ))
    expected.append((.flyDown(cm: 50),
                     [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
    ))
}

expected.append((
    .flyDown(cm: 25),
    [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
))

expected.append((
    .flyUp(cm: 25),
    [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
))

for _ in 0..<swarm.tellos.count {
    expected.append((.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]))
}

PlaygroundPage.current.assessmentStatus = checkMultipleDronesAssessment(expected:expected, success: success)
//#-end-hidden-code
