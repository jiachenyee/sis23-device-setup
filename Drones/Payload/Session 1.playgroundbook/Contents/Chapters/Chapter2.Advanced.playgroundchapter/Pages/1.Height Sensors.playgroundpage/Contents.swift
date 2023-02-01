//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, getHeight())
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/

//#-editable-code Tap to enter code.
takeOff()
wait(seconds: 3)
getHeight()
land()
//#-end-editable-code

//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Well done!\nYou've learned your first getter command.\n\n[**Next Page**](@next)",
    comment: "Height Sensors page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.getHeight, [NSLocalizedString("To get height of drone you need to use the `getHeight()` command.", comment: "getHeight hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
