
import UIKit
import SnapKit

protocol OnboardingDelegate: AnyObject {
    func didFinishOnboarding()
}

final class OnboardingPageController: UIPageViewController {
    
    weak var onboardingDelegate: OnboardingDelegate?
    
    private let pagesData: [OnboardingPage] = [
        .init(imageName: "OnboardingFirst",
              title: NSLocalizedString("onboardingPage1Title", comment: "Текст на первом экране онбординга"),
              buttonTitle: NSLocalizedString("onboardingContinueButton", comment: "Кнопка на онбординге")
             ),
        .init(imageName: "OnboardingSecond",
              title: NSLocalizedString("onboardingPage2Title", comment: "Текст на втором экране онбординга"),
              buttonTitle: NSLocalizedString("onboardingContinueButton", comment: "Кнопка на онбординге")
             )
    ]
    
    private lazy var pages: [UIViewController] = pagesData.map {
        let vc = OnboardingViewController(page: $0)
        vc.delegate = self
        return vc
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .blackCastom
        pageControl.pageIndicatorTintColor = UIColor.blackCastom.withAlphaComponent(0.3)
        return pageControl
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
        
        view.addSubview(pageControl)
        addConstraints()
    }
    private func addConstraints() {
        pageControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(638)
            $0.centerX.equalToSuperview()
            
        }
    }
}

extension OnboardingPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        return index > 0 ? pages[index - 1] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        return index < pages.count - 1 ? pages[index + 1] : nil
    }
}

extension OnboardingPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}

extension OnboardingPageController: OnboardingDelegate {
    func didFinishOnboarding() {
        onboardingDelegate?.didFinishOnboarding()
    }
}
