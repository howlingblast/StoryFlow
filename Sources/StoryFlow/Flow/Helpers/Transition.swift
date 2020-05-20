import Foundation
import UIKit

public struct Transition<To: UIViewController> {
    let go: (UIViewController, To) -> ()
}

// MARK: - Initializers

extension Transition {

    public static func custom(_: To.Type, transition: @escaping (UIViewController, To) -> ()) -> Transition {
        return Transition(go: transition)
    }

    public static func show(_: To.Type) -> Transition {
        return Transition { $0.show($1, sender: nil) }
    }

    public static func present(_: To.Type, animated: Bool = true) -> Transition {
        return Transition { $0.present($1, animated: animated) }
    }
}

extension Transition where To == UIViewController {

    public static func unwind(animated: Bool = true) -> Transition {
        return Transition {

            let parentInTab = $1.parentInTabBarController
            let isWrongTab = parentInTab != $1.tabBarController?.selectedViewController
            let isPresenting = $1.presentedViewController != nil && $1.presentedViewController?.isBeingPresented == false

            // 1. Navigation pop
            if let nav = $1.navigationController {
                let animatedPop = animated && !isPresenting && !isWrongTab
                nav.popToViewController($1, animated: animatedPop)
            }

            // 2. Tab change
            if isWrongTab {
                $1.tabBarController?.selectedViewController = parentInTab
            }

            // 3. Presented dismiss
            if isPresenting {
                $1.dismiss(animated: animated, completion: nil)
            }
        }
    }
}

private extension UIViewController {

    var parentInTabBarController: UIViewController? {
        self.parent == self.tabBarController ? self : self.parent?.parentInTabBarController
    }
}
