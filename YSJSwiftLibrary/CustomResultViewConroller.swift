//
//  CustomResultViewConroller.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/2/15.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CustomResultViewConroller: GetImagesViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
//        updateSelectArray.removeLast()
        
        let imageView = UIImageView(frame: CGRect(x: 80, y: 200, width: 200, height: 200))
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        PHImageManager.default().requestImage(for: (updateSelectArray.first?.phAsset)!, targetSize: CGSize(width: imageView.frame.width*2, height: imageView.frame.height*2), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) in
            imageView.image = image
        }
    }
    
    deinit {
        print("CustomResultViewConroller  deinit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
