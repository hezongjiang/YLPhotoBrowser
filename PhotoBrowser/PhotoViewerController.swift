//
//  PhotoViewerController.swift
//  PhotoBrowserDemo
//
//  Created by Hearsay on 2017/2/14.
//  Copyright © 2017年 Hearsay. All rights reserved.
//

import UIKit

/// 单张照片查看控制器 - 显示单张照片使用
class PhotoViewerController: UIViewController {

    var photoIndex: Int = 0
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: self.view.bounds)
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.maximumZoomScale = 2.0;
        sv.minimumZoomScale = 1.0;
        sv.delegate = self;
        return sv
    }()
    
    lazy var imageView = UIImageView()
    
    private lazy var progressView: PhotoProgressView = {
        let progressV = PhotoProgressView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        progressV.center = self.view.center
        progressV.progress = 1
        return progressV
    }()
    
    fileprivate var url: URL?
    fileprivate var placeholder: UIImage
    
    init(urlString: String, photoIndex: Int, placeholder: UIImage) {
        
        url = URL(string: urlString)
        self.placeholder = UIImage.init(cgImage: placeholder.cgImage!, scale: 1, orientation: placeholder.imageOrientation)
        self.photoIndex = photoIndex
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(progressView)
        
        guard let url = url else { return }
        
        imageView.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(1))], progressBlock: nil) { (image, _, _, _) in
            
            if image != nil { self.setImagePosition(image: image!) }
        }
    }
    
    private func setImagePosition(image: UIImage) {
        
        var size = UIScreen.main.bounds.size
        size.height = image.size.height * size.width / image.size.width
        
        imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        scrollView.contentSize = size
        
        if size.height < scrollView.bounds.height {
            let offsetY = (scrollView.bounds.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsetsMake(offsetY, 0, offsetY, 0)
        }
    }
}

extension PhotoViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
