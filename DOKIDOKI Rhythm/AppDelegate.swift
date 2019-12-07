import UIKit
import Ikemen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.rootViewController = UITabBarController() ※ {
            $0.viewControllers = [
                UINavigationController(rootViewController: Cinderella5thViewController()) ※ {
                    $0.navigationBar.prefersLargeTitles = true},
                UIViewController() ※ {$0.title = "2"},
                UIViewController() ※ {$0.title = "3"}]
        }
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

