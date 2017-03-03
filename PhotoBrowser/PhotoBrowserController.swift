//
//  PhotoBrowserController.swift
//  PhotoBrowserDemo
//
//  Created by Hearsay on 2017/2/14.
//  Copyright © 2017年 Hearsay. All rights reserved.
//

import UIKit

/// 图片浏览器
public class PhotoBrowserController: UIViewController {

    fileprivate var photos: PhotoBrowserPhotos
    
    fileprivate var animator: PhotoBrowserAnimator
    
    fileprivate var statusBarHidden: Bool = false
    
    fileprivate var currentViewer: PhotoViewerController?
    
    fileprivate lazy var pageCountButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 20, width: 80, height: 30))
        btn.center.x = self.view.center.x
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.backgroundColor = UIColor(white: 0.4, alpha: 0.8)
        return btn
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        label.center = self.view.center
        label.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.transform = CGAffineTransform(scaleX: 0, y: 0)
        return label
    }()
    
    
    public init(selectedIndex: Int, urls: [String], parentImageViews: [UIImageView]) {
        
        photos = PhotoBrowserPhotos()
        photos.selectedIndex = selectedIndex
        photos.urls = urls
        photos.parentImageViews = parentImageViews
        
        animator = PhotoBrowserAnimator(photos: photos)
        
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = animator
        
        modalPresentationStyle = .custom
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupui()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        statusBarHidden = true
        
        UIView.animate(withDuration: 0.25) { 
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override public var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
}

private extension PhotoBrowserController {
    
    func setupui() {
        
        view.backgroundColor = UIColor.black
        
        // 分页控制器
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 10])
        pageController.dataSource = self
        pageController.delegate = self
        
        let viewer = viewerWithIndex(index: photos.selectedIndex)
        
        pageController.setViewControllers([viewer], direction: .forward, animated: true, completion: nil)
        view.addSubview(pageController.view)
        addChildViewController(pageController)
        pageController.didMove(toParentViewController: self)
        
        currentViewer = viewer
        
        // 手势识别
        view.gestureRecognizers = pageController.gestureRecognizers
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tap)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(interactiveGesture(recognizer:)))
        pinch.delegate = self
        view.addGestureRecognizer(pinch)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(interactiveGesture(recognizer:)))
        rotate.delegate = self
        view.addGestureRecognizer(rotate)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(recognizer:)))
        view.addGestureRecognizer(longPress)
        
        view.addSubview(pageCountButton)
        
        view.addSubview(messageLabel)
        
        setPageButtonIndex(index: photos.selectedIndex)
    }
    
    func viewerWithIndex(index: Int) -> PhotoViewerController {
        
        return PhotoViewerController(urlString: photos.urls![index], photoIndex: index, placeholder: photos.parentImageViews![index].image!)
    }
}

// MARK: - 手势操作
private extension PhotoBrowserController {
    
    @objc func tapGesture() {
        animator.fromImageView = currentViewer?.imageView
        dismiss(animated: true, completion: nil)
    }
    
    @objc func interactiveGesture(recognizer: UIGestureRecognizer) {
        
        statusBarHidden = currentViewer!.scrollView.zoomScale > 1
        
        setNeedsStatusBarAppearanceUpdate()
        
        if statusBarHidden {
            
            view.backgroundColor = UIColor.black
            view.transform = CGAffineTransform.identity
            view.alpha = 1
            pageCountButton.isHidden = photos.urls?.count == 1
            
            return
        }
        
        var transform = view.transform
        
        if recognizer.isKind(of: UIPinchGestureRecognizer.self) {
            let pinch = recognizer as! UIPinchGestureRecognizer
            transform = transform.scaledBy(x: pinch.scale, y: pinch.scale)
            
            pinch.scale = 1
        } else if recognizer.isKind(of: UIRotationGestureRecognizer.self) {
            let rotate = recognizer as! UIRotationGestureRecognizer
            transform = transform.rotated(by: rotate.rotation)
            
            rotate.rotation = 0
        }
        
        switch recognizer.state {
        case .began, .changed:
            pageCountButton.isHidden = true
            view.backgroundColor = UIColor.clear
            view.transform = transform
            view.alpha = transform.a
        case .cancelled, .failed, .ended:
            tapGesture()
        default: break
            
        }
    }
    
    @objc func longPressGesture(recognizer: UILongPressGestureRecognizer) {
        
    }
    
    func setPageButtonIndex(index: Int) {
        
        pageCountButton.isHidden = photos.urls?.count == 1
        
        pageCountButton.setTitle("\(index + 1) / \(photos.urls?.count ?? 1)", for: .normal)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PhotoBrowserController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension PhotoBrowserController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? PhotoViewerController else { return UIViewController() }
        
        var index = vc.photoIndex
        
        if index <= 0 { return nil }
        
        index -= 1
        
        return viewerWithIndex(index: index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? PhotoViewerController else { return UIViewController() }
        
        var index = vc.photoIndex
        index += 1
        
        if index >= photos.urls?.count ?? 0 { return nil }
        
        return viewerWithIndex(index: index)
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewer = pageViewController.viewControllers?.first as? PhotoViewerController else { return }
        
        photos.selectedIndex = viewer.photoIndex
        
        currentViewer = viewer
        
        setPageButtonIndex(index: viewer.photoIndex)
    }
}
