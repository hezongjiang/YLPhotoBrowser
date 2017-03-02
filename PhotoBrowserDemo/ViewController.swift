//
//  ViewController.swift
//  PhotoBrowserDemo
//
//  Created by Hearsay on 2017/3/2.
//  Copyright © 2017年 Hearsay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageViews: [UIImageView]!
    
    var urls = ["http://ww2.sinaimg.cn/bmiddle/72635b6agw1eyqehvujq1j218g0p0qai.jpg",
                "http://ww2.sinaimg.cn/bmiddle/e67669aagw1f1v6w3ya5vj20hk0qfq86.jpg",
                "http://ww3.sinaimg.cn/bmiddle/61e36371gw1f1v6zegnezg207p06fqv6.gif",
                "http://ww4.sinaimg.cn/bmiddle/7f02d774gw1f1dxhgmh3mj20cs1tdaiv.jpg"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, imageView) in imageViews.enumerated() {
            let url = URL(string: urls[i])!
            imageView.kf.setImage(with: url)
        }
    }
    
    @IBAction func imageTap(_ sender: UITapGestureRecognizer) {
        
        let browser = PhotoBrowserController(selectedIndex: sender.view?.tag ?? 0, urls: urls, parentImageViews: imageViews)
        
        present(browser, animated: true, completion: nil)
    }


}

