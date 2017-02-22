//
//  ImageDetailViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import UIKit
import Photos


public let updateArrayDetailVCNotificationName = Notification.Name("updateArrayDetailVCNotificationName")
public let updateArrayDetailVCUserInfoKey = "updateArrayDetailVCUserInfoKey"

public let changeScreenDirectionNotificationName = Notification.Name("changeScreenDirectionNotificationName")
public let changeScreenDirectionUserInfoKey = "changeScreenDirectionUserInfoKey"

struct SinglePage {
    var pageScrollView: UIScrollView = UIScrollView()
    var pageImageView: UIImageView = UIImageView()
    var pageBtn: UIButton?
    var clearImage: UIImage?
}

class ImageDetailViewController: UIViewController, UIScrollViewDelegate{
    //原始数组  外部传入
    var cellModelArray: [ImageCellModel]!
    //被选中的数组   外部传入，传到外部再进行更新
    var updateSelectArray: [ImageCellModel] = []
    //外部进入时，锚点图片的下标
    var comingIndex = 0
    
    
    //下标对比字典 key:外部传入的cellModelArray元素的下标值(同时也是index值)，value:内部detailArray的元素的下标值，-1表示不在内部元素内
    var indexCompareDic: [Int: Int] = [:]
    //应该显示的数组   内部筛选
    var detailArray: [ImageCellModel] = []
    //单页scroll相关元素的字典
    var pageViewDic: [Int: SinglePage] = [:]
    //查看过的视频文件的dic
    var avPlayItemDic: [Int: AVPlayerItem] = [:]
    //以锚点图片下标计算得到的内部图片显示下标，用于显示
    var detailArrayOffSetIndex = 0
    //当前页面下标
    var currentIndex = 0
    //最大选择图片数量
    var maxChooseNum = 9
    //初始化前后图片数量
    let scrollPagePrepareNum = 3
    //是否正在转屏
    var isTransition = false
    //根据vc隐藏或显示而改变，从而控制scroll不进入不必要的delegate
    var isViewControllerShow = true
    //根据之前选择的模式，传入的选择模式
    var chooseType: ChooseType = .headImageType
    //头像选择模式下的单个选中图片
    var singleChooseImage: UIImage?
    //外部传入的头像选择模式下的处理闭包
    public var chooseHeadImageClosure: ( (UIImage, EditHeadImageViewController?) -> () )?
    //外部传入的分享模式下的处理闭包
    var chooseImagesClosure: ( ([PHAsset], GetImagesViewController?) -> () )?
    //用户自定义结果viewcontroller
    var customResultVCName: String = ""
    
    
    let widthConstraintKey = "widthConstraintKey"
    let heightConstraintKey = "heightConstraintKey"
    let scrollCenterXConstrsintKey = "scrollCenterXConstrsintKey"
    
    
    
    let topView = UIView()
    let bottomView = UIView()
    let scrollView = UIScrollView()
    let selectNumLabel = UILabel()
    //右上选择按钮的遮盖view 图片被选中，hidden为true
    let selectBackImageView = UIImageView()
    let sureBtn = UIButton()
    let videoView = UIView()
    let avPlayer = AVPlayer()
    let backBtn = UIButton()
    let selectBtn = UIButton()
    let avLayer = AVPlayerLayer()
    let singleChooseImageView = UIImageView()
    //转屏时视觉效果结构体
    var coverSinglePage = SinglePage()
    
    
    // MARK: - LifeCircle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotification()
        initData()
        initView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: .slide)
        isViewControllerShow = true
        reloadSureBtnText(count: updateSelectArray.count)
        updateSelectNumLabelStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isViewControllerShow = false
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        for item in avPlayItemDic {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
        NotificationCenter.default.removeObserver(self, name: updateArrayDetailVCNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: changeScreenDirectionNotificationName, object: nil)
        print("ImageDetailViewController  deinit")
    }
    
    // MARK: - ScreenDirectionChanged Listener Method
    //转屏监听
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width == view.frame.width {
            return
        }
        directionChanged(size: size)
    }
    
    func directionChanged(size: CGSize) {
        isTransition = true
        //若为视频文件，转屏时需显示播放按钮
        coverSinglePage.pageBtn?.isHidden = detailArray[currentIndex].modelType == .videoAssetModel ? false : true
        //转屏时视觉效果结构体 coverSinglePage 的初始化
        if let currentPage = pageViewDic[currentIndex] {
            coverSinglePage.pageScrollView.contentSize = size
            coverSinglePage.pageScrollView.setZoomScale(currentPage.pageScrollView.zoomScale, animated: false)
            coverSinglePage.pageScrollView.contentOffset = currentPage.pageScrollView.contentOffset
            coverSinglePage.pageImageView.image = currentPage.pageImageView.image
        }
        coverSinglePage.pageScrollView.isHidden = false
        
        scrollView.contentSize = CGSize(width: size.width * CGFloat(detailArray.count), height: size.height)
        
        for keyIndex in pageViewDic.keys {
            guard let singlePage = pageViewDic[keyIndex] else {
                continue
            }
            guard let image = singlePage.pageImageView.image else { continue
            }
            print("keyIndex:\(keyIndex)")
            singlePage.pageScrollView.frame = CGRect(x: CGFloat(keyIndex)*size.width, y: 0, width: size.width, height: size.height)
            singlePage.pageScrollView.setZoomScale(1, animated: false)
            singlePage.pageScrollView.contentSize = size
            
            var imgViewW = CGFloat(0)
            var imgViewH = CGFloat(0)
            if image.size.width >= image.size.height*size.width/size.height{
                //当 w >= W*h/H，即宽度过大时，以宽度为基准调整imageView的高度
                imgViewW = size.width
                imgViewH = image.size.height * imgViewW / image.size.width
                singlePage.pageImageView.frame = CGRect(x: 0, y: (size.height-imgViewH)/2, width: imgViewW, height: imgViewH)
            }else{
                //其余情况以高度为基准调整imageView的宽度
                imgViewH = size.height
                imgViewW = image.size.width * imgViewH / image.size.height
                singlePage.pageImageView.frame = CGRect(x: (size.width-imgViewW)/2, y: 0, width: imgViewW, height: imgViewH)
            }
            
            if singlePage.pageBtn != nil {
                singlePage.pageBtn?.frame = singlePage.pageImageView.frame
                avLayer.frame = CGRect(origin: CGPoint.zero, size: size)
            }
        }
        
        self.scrollView.setContentOffset(CGPoint(x: size.width * CGFloat(self.currentIndex), y: 0), animated: false)
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.5) {
            self.coverSinglePage.pageScrollView.isHidden = true
            self.isTransition = false
        }
    }
    
    // MARK: - Notification Method
    func initNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateArrayDetailVC(notification:)), name: updateArrayDetailVCNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeScreenDirectionNotification(notification:)), name: changeScreenDirectionNotificationName, object: nil)
    }
    
    func changeScreenDirectionNotification(notification: Notification) {
        let size = notification.userInfo?[changeScreenDirectionUserInfoKey] as! CGSize
        directionChanged(size: size)
    }
    
    func updateArrayDetailVC(notification: Notification) {
        let updateArray: [ImageCellModel] = notification.userInfo?[updateArrayDetailVCUserInfoKey] as! Array
        //将老的更新数组内元素的选中全部设置为未选中
        for cellModel in updateSelectArray {
            if let index = indexCompareDic[cellModel.index] {
                detailArray[index].isSelected = false
            }else{
                continue
            }
        }
        //将新的更新数组内元素的选中全部设置为选中
        for cellModel in updateArray {
            if let index = indexCompareDic[cellModel.index] {
                detailArray[index].isSelected = true
            }else{
                continue
            }
        }
        updateSelectArray = updateArray
        scrollViewDidScroll(scrollView)
        reloadSureBtnText(count: updateSelectArray.count)
        updateSelectNumLabelStatus()
    }
    
    func addtNotification(avPlayerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayItemDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayerItem)
    }
    
    func avPlayItemDidEnd() {
        videoView.isHidden = true
        topView.isHidden = false
        bottomView.isHidden = false
        avPlayer.seek(to: kCMTimeZero)
        avPlayer.replaceCurrentItem(with: nil)
    }
    
    // MARK: - Custom Method
    func initData() {
        for cellModel in cellModelArray {
            //构建显示数组
            if cellModel.modelType == .cameraModel || cellModel.modelType == .addModel{
                indexCompareDic[cellModel.index] = -1
                continue
            }
            detailArray.append(cellModel)
            indexCompareDic[cellModel.index] = detailArray.count-1
            //确定从外部点击进入的素材在显示数组内的下标
            if cellModel.index == comingIndex {
                detailArrayOffSetIndex = detailArray.count-1
                currentIndex = detailArray.count-1
            }
        }
    }
    
    func initConstraint() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollTopConstraint = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        
        let scrollBottomConstraint = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let scrollLeftConstraint = NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let scrollRightConstraint = NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        scrollTopConstraint.isActive = true
        scrollBottomConstraint.isActive = true
        scrollLeftConstraint.isActive = true
        scrollRightConstraint.isActive = true
        
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        let topViewTopConstraint = NSLayoutConstraint(item: topView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        
        let topViewLeftConstraint = NSLayoutConstraint(item: topView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let topViewRightConstraint = NSLayoutConstraint(item: topView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        let topViewHeightConstraint = NSLayoutConstraint(item: topView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: ipFitSize(IPCGFloatDetailTopViewHeight))
        
        topViewTopConstraint.isActive = true
        topViewLeftConstraint.isActive = true
        topViewRightConstraint.isActive = true
        topViewHeightConstraint.isActive = true
        
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let backBtnTopConstraint = NSLayoutConstraint(item: backBtn, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: 1.0, constant: 0)
        
        let backBtnBottomConstraint = NSLayoutConstraint(item: backBtn, attribute: .bottom, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let backBtnLeftConstraint = NSLayoutConstraint(item: backBtn, attribute: .left, relatedBy: .equal, toItem: topView, attribute: .left, multiplier: 1.0, constant: 0)
        
        let backBtnWidthConstraint = NSLayoutConstraint(item: backBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: ipFitSize(IPCGFloatDetailBackIconLeftDistance*2))
        
        backBtnTopConstraint.isActive = true
        backBtnBottomConstraint.isActive = true
        backBtnLeftConstraint.isActive = true
        backBtnWidthConstraint.isActive = true
        
        
        selectBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let selectBtnTopConstraint = NSLayoutConstraint(item: selectBtn, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: 1.0, constant: 0)
        
        let selectBtnBottomConstraint = NSLayoutConstraint(item: selectBtn, attribute: .bottom, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let selectBtnRightConstraint = NSLayoutConstraint(item: selectBtn, attribute: .right, relatedBy: .equal, toItem: topView, attribute: .right, multiplier: 1.0, constant: 0)
        
        let btnWidth = (IPCGFloatChooseSureBtnRightDistance + IPCGFloatDetailSelectBtnWidth/2)*2
        let selectBtnWidthConstraint = NSLayoutConstraint(item: selectBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: ipFitSize(btnWidth))
        
        selectBtnTopConstraint.isActive = true
        selectBtnBottomConstraint.isActive = true
        selectBtnRightConstraint.isActive = true
        selectBtnWidthConstraint.isActive = true
        
        
        selectNumLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let selectNumLabelCenterXConstraint = NSLayoutConstraint(item: selectNumLabel, attribute: .centerX, relatedBy: .equal, toItem: selectBtn, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let selectNumLabelCenterYConstraint = NSLayoutConstraint(item: selectNumLabel, attribute: .centerY, relatedBy: .equal, toItem: selectBtn, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let selectNumLabelWidthConstraint = NSLayoutConstraint(item: selectNumLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: ipFitSize(IPCGFloatDetailSelectBtnWidth))
        
        let selectNumLabelHeightConstraint = NSLayoutConstraint(item: selectNumLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: ipFitSize(IPCGFloatDetailSelectBtnWidth))
        
        selectNumLabelCenterXConstraint.isActive = true
        selectNumLabelCenterYConstraint.isActive = true
        selectNumLabelWidthConstraint.isActive = true
        selectNumLabelHeightConstraint.isActive = true
        
        
        selectBackImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let selectBackImageViewTopConstraint = NSLayoutConstraint(item: selectBackImageView, attribute: .top, relatedBy: .equal, toItem: selectNumLabel, attribute: .top, multiplier: 1.0, constant: 0)
        
        let selectBackImageViewBottomConstraint = NSLayoutConstraint(item: selectBackImageView, attribute: .bottom, relatedBy: .equal, toItem:selectNumLabel , attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let selectBackImageViewLeftConstraint = NSLayoutConstraint(item: selectBackImageView, attribute: .left, relatedBy: .equal, toItem: selectNumLabel, attribute: .left, multiplier: 1.0, constant: 0)
        
        let selectBackImageViewRightConstraint = NSLayoutConstraint(item: selectBackImageView, attribute: .right, relatedBy: .equal, toItem: selectNumLabel, attribute: .right, multiplier: 1.0, constant: 0)
        
        selectBackImageViewTopConstraint.isActive = true
        selectBackImageViewBottomConstraint.isActive = true
        selectBackImageViewLeftConstraint.isActive = true
        selectBackImageViewRightConstraint.isActive = true
        
        
        singleChooseImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let singleChooseImageViewTopConstraint = NSLayoutConstraint(item: singleChooseImageView, attribute: .top, relatedBy: .equal, toItem: selectNumLabel, attribute: .top, multiplier: 1.0, constant: 0)
        
        let singleChooseImageViewBottomConstraint = NSLayoutConstraint(item: singleChooseImageView, attribute: .bottom, relatedBy: .equal, toItem:selectNumLabel , attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let singleChooseImageViewLeftConstraint = NSLayoutConstraint(item: singleChooseImageView, attribute: .left, relatedBy: .equal, toItem: selectNumLabel, attribute: .left, multiplier: 1.0, constant: 0)
        
        let singleChooseImageViewRightConstraint = NSLayoutConstraint(item: singleChooseImageView, attribute: .right, relatedBy: .equal, toItem: selectNumLabel, attribute: .right, multiplier: 1.0, constant: 0)
        
        singleChooseImageViewTopConstraint.isActive = true
        singleChooseImageViewBottomConstraint.isActive = true
        singleChooseImageViewLeftConstraint.isActive = true
        singleChooseImageViewRightConstraint.isActive = true
        
        
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
        
        let sureBtnTopConstraint = NSLayoutConstraint(item: sureBtn, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1.0, constant: 0)
        
        let sureBtnBottomConstraint = NSLayoutConstraint(item: sureBtn, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let sureBtnLeftConstraint = NSLayoutConstraint(item: sureBtn, attribute: .left, relatedBy: .equal, toItem: bottomView, attribute: .left, multiplier: 1.0, constant: 0)
        
        let sureBtnRightConstraint = NSLayoutConstraint(item: sureBtn, attribute: .right, relatedBy: .equal, toItem: bottomView, attribute: .right, multiplier: 1.0, constant: 0)
        
        sureBtnTopConstraint.isActive = true
        sureBtnBottomConstraint.isActive = true
        sureBtnLeftConstraint.isActive = true
        sureBtnRightConstraint.isActive = true
        
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        let videoViewTopConstraint = NSLayoutConstraint(item: videoView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        
        let videoViewBottomConstraint = NSLayoutConstraint(item: videoView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let videoViewLeftConstrint = NSLayoutConstraint(item: videoView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let videoViewRightConstraint = NSLayoutConstraint(item: videoView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        videoViewTopConstraint.isActive = true
        videoViewBottomConstraint.isActive = true
        videoViewLeftConstrint.isActive = true
        videoViewRightConstraint.isActive = true
        
        
        coverSinglePage.pageScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let pageScrollCenterXConstraint = NSLayoutConstraint(item: coverSinglePage.pageScrollView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let pageScrollCenterYConstraint = NSLayoutConstraint(item: coverSinglePage.pageScrollView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let pageScrollWidthConstraint = NSLayoutConstraint(item: coverSinglePage.pageScrollView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        
        let pageScrollHeightConstraint = NSLayoutConstraint(item: coverSinglePage.pageScrollView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0)
        
        pageScrollCenterXConstraint.isActive = true
        pageScrollCenterYConstraint.isActive = true
        pageScrollWidthConstraint.isActive = true
        pageScrollHeightConstraint.isActive = true
        
        
        coverSinglePage.pageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let pageImageCenterXConstraint = NSLayoutConstraint(item: coverSinglePage.pageImageView, attribute: .centerX, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let pageImageCenterYConstraint = NSLayoutConstraint(item: coverSinglePage.pageImageView, attribute: .centerY, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let pageImageWidthConstraint = NSLayoutConstraint(item: coverSinglePage.pageImageView, attribute: .width, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .width, multiplier: 1.0, constant: 0)
        
        let pageImageHeightConstraint = NSLayoutConstraint(item: coverSinglePage.pageImageView, attribute: .height, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .height, multiplier: 1.0, constant: 0)
        
        pageImageCenterXConstraint.isActive = true
        pageImageCenterYConstraint.isActive = true
        pageImageWidthConstraint.isActive = true
        pageImageHeightConstraint.isActive = true
        
        
        guard coverSinglePage.pageBtn != nil else {
            return
        }
        coverSinglePage.pageBtn?.translatesAutoresizingMaskIntoConstraints = false
        
        let pageBtnCenterXConstraint = NSLayoutConstraint(item: coverSinglePage.pageBtn!, attribute: .centerX, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let pageBtnCenterYConstraint = NSLayoutConstraint(item: coverSinglePage.pageBtn!, attribute: .centerY, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let pageBtnWidthConstraint = NSLayoutConstraint(item: coverSinglePage.pageBtn!, attribute: .width, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .width, multiplier: 1.0, constant: 0)
        
        let pageBtnHeightConstraint = NSLayoutConstraint(item: coverSinglePage.pageBtn!, attribute: .height, relatedBy: .equal, toItem: coverSinglePage.pageScrollView, attribute: .height, multiplier: 1.0, constant: 0)
        
        pageBtnCenterXConstraint.isActive = true
        pageBtnCenterYConstraint.isActive = true
        pageBtnWidthConstraint.isActive = true
        pageBtnHeightConstraint.isActive = true
    }
    
    func initView() {
        view.backgroundColor = UIColor.black
        //顶部view
        topView.backgroundColor = ipColorFromHex(hex: IPHexColorDetailTopView, alpha: 0.6)
        view.addSubview(topView)
        
        //返回按钮
        backBtn.setImage(UIImage(named: "white_return_icon"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        topView.addSubview(backBtn)
        
        //选中图片按钮
        let btnWidth = (IPCGFloatChooseSureBtnRightDistance + IPCGFloatDetailSelectBtnWidth/2)*2
        selectBtn.frame = CGRect(x: view.frame.width-ipFitSize(btnWidth), y: 0, width: ipFitSize(btnWidth), height: topView.frame.height)
        selectBtn.backgroundColor = UIColor.clear
        selectBtn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        topView.addSubview(selectBtn)
        
        selectBackImageView.image = UIImage(named: "um_select_camera")
        selectBackImageView.isUserInteractionEnabled = false
        selectBtn.addSubview(selectBackImageView)
        
        selectNumLabel.frame = CGRect(x: ipFitSize((btnWidth-IPCGFloatDetailSelectBtnWidth)/2), y: (selectBtn.frame.height-ipFitSize(IPCGFloatDetailSelectBtnWidth))/2, width: ipFitSize(IPCGFloatDetailSelectBtnWidth), height: ipFitSize(IPCGFloatDetailSelectBtnWidth))
        selectNumLabel.textAlignment = .center
        selectNumLabel.font = UIFont.systemFont(ofSize: 15)
        selectNumLabel.textColor = ipColorFromHex(IPHexColorSelectNumLabelText)
        selectNumLabel.isUserInteractionEnabled = false
        selectNumLabel.backgroundColor = ipColorFromHex(IPHexColorNextBtn)
        selectNumLabel.layer.cornerRadius = selectNumLabel.frame.width/2
        selectNumLabel.layer.masksToBounds = true
        selectBtn.addSubview(selectNumLabel)
        
        
        singleChooseImageView.backgroundColor = UIColor.clear
        singleChooseImageView.image = singleChooseImage
        selectNumLabel.addSubview(singleChooseImageView)
        
        //底部栏
        bottomView.backgroundColor = ipColorFromHex(hex: IPHexColorDetailTopView, alpha: 0.6)
        view.addSubview(bottomView)
        
        //确认按钮
        sureBtn.setTitleColor(ipColorFromHex(IPHexColorNextBtn), for: .disabled)
        sureBtn.setTitleColor(ipColorFromHex(IPHexColorNextBtn), for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sureBtn.contentHorizontalAlignment = .right
        sureBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        bottomView.addSubview(sureBtn)
        reloadSureBtnText(count: updateSelectArray.count)
        
        //大scroll
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(detailArray.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.contentOffset = CGPoint(x: view.frame.width * CGFloat(detailArrayOffSetIndex), y: 0)
        scrollView.backgroundColor = UIColor.black
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.insertSubview(scrollView, belowSubview: topView)
        
        //展示视频的view与layer
        avLayer.player = avPlayer
        avLayer.frame = view.bounds
        
        videoView.backgroundColor = UIColor.clear
        videoView.layer.addSublayer(avLayer)
        view.addSubview(videoView)
        videoView.isHidden = true
        
        
        //转屏动画覆盖的views
        coverSinglePage.pageScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        coverSinglePage.pageScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        coverSinglePage.pageScrollView.contentOffset = CGPoint(x: 0, y: 0)
        coverSinglePage.pageScrollView.delegate = self
        coverSinglePage.pageScrollView.showsVerticalScrollIndicator = false
        coverSinglePage.pageScrollView.showsHorizontalScrollIndicator = false
        coverSinglePage.pageScrollView.maximumZoomScale = 2.0
        coverSinglePage.pageScrollView.minimumZoomScale = 1.0
        coverSinglePage.pageScrollView.backgroundColor = UIColor.black
        coverSinglePage.pageScrollView.isScrollEnabled = false
        view.insertSubview(coverSinglePage.pageScrollView, aboveSubview: scrollView)
        coverSinglePage.pageScrollView.isHidden = true
        
        coverSinglePage.pageImageView.contentMode = .scaleAspectFit
        coverSinglePage.pageImageView.backgroundColor = UIColor.black
        coverSinglePage.pageScrollView.addSubview(coverSinglePage.pageImageView)
        
        let pageBtn = UIButton()
        pageBtn.backgroundColor = UIColor.clear
        pageBtn.setImage(UIImage.init(named: "play_button_icon"), for: .disabled)
        pageBtn.isEnabled = false
        coverSinglePage.pageScrollView.addSubview(pageBtn)
        coverSinglePage.pageBtn = pageBtn
        
        //初始化约束条件
        initConstraint()
        
        //视频view点击事件
        let videoViewTap = UITapGestureRecognizer(target: self, action: #selector(avPlayItemDidEnd))
        videoViewTap.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(videoViewTap)
        
        //屏幕点击事件
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapClick))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapClick))
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
        
        //初始化单页scroll
        initSinglePageStruct(index: currentIndex)
        for i in 1...scrollPagePrepareNum {
            if currentIndex-i >= 0 {
                initSinglePageStruct(index: currentIndex-i)
            }
            if currentIndex+i <= detailArray.count-1 {
                initSinglePageStruct(index: currentIndex+i)
            }
        }
        
        //刷新进入的当前页高清图
        scrollViewDidEndDecelerating(scrollView)
        
        //刷新select状态
        scrollViewDidScroll(scrollView)
    }
    
    func initSinglePageStruct(index: Int) {
        guard pageViewDic[index] == nil else {
            return
        }
        
        var singlePage = SinglePage()
        
        singlePage.pageScrollView.frame = CGRect(x: CGFloat(index)*view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        singlePage.pageScrollView.contentSize = CGSize(width: singlePage.pageScrollView.bounds.width, height: singlePage.pageScrollView.bounds.height)
        singlePage.pageScrollView.tag = index
        singlePage.pageScrollView.contentOffset = CGPoint(x: 0, y: 0)
        singlePage.pageScrollView.delegate = self
        singlePage.pageScrollView.showsVerticalScrollIndicator = false
        singlePage.pageScrollView.showsHorizontalScrollIndicator = false
        singlePage.pageScrollView.maximumZoomScale = 2.0
        singlePage.pageScrollView.minimumZoomScale = 1.0
        scrollView.addSubview(singlePage.pageScrollView)
        
        
        singlePage.pageImageView.contentMode = .scaleAspectFit
        singlePage.pageScrollView.addSubview(singlePage.pageImageView)
        
        singlePage.pageScrollView.backgroundColor = UIColor.black
        singlePage.pageImageView.backgroundColor = UIColor.black
        
        if detailArray[index].phAsset != nil {
            PHImageManager.default().requestImage(for: detailArray[index].phAsset!, targetSize: CGSize(width: singlePage.pageScrollView.frame.width/4, height: singlePage.pageScrollView.frame.height/4), contentMode: PHImageContentMode.aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) in

                //需要根据image的大小调整imageView的size以保证后续zoom的边界不会过大
                if image!.size.width >= image!.size.height*self.view.frame.width/self.view.frame.height{
                    //当 w >= W*h/H ，即宽度过大时， 以宽度为基准调整imageView的高度
                    let imgViewW = self.view.frame.width
                    let imgViewH = image!.size.height * imgViewW / image!.size.width
                    singlePage.pageImageView.frame = CGRect(x: 0, y: (self.view.frame.height-imgViewH)/2, width: imgViewW, height: imgViewH)
                }else{
                    //其余情况以高度为基准调整imageView的宽度
                    let imgViewH = self.view.frame.height
                    let imgViewW = image!.size.width * imgViewH / image!.size.height
                    singlePage.pageImageView.frame = CGRect(x: (self.view.frame.width-imgViewW)/2, y: 0, width: imgViewW, height: imgViewH)
                }
                singlePage.pageImageView.image = image
            }
        }
        
        if detailArray[index].modelType == .videoAssetModel {
            
            let pageBtn = UIButton(frame: singlePage.pageImageView.bounds)
            pageBtn.backgroundColor = UIColor.clear
            pageBtn.setImage(UIImage.init(named: "play_button_icon"), for: .normal)
            pageBtn.setImage(UIImage.init(named: "play_button_icon"), for: .disabled)
            pageBtn.setImage(UIImage.init(named: "remove_icon"), for: .selected)
            pageBtn.addTarget(self, action: #selector(playBtnClick(playBtn:)), for: .touchUpInside)
            singlePage.pageScrollView.addSubview(pageBtn)
            
            singlePage.pageBtn = pageBtn
        }
        pageViewDic[index] = singlePage
    }
    
    func reloadSureBtnText(count: Int) {
        if count == 0 {
            sureBtn.setTitle(IPStringComplete, for: .normal)
        }else{
            sureBtn.setTitle(IPStringComplete+" (\(count))", for: .normal)
        }
    }
    
    func updateSelectNumLabelStatus() {
        //更新选中按钮
        if detailArray[currentIndex].isSelected {
            for i in 0..<updateSelectArray.count {
                if updateSelectArray[i].index == detailArray[currentIndex].index {
                    selectNumLabel.text = "\(i+1)"
                    break
                }
            }
            selectNumLabel.isHidden = false
        }else{
            selectNumLabel.text = ""
            selectNumLabel.isHidden = true
        }
    }
    
    // MARK: - Tap&Click Method
    func playBtnClick(playBtn: UIButton) {
        guard playBtn.superview != nil else {
            return
        }
        let cellModel: ImageCellModel? = detailArray[currentIndex]
        guard cellModel?.phAsset != nil else {
            return
        }
        
        PHImageManager.default().requestAVAsset(forVideo: cellModel!.phAsset!, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
            
            //播放一个从未播放过的资源
            if self.avPlayItemDic[self.currentIndex] == nil{
                let item = AVPlayerItem(asset: asset!)
                self.avPlayItemDic[self.currentIndex] = item
                self.addtNotification(avPlayerItem: item)
            }
            self.avPlayer.replaceCurrentItem(with: self.avPlayItemDic[self.currentIndex])
            
            DispatchQueue.main.sync {
                self.videoView.isHidden = false
                self.avPlayer.play()
            }
        })
    }
    
    func singleTapClick() {
        if topView.isHidden == false {
            topView.isHidden = true
            bottomView.isHidden = true
        }else{
            topView.isHidden = false
            bottomView.isHidden = false
        }
    }
    
    func doubleTapClick() {
        let cellModel = detailArray[currentIndex]
        if cellModel.modelType == .imageAssetModel {
            
            guard (pageViewDic[currentIndex] != nil) else {
                return
            }
            
            let imageView = pageViewDic[currentIndex]!.pageImageView
            let pageView = pageViewDic[currentIndex]!.pageScrollView
            
            let image: UIImage! = imageView.image
            //   令image的长度为ih，宽度为iw，view的长度为vh，宽度为vw，扩放比例系数为n
            if image.size.width > image.size.height {
                //   预防宽远大于长的情况，需要满足 ih > (vh * iw) / (n * vw)
                //   若高度不满足，将公式变形可得，需要n满足 n > (vh * iw) / (ih * vw)
                let rightCalaulate = (view.frame.height*image.size.width)/(2*view.frame.width)
                //高度不满足
                if image.size.height < rightCalaulate {
                    let n = (view.frame.height*image.size.width)/(image.size.height*view.frame.width)
                    pageView.maximumZoomScale = n
                }
            }else{
                //   预防长远大于宽的情况，需要满足 iw > (vw * ih) / (n * vh)
                //   若不满足，将公式变形可得，需要n满足 n > (vw * ih) / (iw * vh)
                let rightCalaulate = (view.frame.width*image.size.height)/(2*view.frame.height)
                if image.size.width < rightCalaulate {
                    let n = (view.frame.width*image.size.height)/(image.size.width*view.frame.height)
                    pageView.maximumZoomScale = n
                }
            }
            
            let zoom = pageView.zoomScale > 1 ? 1 : pageView.maximumZoomScale
            pageView.setZoomScale(CGFloat(zoom), animated: true)
            
        }
    }
    
    func backBtnClick() {
        NotificationCenter.default.post(name: updateArrayCollectionVCNotificationName, object: self, userInfo: [updateArrayCollectionVCUserInfoKey: updateSelectArray])
        _ = navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func selectBtnClick(btn: UIButton) {
        
        switch chooseType {
        case .headImageType:
            //若之前有选中的图片，取消之
            if updateSelectArray.count > 0 {
                if let index = indexCompareDic[(updateSelectArray.first?.index)!] {
                    detailArray[index].isSelected = false
                }
            }
            
            detailArray[currentIndex].isSelected = !detailArray[currentIndex].isSelected
            updateSelectArray.removeAll()
            if detailArray[currentIndex].isSelected {
                updateSelectArray.append(detailArray[currentIndex])
            }
        case .shareImageType:
            if updateSelectArray.count >= maxChooseNum && detailArray[currentIndex].isSelected == false{
                showHudWith(targetView: view, title: IPStringSelectTheMost)
                return
            }
            detailArray[currentIndex].isSelected = !detailArray[currentIndex].isSelected
            if detailArray[currentIndex].isSelected {
                updateSelectArray.append(detailArray[currentIndex])
            }else{
                for i in 0..<updateSelectArray.count {
                    if updateSelectArray[i].index ==  detailArray[currentIndex].index {
                        updateSelectArray.remove(at: i)
                        break
                    }
                }
            }
        }
        
        reloadSureBtnText(count: updateSelectArray.count)
        updateSelectNumLabelStatus()
    }
    
    func sureBtnClick() {
        //参考微信， 若点下下一步时无选中图像，则自动选择当前图片并进入下一步
        var noChoosed = true
        for cellModel in updateSelectArray {
            if cellModel.isSelected {
                noChoosed = false
                break
            }
        }
        if noChoosed {
            detailArray[currentIndex].isSelected = true
            updateSelectArray.append(detailArray[currentIndex])
        }
        
        switch chooseType {
        case .headImageType:
            PHImageManager.default().requestImage(for: detailArray[currentIndex].phAsset!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
                
                let editHeadImageVC = EditHeadImageViewController()
                editHeadImageVC.headImage = image
                editHeadImageVC.isComingFromDetail = true
                editHeadImageVC.updateSelectArray = self.updateSelectArray
                editHeadImageVC.chooseHeadImageClosure = self.chooseHeadImageClosure
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.navigationController?.pushViewController(editHeadImageVC, animated: true)
            })

        case .shareImageType:
            var customResultVC: GetImagesViewController? = nil
            
            if let customResultVCType = NSClassFromString(customResultVCName) as? GetImagesViewController.Type {
                customResultVC = customResultVCType.init()
            }else if let customResultVCType = NSClassFromString("\(appName()).\(customResultVCName)") as? GetImagesViewController.Type{
                customResultVC = customResultVCType.init()
            }
            customResultVC?.isComingFromDetail = true
            customResultVC?.maxChooseNum = maxChooseNum
            customResultVC?.updateSelectArray = updateSelectArray
            
            if let closure = chooseImagesClosure {
                var phAssetArray: [PHAsset] = []
                
                for index in 0..<updateSelectArray.count {
                    guard (updateSelectArray[index].phAsset != nil)  else {
                        continue
                    }
                    phAssetArray.append(updateSelectArray[index].phAsset!)
                }
                closure(phAssetArray, customResultVC)
            }
        }
    }
    
    // MARK: - ScrollViewDelegate Method
    //执行该代理方法的为大scroll内的单页scroll
    func viewForZooming(in scroll: UIScrollView) -> UIView? {
        if scroll == coverSinglePage.pageScrollView {
            return coverSinglePage.pageImageView
        }
        return pageViewDic[scroll.tag]?.pageImageView
    }
    
    func scrollViewDidScroll(_ scroll: UIScrollView) {
        guard scroll == scrollView else {
            return
        }
        guard isTransition == false else {
            return
        }
        guard isViewControllerShow else {
            return
        }
        
        let index = Int(scroll.contentOffset.x + scroll.frame.width/2)/Int(scroll.frame.width)
        
        if index != currentIndex {
            if index > currentIndex && index+scrollPagePrepareNum <= detailArray.count-1 {
                initSinglePageStruct(index: index+scrollPagePrepareNum)
            }
            if index < currentIndex && index-scrollPagePrepareNum >= 0{
                initSinglePageStruct(index: index-scrollPagePrepareNum)
            }
            currentIndex = index
        }
        
        updateSelectNumLabelStatus()
    }
    
    //pageScrollView进行缩放时 大scrollView不可滑动
    func scrollViewDidZoom(_ scroll: UIScrollView) {
        //缩放后重置imageView中心点
        let offX = (scroll.bounds.size.width > scroll.contentSize.width) ?  (scroll.bounds.size.width - scroll.contentSize.width) * 0.5 : 0
        let offY = (scroll.bounds.size.height > scroll.contentSize.height) ?
            (scroll.bounds.size.height - scroll.contentSize.height) * 0.5 : 0
        guard (pageViewDic[currentIndex] != nil) else {
            return
        }
        let imgView = pageViewDic[currentIndex]?.pageImageView
        
        imgView?.center = CGPoint(x: scroll.contentSize.width*0.5+offX, y: scroll.contentSize.height*0.5+offY)
        scrollView.isScrollEnabled = !scroll.isZooming
    }
    
    //pageScrollView缩放结束 大scrollView可以滑动
    func scrollViewDidEndZooming(_ scroll: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.isScrollEnabled = true
    }
    
    
    func scrollViewDidEndDecelerating(_ scroll: UIScrollView) {
        guard scroll == scrollView else {
            return
        }
        guard (detailArray[currentIndex].phAsset != nil) else {
            return
        }
        
        guard (pageViewDic[currentIndex] != nil) else {
            return
        }
        
        reSizePageScroll(index: currentIndex-1)
        reSizePageScroll(index: currentIndex+1)
        
        let imgView = pageViewDic[currentIndex]?.pageImageView
        
        //PHImageManagerMaximumSize 获得原图尺寸
        //高清图片没有值，初始化之，有值直接拿来用
        if pageViewDic[currentIndex]?.clearImage == nil {
            PHImageManager.default().requestImage(for: detailArray[currentIndex].phAsset!, targetSize:CGSize(width: scroll.frame.width*2, height: scroll.frame.height*2) , contentMode: PHImageContentMode.aspectFill, options: nil) { [unowned self] (image: UIImage?, info: [AnyHashable : Any]?) in
                //经测试，这个闭包体会执行2次，莫名其妙啊简直了...
                //直接 imgView.image = image 会因该闭包莫名地执行2次而产生屏闪，只能曲线救国了
                guard let oldImg = imgView?.image else{
                    return
                }
                guard let newImg = image else{
                    return
                }
                
                if oldImg.size.width < newImg.size.width{
                    imgView?.image = newImg
                    self.pageViewDic[self.currentIndex]?.clearImage = newImg
                }
            }
        }else{
            imgView?.image = pageViewDic[currentIndex]?.clearImage
        }
    }
    
    func reSizePageScroll(index: Int) {
        if let pageScrollView = pageViewDic[index]?.pageScrollView{
            pageScrollView.setZoomScale(1, animated: false)
        }
    }
}
