import UIKit
import Ikemen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.rootViewController = UITabBarController() ※ {
            $0.viewControllers = [
                UINavigationController(rootViewController: ViewController()) ※ {
                    $0.navigationBar.prefersLargeTitles = true},
                UIViewController() ※ {$0.title = "2"},
                UIViewController() ※ {$0.title = "3"}]
        }
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

