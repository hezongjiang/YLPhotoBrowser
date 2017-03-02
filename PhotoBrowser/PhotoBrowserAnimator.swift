//
//  PhotoBrowserAnimator.swift
//  PhotoBrowserDemo
//
//  Created by Hearsay on 2017/2/14.
//  Copyright © 2017年 Hearsay. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoBrowserAnimator: NSObject {
    
    var fromImageView: UIImageView?
    
    var isPresenting: Bool = false
    
    var photos: PhotoBrowserPhotos
    
    
    init(photos: PhotoBrowserPhotos) {
        
        self.photos = photos
        
        super.init()
    }

}

// MARK: - UIViewControllerTransitioningDelegate
extension PhotoBrowserAnimator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = true
        
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = false
        
        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? presentTransition(transitionContext: transitionContext) : dismissTransition(transitionContext: transitionContext)
    }
}


private extension PhotoBrowserAnimator {
    
    /// 展现转场动画方法
    func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let dummyIV = dummyImageView()
        let parentIV = parentImageView()
        dummyIV.frame = containerView.convert(parentIV!.frame, from: parentIV?.superview)
        containerView.addSubview(dummyIV)
        
        let toView = transitionContext.view(forKey: .to)
        containerView.addSubview(toView!)
        toView?.alpha = 0.0;
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            dummyIV.frame = self.presentRectWithImageView(imageView: dummyIV)
        }) { (_) in
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                toView?.alpha = 1
            }, completion: { (_) in
                dummyIV.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
    
    /// 根据图像计算展现目标尺寸
    func presentRectWithImageView(imageView: UIImageView) -> CGRect {
        
        let image = imageView.image
        
        guard let img = image else {
            return imageView.frame
        }
        
        let screenSize = UIScreen.main.bounds.size
        var imageSize = screenSize
        
        imageSize.height = img.size.height * imageSize.width / img.size.width
        
        var rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        if imageSize.height < screenSize.height {
            rect.origin.y = (screenSize.height - imageSize.height) * 0.5
        }
        return rect
    }
    
    
    /// 生成 dummy 图像
    func dummyImage() -> UIImage? {
        
        guard let key = photos.urls?[photos.selectedIndex] else { return nil }
        
        var image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: key)
        
        if image == nil {
            image = parentImageView()?.image
        }
        return image
    }
    
    /// 生成 dummy 图像视图
    func dummyImageView() -> UIImageView {
        
        let iv = UIImageView(image: dummyImage())
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }
    
    /// 父视图参考图像视图
    func parentImageView() -> UIImageView? {
        return photos.parentImageViews?[photos.selectedIndex]
    }
    
    
    /// 解除转场动画方法
    func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        
        let dummyIV = dummyImageView()
        dummyIV.frame = containerView.convert(fromImageView!.frame, from: fromImageView?.superview)
        dummyIV.alpha = fromView!.alpha
        containerView.addSubview(dummyIV)
        
        fromView?.removeFromSuperview()
        
        let parentIV = parentImageView()
        let targetRect = containerView.convert(parentIV!.frame, from: parentIV?.superview)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
            dummyIV.frame = targetRect
            dummyIV.alpha = 1
            
        }) { (_) in
            
            dummyIV.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}









