
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let tabBarController = UITabBarController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let trackersVC = ViewController()
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackersIcon"), tag: 0)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statisticsIcon"), tag: 1)
        let trackersNavigationVC = UINavigationController(rootViewController: trackersVC)
        let statisticsNavigationVC = UINavigationController(rootViewController: statisticsVC )
        
        tabBarController.setViewControllers([trackersNavigationVC, statisticsNavigationVC], animated: true)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        appearance.shadowColor = .lightGray
        
        tabBarController.tabBar.standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    tabBarController.tabBar.scrollEdgeAppearance = appearance
                }
                
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        //guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

