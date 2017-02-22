//
//  EditHeadImageViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/1/10.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

class EditHeadImageViewController: UIViewController, UIScrollViewDelegate {
    
    var headImage: UIImage!
    
    let clipView = UIView()
    let scroll = UIScrollView()
    let imageView = UIImageView()
    let topShadowView = UIView()
    let bottomShadowView = UIView()
    let leftShadowView = UIView()
    let rightShadowView = UIView()
    let bottomView = UIView()
    let sureBtn = UIButton()
    let cancelBtn = UIButton()
    
    
    var updateSelectArray: [ImageCellModel] = []
    var isComingFromDetail = false
    
    var chooseHeadImageClosure: ( (UIImage, EditHeadImageViewController?) -> () )?
    
    
    // MARK: - ScreenDirectionChanged Listener Method
    //转屏监听
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width == view.frame.width {
            return
        }
        directionChanged(size: size)
    }
    
    func directionChanged(size: CGSize) {
        scroll.setZoomScale(1, animated: false)
        scroll.contentSize = size
        
        var imgViewW = CGFloat(0)
        var imgViewH = CGFloat(0)
        if headImage.size.width >= headImage.size.height*size.width/size.height{
            //当 w >= W*h/H，即宽度过大时，以宽度为基准调整imageView的高度
            imgViewW = size.width
            imgViewH = headImage.size.height * imgViewW / headImage.size.width
            imageView.frame = CGRect(x: 0, y: (size.height-imgViewH)/2, width: imgViewW, height: imgViewH)
        }else{
            //其余情况以高度为基准调整imageView的宽度
            imgViewH = size.height
            imgViewW = headImage.size.width * imgViewH / headImage.size.height
            imageView.frame = CGRect(x: (size.width-imgViewW)/2, y: 0, width: imgViewW, height: imgViewH)
        }
    }
    
    // MARK: - LifeCircle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollViewDidZoom(scroll)
        //改变contentOffset 使其长度过长时保持居中
        UIApplication.shared.setStatusBarHidden(true, with: .slide)
        if imageView.frame.height > scroll.frame.height {
            scroll.contentOffset = CGPoint(x: 0, y: (imageView.frame.height-scroll.frame.height)/2)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    func initView() {
        guard (headImage != nil) else {
            return
        }
        view.backgroundColor = UIColor.black
        view.clipsToBounds = true
        
        clipView.backgroundColor = UIColor.clear
        clipView.layer.borderColor = UIColor.white.cgColor
        clipView.layer.borderWidth = 1
        view.addSubview(clipView)
        
        scroll.delegate = self
        scroll.maximumZoomScale = 3
        scroll.minimumZoomScale = 1
        scroll.contentSize = view.frame.size
        scroll.isScrollEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.layer.borderColor = UIColor.white.cgColor
        scroll.layer.borderWidth = 1
        scroll.backgroundColor = UIColor.black
        clipView.addSubview(scroll)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapClick))
        doubleTap.numberOfTapsRequired = 2
        scroll.addGestureRecognizer(doubleTap)
        
        //imageView
        imageView.image = headImage
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        
        //imageView
        directionChanged(size: view.frame.size)
        scroll.addSubview(imageView)
        
        //周围阴影
        topShadowView.alpha = 0.5
        topShadowView.backgroundColor = UIColor.black
        view.addSubview(topShadowView)
        
        bottomShadowView.alpha = 0.5
        bottomShadowView.backgroundColor = UIColor.black
        view.addSubview(bottomShadowView)
        
        leftShadowView.alpha = 0.5
        leftShadowView.backgroundColor = UIColor.black
        view.addSubview(leftShadowView)
        
        rightShadowView.alpha = 0.5
        rightShadowView.backgroundColor = UIColor.black
        view.addSubview(rightShadowView)
        
        //底部按钮栏
        bottomView.backgroundColor = ipColorFromHex(hex: IPHexColorDetailTopView, alpha: 0.5)
        view.addSubview(bottomView)
        
        cancelBtn.setTitle(IPStringCancel, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        bottomView.addSubview(cancelBtn)
        
        sureBtn.setTitle(IPStringComplete, for: .normal)
        sureBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        sureBtn.setTitleColor(UIColor.white, for: .normal)
        sureBtn.backgroundColor = UIColor.clear
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        bottomView.addSubview(sureBtn)
    }
    
    func initConstraint() {
        let shortLength = view.frame.width < view.frame.height ? view.frame.width : view.frame.height
        
        clipView.translatesAutoresizingMaskIntoConstraints = false
        
        let clipViewCenterXConstraint = NSLayoutConstraint(item: clipView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let clipViewCenterYConstraint = NSLayoutConstraint(item: clipView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let clipViewWidthConstraint = NSLayoutConstraint(item: clipView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: shortLength-2)
        
        let clipViewHeightConstraint = NSLayoutConstraint(item: clipView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: shortLength-2)
        
        clipViewCenterXConstraint.isActive = true
        clipViewCenterYConstraint.isActive = true
        clipViewWidthConstraint.isActive = true
        clipViewHeightConstraint.isActive = true
        
        
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollViewCenterXConstraint = NSLayoutConstraint(item: scroll, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let scrollViewCenterYConstraint = NSLayoutConstraint(item: scroll, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let scrollViewWidthConstraint = NSLayoutConstraint(item: scroll, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: +2)
        
        let scrollViewHeightConstraint = NSLayoutConstraint(item: scroll, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: +2)
        
        scrollViewCenterXConstraint.isActive = true
        scrollViewCenterYConstraint.isActive = true
        scrollViewWidthConstraint.isActive = true
        scrollViewHeightConstraint.isActive = true
        
        
        topShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        let topShadowViewLeftConstraint = NSLayoutConstraint(item: topShadowView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let topShadowViewRightConstraint = NSLayoutConstraint(item: topShadowView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        let topShadowViewTopConstraint = NSLayoutConstraint(item: topShadowView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        
        let topShadowViewBottomConstraint = NSLayoutConstraint(item: topShadowView, attribute: .bottom, relatedBy: .equal, toItem: clipView, attribute: .top, multiplier: 1.0, constant: 0)
        
        topShadowViewLeftConstraint.isActive = true
        topShadowViewRightConstraint.isActive = true
        topShadowViewTopConstraint.isActive = true
        topShadowViewBottomConstraint.isActive = true
        
        
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomShadowViewLeftConstraint = NSLayoutConstraint(item: bottomShadowView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let bottomShadowViewRightConstraint = NSLayoutConstraint(item: bottomShadowView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        let bottomShadowViewTopConstraint = NSLayoutConstraint(item: bottomShadowView, attribute: .top, relatedBy: .equal, toItem: clipView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let bottomShadowViewBottomConstraint = NSLayoutConstraint(item: bottomShadowView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        bottomShadowViewLeftConstraint.isActive = true
        bottomShadowViewRightConstraint.isActive = true
        bottomShadowViewTopConstraint.isActive = true
        bottomShadowViewBottomConstraint.isActive = true
        
        
        leftShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        let leftShadowViewLeftConstraint = NSLayoutConstraint(item: leftShadowView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let leftShadowViewRightConstraint = NSLayoutConstraint(item: leftShadowView, attribute: .right, relatedBy: .equal, toItem: clipView, attribute: .left, multiplier: 1.0, constant: 0)
        
        let leftShadowViewTopConstraint = NSLayoutConstraint(item: leftShadowView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        
        let leftShadowViewBottomConstraint = NSLayoutConstraint(item: leftShadowView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        leftShadowViewLeftConstraint.isActive = true
        leftShadowViewRightConstraint.isActive = true
        leftShadowViewTopConstraint.isActive = true
        leftShadowViewBottomConstraint.isActive = true
        
        
        rightShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        let rightShadowViewLeftConstraint = NSLayoutConstraint(item: rightShadowView, attribute: .left, relatedBy: .equal, toItem: clipView, attribute: .right, multiplier: 1.0, constant: 0)
        
        let rightShadowViewRightConstraint = NSLayoutConstraint(item: rightShadowView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        let rightShadowViewTopConstraint = NSLayoutConstraint(item: rightShadowView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        
        let rightShadowViewBottomConstraint = NSLayoutConstraint(item: rightShadowView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        rightShadowViewLeftConstraint.isActive = true
        rightShadowViewRightConstraint.isActive = true
        rightShadowViewTopConstraint.isActive = true
        rightShadowViewBottomConstraint.isActive = true
        
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomViewLeftConstraint = NSLayoutConstraint(item: bottomView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let bottomViewRightConstraint = NSLayoutConstraint(item: bottomView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        let bottomViewBottomConstraint = NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let bottomViewHeightConstraint = NSLayoutConstraint(item: bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: ipFitSize(IPCGFloatDetailBottomViewHeight))
        
        bottomViewLeftConstraint.isActive = true
        bottomViewRightConstraint.isActive = true
        bottomViewBottomConstraint.isActive = true
        bottomViewHeightConstraint.isActive = true
        
        
        sureBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let sureBtnRightConstraint = NSLayoutConstraint(item: sureBtn, attribute: .right, relatedBy: .equal, toItem: bottomView, attribute: .right, multiplier: 1.0, constant: 0)
        
        let sureBtnBottomConstraint = NSLayoutConstraint(item: sureBtn, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let sureBtnTopConstraint = NSLayoutConstraint(item: sureBtn, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1.0, constant: 0)
        
        let sureBtnWidthConstraint = NSLayoutConstraint(item: sureBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 80)
        
        sureBtnRightConstraint.isActive = true
        sureBtnBottomConstraint.isActive = true
        sureBtnTopConstraint.isActive = true
        sureBtnWidthConstraint.isActive = true
        
        
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelBtnLeftConstraint = NSLayoutConstraint(item: cancelBtn, attribute: .left, relatedBy: .equal, toItem: bottomView, attribute: .left, multiplier: 1.0, constant: 0)
        
        let cancelBtnBottomConstraint = NSLayoutConstraint(item: cancelBtn, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let cancelBtnTopConstraint = NSLayoutConstraint(item: cancelBtn, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1.0, constant: 0)
        
        let cancelBtnWidthConstraint = NSLayoutConstraint(item: cancelBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 80)
        
        cancelBtnLeftConstraint.isActive = true
        cancelBtnBottomConstraint.isActive = true
        cancelBtnTopConstraint.isActive = true
        cancelBtnWidthConstraint.isActive = true
    }
    
    // MARK: - btn click Method
    func doubleTapClick() {
        let zoom = scroll.zoomScale > scroll.minimumZoomScale ? scroll.minimumZoomScale : scroll.maximumZoomScale
        scroll.setZoomScale(zoom, animated: true)
    }
    
    func cancelBtnClick() {
        if isComingFromDetail{
            navigationController?.setNavigationBarHidden(true, animated: false)
        }else{
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
        hidesBottomBarWhenPushed = true
        _ = navigationController?.popViewController(animated: true)
    }
    
    func sureBtnClick() {
        UIGraphicsBeginImageContextWithOptions(clipView.frame.size, false, 0.0)
        clipView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let closure = chooseHeadImageClosure {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            _ = navigationController?.popToRootViewController(animated: true)
            closure(newImage!, self)
        }
    }
    
    // MARK: - ScrollViewDelegate Method
    func viewForZooming(in scroll: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scroll: UIScrollView) {
        //缩放后重置imageView中心点
        let offX = (scroll.bounds.size.width > scroll.contentSize.width) ?  (scroll.bounds.size.width - scroll.contentSize.width) * 0.5 : 0
        let offY = (scroll.bounds.size.height > scroll.contentSize.height) ?
            (scroll.bounds.size.height - scroll.contentSize.height) * 0.5 : 0
        imageView.center = CGPoint(x: scroll.contentSize.width*0.5+offX, y: scroll.contentSize.height*0.5+offY)
    }
}


