//
//  RoutesViewController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 29.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import FloatingPanel

class RoutesPanelBehavior: FloatingPanelBehavior {
    
    private func shouldProjectMomentum(_ fpc: FloatingPanelController, for proposedTargetPosition: FloatingPanelPosition) -> Bool {
        return true
    }
    
    var removalVelocity: CGFloat {
        return 0
    }
    
    var removalProgress: CGFloat {
        return 0.2
    }
}

class RoutesViewController: UIPageViewController {
    
    weak var metroService: MetroService?
    
    var onPageChange: ((Int) -> ())?
    var onClose : (()->())?
    
    var routes = [ShortRoute]() {
        didSet {
            routePageControl.numberOfPages = routes.count
            routePageControl.set(progress: currentIndex, animated: true)
            setViewControllers([controllers[currentIndex]], direction: .forward, animated: true, completion: nil)
        }
    }
    var currentIndex = 0
    
    weak var parentPanelController: FloatingPanelController? {
        didSet {
            guard let view = controllers[currentIndex] as? RouteDetailsController else { return }
            self.parentPanelController?.track(scrollView: view.routeDetailsView.tableView)
        }
    }
    
    private let routePageControl: CHIPageControlAji = {
        let pageControl = CHIPageControlAji()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 1
        pageControl.borderWidth = 1
        pageControl.radius = 3.5
        pageControl.inactiveTransparency = 0
        pageControl.tintColor = .mm_TextPrimary
        pageControl.backgroundColor = .clear
        pageControl.currentPageTintColor = .mm_TextPrimary
        return pageControl
    }()
    
    private lazy var controllers: [UIViewController] = {
        var viewControllers = [RouteDetailsController]()
        var index = 0
        routes.forEach {
            let detailsController = RouteDetailsController()
            guard let service = self.metroService else { return }
            detailsController.metroService = service
            detailsController.route = $0
            detailsController.index = index
            viewControllers.append(detailsController)
            index += 1
        }
        return viewControllers
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.delegate = self
        self.dataSource = self
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIBarButtonItem {

    static func menuButton(_ target: Any?, action: Selector, image: UIImage) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true

        return menuBarItem
    }
}

extension RoutesViewController {
    
    private func setup() {
        view.backgroundColor = .navigationBar
        let leftBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(self.close), image: UIImage(named: "arrow down templatte", in: .mm_Map, compatibleWith: nil)!)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = .mm_Main
        self.navigationItem.titleView = routePageControl
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc
    private func close() {
        self.onClose?()
        dismiss(animated: true, completion: nil)
    }
}

extension RoutesViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let currentVC = pageViewController.viewControllers?.first as? RouteDetailsController else { return }
            self.parentPanelController?.track(scrollView: currentVC.routeDetailsView.tableView)
            self.onPageChange?(currentVC.index)
            self.routePageControl.set(progress: currentVC.index, animated: true)
        }
    }
}

extension RoutesViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? RouteDetailsController else { return nil }
        if let index = controllers.firstIndex(of: controller) {
            if index > 0 {
                return controllers[index-1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? RouteDetailsController else { return nil }
        if let index = controllers.firstIndex(of: controller) {
            if index < (routes.count) - 1 {
                return controllers[index + 1]
            }
        }
        return nil
    }
}
