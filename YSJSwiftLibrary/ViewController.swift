//
//  ViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import UIKit
import Photos
import MediaPicker
import SnapKit

class ViewController: YSJViewController{
    
    var imageView = UIImageView()
    let shadowImageView = UIImageView(frame: CGRect(x: 120, y: 552, width: 59, height: 59))
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        navigationItem.title = "我也是第一页"
        let str = "京C-R3925"
        print(str.characters.count)
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(childBackBtnClick))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "headImage", style: UIBarButtonItemStyle.plain, target: self, action: #selector(headImageBtnClick))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "shareImage", style: .plain, target: self, action: #selector(shareImageBtnClick))
        
        
        
        
        
        
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(-100)
            make.width.equalTo(view.snp.width).multipliedBy(0.5)
            make.height.equalTo(view.snp.width).multipliedBy(0.5)
        }
        
//        testPersistentStore()
//        testLargePersistentStore()
//        testCacheStore()
//        testLargeCacheStore()
//        testLargeCacheWithTimeKVStore()
//        testTempStore()
//        testPlistStore()
//        testSecurityStore()
//        testUserDefult()
        
        let headImages = HeadImageRollView(frame: CGRect(x: 120, y: 400, width: 100, height: 150))
        
        headImages.headImagesArray = [
            UIImage(named: "camera_button_icon")!,
            UIImage(named: "delete_button_icon")!,
            UIImage(named: "graphic_icon")!,
            UIImage(named: "video_icon")!,
            UIImage(named: "round_icon")!,
            UIImage(named: "release_delete_icon")!,
            UIImage(named: "return_icon")!,
            UIImage(named: "mask_icon")!]
        
        headImages.headImageShapeType = .roundType
        headImages.headWidth = 50
        headImages.selectImageClosure = {(index, image) in
            print(index)
            self.imageView.image = image
        }
        headImages.borderWidth = 2
        headImages.borderColor = UIColor.purple
//        headImages.isHorizontalShow = false
        headImages.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(headImages)

        
        
        view.addSubview(shadowImageView)
        
        shadowImageView.backgroundColor = UIColor.purple
        shadowImageView.image = #imageLiteral(resourceName: "camera_button_icon")
        shadowImageView.layer.cornerRadius = shadowImageView.frame.width / 2
        shadowImageView.layer.shadowColor = UIColor.gray.cgColor
        shadowImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        shadowImageView.backgroundColor = UIColor.purple
        shadowImageView.layer.shadowOpacity = 0.5
        
        
        
        let label = UILabel(frame: CGRect(x: 250, y: 400, width: 100, height: 200))
        label.backgroundColor = UIColor.lightGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.purple
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
//        label.setLineSpaceing(lineSpace: CGFloat(10), text: "哈哈哈哈哈哈哈\n哈哈哈哈哈哈哈哈", alignment: .center)
        label.text = "哈哈哈哈哈哈哈\n哈哈哈哈哈哈哈哈"
        label.setLineSpaceing(lineSpace: CGFloat(10))
        
        let textView = UITextView(frame: CGRect(x: 10, y: 400, width: 100, height: 200))
        textView.backgroundColor = UIColor.lightGray
        textView.textColor = UIColor.purple
        textView.text = "哈哈哈哈哈哈哈\n哈哈哈哈哈哈哈哈"
        textView.setLineSpaceing(lineSpace: CGFloat(20), text: nil, alignment: .center, attributes: nil)
        view.addSubview(textView)
        
//        tabBarController?.selectedIndex = 1
        
        let btn = UIButton(type: .infoLight)
        btn.frame = CGRect(x: 50, y: 100, width: 50, height: 50)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func btnClick() {
        UIView.animateKeyframes(withDuration: 6, delay: 0, options: [.calculationModeLinear], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.333, animations: {
                self.imageView.layer.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
                self.imageView.layer.backgroundColor = UIColor.red.cgColor
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.333, relativeDuration: 0.333, animations: {
                self.imageView.layer.backgroundColor = UIColor.yellow.cgColor
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.666, relativeDuration: 0.333, animations: {
                //                self.label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/8))
                self.imageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi/8), 0, 0, 1)
                self.imageView.layer.backgroundColor = UIColor.lightGray.cgColor
            })
            
        }, completion: nil)
    }
    
//    func testTempStore() {
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.tempStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.tempStore().objectForKey("key1"))
//    }
//
//    func testLargeCacheStore() {
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.largeCacheStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.largeCacheStore().objectForKey("key1"))
//    }
//
//    func testCacheStore() {
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.cacheStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.cacheStore().objectForKey("key1"))
//    }
//
//    func testSecurityStore() {
//        //set arr
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.securityStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.securityStore().objectForKey("key1"))
//
//        // set dic   enum
//        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
//        Store.securityStore().setObject(dataTypeDic, forKey: "key2")
//        Store.securityStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//        }
//        
//        //remove
//        Store.securityStore().removeForKey("key1")
//        print(Store.securityStore().objectForKey("key1"))
//        
//        //clean
//        Store.securityStore().cleanAll()
//        print(Store.securityStore().objectForKey("key2"))
//    }
//
//    func testLargeCacheWithTimeKVStore() {
//        //set arr
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.largeCacheWithTimeStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.largeCacheWithTimeStore().objectForKey("key1"))
//
//        // set dic   enum
//        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
//        Store.largeCacheWithTimeStore().setObject(dataTypeDic, forKey: "key2")
//        Store.largeCacheWithTimeStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//        print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//                    }
//        
//        
//        //remove
//        Store.largeCacheWithTimeStore().removeForKey("key1")
//        print(Store.largeCacheWithTimeStore().objectForKey("key1"))
//        
//        
//        //clean all
//        Store.largeCacheWithTimeStore().cleanAll()
//
//    }
//
//    func testLargePersistentKVStore() {
//        //set arr
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.largePersistentStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.largePersistentStore().objectForKey("key1"))
//
//        // set dic   enum
//        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
//        Store.largePersistentStore().setObject(dataTypeDic, forKey: "key2")
//        Store.largePersistentStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//        }
//        
//        //remove
//        Store.largePersistentStore().removeForKey("key1")
//        print(Store.largePersistentStore().objectForKey("key1"))
//        
//        
//        //clean all
//        Store.largePersistentStore().cleanAll()
//    }
//
//    func testPersistentStore() {
//        //persistent set arr
//        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
//        Store.persistentStore().setObject(dataTypeArr, forKey: "key1")
//        print(Store.persistentStore().objectForKey("key1"))
//
//
//        //persistent set dic
//        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
//        Store.persistentStore().setObject(dataTypeDic, forKey: "key2")
//        Store.persistentStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//        }
//
//
//        //persistent set   int & double & float & bool
//        Store.persistentStore().setValue(1.2, forKey: "key3")
//        let value3: Double? = Store.persistentStore().valueForKey("key3")
//        print("value3:\(value3)")
//
//
//        //persistent remove
//        Store.persistentStore().removeForKey("key3")
//        print("delete:\(Store.persistentStore().objectForKey("key3"))")
//
//
//        //persistent cleanAll
//        Store.persistentStore().cleanAll()
//        Store.persistentStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//        }
//        print("over")
//    }
//
//    func testPlistStore() {
//        //plist set dic
//        let typeDic = DataType.dictionary(["key1": "value1", "key2": "value2"])
//        print(typeDic.toString())
//        Store.plistStore().setObject(typeDic, forKey: "plistKey1")
//        print("\(Store.plistStore().objectForKey("plistKey1").toString())")
//
//
//        //plist set arr
//        let typeArr = DataType.array(["11","22"])
//        Store.plistStore().setObject(typeArr, forKey: "arrarKey2")
//        print("\(Store.plistStore().objectForKey("arrarKey2").toString())")
//        
//        
//        //plist  get value
//        let valueStr = Store.plistStore().objectForKey("plistKey1").toString()
//        print("\(valueStr)")
//        
//        
//        //plist  get empty value
//        let emptyValueStr = Store.plistStore().objectForKey("empty").toString()
//        print("\(emptyValueStr)")
//        
//        
//        //plist remove value
//        Store.plistStore().removeForKey("arrarKey1")
//        let plist = Store.plistStore() as! PlistKVStore
//        print("\(plist.dict)")
//        
//        
//        //plist enum
//        Store.plistStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print("key:\(key)  typeString:\(dataType.typeString()) toString:\(dataType.toString())")
//            print("toOCObject:\(dataType.toOCObject())  timestamp:\(dataType.timestamp())")
//        }
//        
//        //plist  cleanAll
//        Store.plistStore().cleanAll()
//    }
//
//    func testUserDefult() {
//        let userDefault = UserDefaultKVStore()
//
//        //userDefault  setObject
//        userDefault.setObject(.string("this is str"), forKey: "testErrorKey")
//        print("testErrorValue:\(userDefault.objectForKey("testErrorKey"))")
//        userDefault.setObject(.string("this is str2"), forKey: "testErrorKey2")
//        print("testErrorValue:\(userDefault.objectForKey("testErrorKey2"))")
//        
//        //userDefault removeObject
//        print("testErrorValue:\(userDefault.objectForKey("testErrorKey2"))")
//        userDefault.removeForKey("testErrorKey2")
//        print("testErrorValue:\(userDefault.objectForKey("testErrorKey3"))")
//        
//        //userDefault  enum
//        userDefault.enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//        }
//        
//        
//        //userDefault   cleanAll
//        userDefault.cleanAll()
//        userDefault.enumerateKeysAndObjectsUsingBlock { (key, dataType) in
//            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
//        }
//        print("over")
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func childBackBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareImageBtnClick() {
        let imagePickerVC = ImagePickerViewController()
        imagePickerVC.detailType = .imageVideoType
        //        imagePickerVC.isNewPhotoFront = true
        //        imagePickerVC.cameraBtnImage = UIImage(named: "addition_icon")
        //        imagePickerVC.isNeedCameraBtn = false
        
        MPProperty.isUseSelectImageInShareImageType = true
        //        MPProperty.themeColor = UIColor.purple
        MPProperty.selectBackgroundColor = UIColor.green
        MPProperty.selectNumTextColor = UIColor.red
        MPProperty.chooseType = .shareImageType
        //        MPProperty.maxChooseNum = 5
        MPProperty.selectImage = UIImage(named: "video_icon")
        MPProperty.chooseShareImageClosure = { (imageArray) in
            self.imageView.image = imageArray.first
            print(imageArray)
        }
        //        MPProperty.resultImageTargetSize = UIScreen.main.bounds.size
        //        MPProperty.failClosure = {
        //            print("fail")
        //        }
        
        let nav = UINavigationController(rootViewController: imagePickerVC)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func headImageBtnClick() {
        //headImageType   头像选择模式进入
        let imagePickerVC = ImagePickerViewController()
        //        imagePickerVC.isNewPhotoFront = true
        //        imagePickerVC.cameraBtnImage = UIImage(named: "addition_icon")
        //        imagePickerVC.isNeedCameraBtn = true
        
        //        MPProperty.themeColor = ipColorFromHex(IPHexColorNextBtn)
        //        MPProperty.selectBackgroundColor = ipColorFromHex(IPHexColorNextBtn)
        //        MPProperty.selectNumTextColor = ipColorFromHex(IPHexColorSelectNumLabelText)
        MPProperty.chooseType = .headImageType
        //        MPProperty.maxChooseNum = 2
        MPProperty.selectImage = UIImage(named: "video_icon")
        MPProperty.selectBackgroundColor = UIColor.green
        MPProperty.selectNumTextColor = UIColor.red
        MPProperty.chooseHeadImageClosure = { (headImage) in
            self.imageView.image = headImage
            print(headImage)
        }
        MPProperty.resultImageTargetSize = UIScreen.main.bounds.size
        //        MPProperty.failClosure = {
        //            print("fail")
        //        }
        
        let nav = UINavigationController(rootViewController: imagePickerVC)
        self.present(nav, animated: true, completion: nil)
    }
}

