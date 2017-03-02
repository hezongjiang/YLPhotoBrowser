//
//  PhotoBrowserPhotos.swift
//  PhotoBrowserDemo
//
//  Created by Hearsay on 2017/2/14.
//  Copyright © 2017年 Hearsay. All rights reserved.
//

import UIKit

/// 浏览照片模型
class PhotoBrowserPhotos: NSObject {

    /// 选中照片索引
    var selectedIndex: Int = 0
    
    /// 照片 url 字符串数组
    var urls: [String]?
    
    /// 父视图图像视图数组，便于交互转场
    var parentImageViews: [UIImageView]?
    
}
