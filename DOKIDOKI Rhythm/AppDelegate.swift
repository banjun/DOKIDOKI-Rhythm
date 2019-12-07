import UIKit
import Ikemen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.rootViewController = UITabBarController() ※ {
            $0.viewControllers = [
                UINavigationController(rootViewController: Cinderella7thViewController()) ※ {
                    $0.tabBarItem.title = "7th"
                    $0.navigationBar.prefersLargeTitles = true},
                UINavigationController(rootViewController: Cinderella6thViewController()) ※ {
                    $0.tabBarItem.title = "6th"
                    $0.navigationBar.prefersLargeTitles = true},
                UINavigationController(rootViewController: Cinderella5thViewController()) ※ {
                    $0.tabBarItem.title = "5th"
                    $0.navigationBar.prefersLargeTitles = true}]
        }
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

