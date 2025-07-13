
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let tabBarController = UITabBarController()
    private let colors = Colors()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackersIcon"), tag: 0)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statisticsIcon"), tag: 1)
        let trackersNavigationVC = UINavigationController(rootViewController: trackersVC)
        let statisticsNavigationVC = UINavigationController(rootViewController: statisticsVC )
        
        tabBarController.setViewControllers([trackersNavigationVC, statisticsNavigationVC], animated: true)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colors.viewBackgroundColor
        appearance.shadowColor = .lightGray
        
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        
        window = UIWindow(windowScene: windowScene)
        if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    window?.rootViewController = tabBarController
                } else {
                    let onboarding = OnboardingPageController()
                    onboarding.onboardingDelegate = self
                    window?.rootViewController = onboarding
                }
        
//        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: OnboardingDelegate {
    func didFinishOnboarding() {
        window?.rootViewController = tabBarController
    }
}

