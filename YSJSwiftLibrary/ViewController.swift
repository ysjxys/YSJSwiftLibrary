//
//  ViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import UIKit
import Photos


class ViewController: YSJViewController{
    
    var imageView = UIImageView()
    
    
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
        
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(childBackBtnClick))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "headImage", style: UIBarButtonItemStyle.plain, target: self, action: #selector(headImageBtnClick))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "shareImage", style: .plain, target: self, action: #selector(shareImageBtnClick))
        
        
        imageView.frame = CGRect(x: 100, y: 200, width: (view.frame.width-100)/2, height: (view.frame.width-100)/2)
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        
//        testPlistStore()
//        testPersistentStore()
//        testUserDefult()
//        testLargePersistentKVStore()
//        testLargeCacheWithTimeKVStore()
//        testKeychain()
    }
    
    
    
    func testKeychain() {
        //set arr
        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
        Store.keychainKVStore.setObject(dataTypeArr, forKey: "key1")
        print(Store.keychainKVStore.objectForKey("key1"))
        
        // set dic   enum
        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
        Store.keychainKVStore.setObject(dataTypeDic, forKey: "key2")
        Store.keychainKVStore.enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
        }
        
        //remove
        Store.keychainKVStore.removeForKey("key1")
        print(Store.keychainKVStore.objectForKey("key1"))
        
        //clean
        Store.keychainKVStore.cleanAll()
        print(Store.keychainKVStore.objectForKey("key2"))
    }
    
    func testLargeCacheWithTimeKVStore() {
        //set arr
        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
        StoreLayer.defaultStore().largeCacheWithTimeKVStore.setObject(dataTypeArr, forKey: "key1")
        print(StoreLayer.defaultStore().largeCacheWithTimeKVStore.objectForKey("key1"))
        
        // set dic   enum
        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
        StoreLayer.defaultStore().largeCacheWithTimeKVStore.setObject(dataTypeDic, forKey: "key2")
        StoreLayer.defaultStore().largeCacheWithTimeKVStore.enumerateKeysAndObjectsUsingBlock { (key, dataType) in
        print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
                    }
        
        
        //remove
        StoreLayer.defaultStore().largeCacheWithTimeKVStore.removeForKey("key1")
        print(StoreLayer.defaultStore().largeCacheWithTimeKVStore.objectForKey("key1"))
        
        
        //clean all
        StoreLayer.defaultStore().largeCacheWithTimeKVStore.cleanAll()
        
    }
    
    func testLargePersistentKVStore() {
        //set arr
        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
        StoreLayer.defaultStore().largePersistentStore().setObject(dataTypeArr, forKey: "key1")
        print(StoreLayer.defaultStore().largePersistentStore().objectForKey("key1"))
        
        // set dic   enum
        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
        StoreLayer.defaultStore().largePersistentStore().setObject(dataTypeDic, forKey: "key2")
        StoreLayer.defaultStore().largePersistentStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
        }
        
        //remove
        StoreLayer.defaultStore().largePersistentStore().removeForKey("key1")
        print(StoreLayer.defaultStore().largePersistentStore().objectForKey("key1"))
        
        
        //clean all
        StoreLayer.defaultStore().largePersistentStore().cleanAll()
    }
    
    func testPersistentStore() {
        //persistent set arr
        let dataTypeArr = DataType.array(["value1", "value2", "value3"])
        StoreLayer.defaultStore().persistentStore().setObject(dataTypeArr, forKey: "key1")
        print(StoreLayer.defaultStore().persistentStore().objectForKey("key1"))
        
        
        //persistent set dic
        let dataTypeDic = DataType.dictionary(["key1":"value1","key2":["1","2"]])
        StoreLayer.defaultStore().persistentStore().setObject(dataTypeDic, forKey: "key2")
        StoreLayer.defaultStore().persistentStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
        }
        
        
        //persistent set   int & double & float & bool
        StoreLayer.defaultStore().persistentStore().setValue(1.2, forKey: "key3")
        let value3: Double? = StoreLayer.defaultStore().persistentStore().valueForKey("key3")
        print("value3:\(value3)")
        
        
        //persistent remove
        StoreLayer.defaultStore().persistentStore().removeForKey("key3")
        print("delete:\(StoreLayer.defaultStore().persistentStore().objectForKey("key3"))")
        
        
        //persistent cleanAll
        StoreLayer.defaultStore().persistentStore().cleanAll()
         StoreLayer.defaultStore().persistentStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
        }
        print("over")
    }
    
    func testPlistStore() {
        //plist set dic
        let typeDic = DataType.dictionary(["key1": "value1", "key2": "value2"])
        print(typeDic.toString())
        StoreLayer.defaultStore().plistStore().setObject(typeDic, forKey: "plistKey1")
        print("\(StoreLayer.defaultStore().plistStore().objectForKey("plistKey1").toString())")
        
        
        //plist set arr
        let typeArr = DataType.array(["11","22"])
        StoreLayer.defaultStore().plistStore().setObject(typeArr, forKey: "arrarKey2")
        print("\(StoreLayer.defaultStore().plistStore().objectForKey("arrarKey2").toString())")
        
        
        //plist  get value
        let valueStr = StoreLayer.defaultStore().plistStore().objectForKey("plistKey1").toString()
        print("\(valueStr)")
        
        
        //plist  get empty value
        let emptyValueStr = StoreLayer.defaultStore().plistStore().objectForKey("empty").toString()
        print("\(emptyValueStr)")
        
        
        //plist remove value
        StoreLayer.defaultStore().plistStore().removeForKey("arrarKey1")
        let plist = StoreLayer.defaultStore().plistStore() as! PlistKVStore
        print("\(plist.dict)")
        
        
        //plist enum
        StoreLayer.defaultStore().plistStore().enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print("key:\(key)  typeString:\(dataType.typeString()) toString:\(dataType.toString())")
            print("toOCObject:\(dataType.toOCObject())  timestamp:\(dataType.timestamp())")
        }
        
        //plist  cleanAll
        StoreLayer.defaultStore().plistStore().cleanAll()
    }
    
    func testUserDefult() {
        let userDefault = UserDefaultKVStore()
        
        //userDefault  setObject
        userDefault.setObject(.string("this is str"), forKey: "testErrorKey")
        print("testErrorValue:\(userDefault.objectForKey("testErrorKey"))")
        userDefault.setObject(.string("this is str2"), forKey: "testErrorKey2")
        print("testErrorValue:\(userDefault.objectForKey("testErrorKey2"))")
        
        //userDefault removeObject
        print("testErrorValue:\(userDefault.objectForKey("testErrorKey2"))")
        userDefault.removeForKey("testErrorKey2")
        print("testErrorValue:\(userDefault.objectForKey("testErrorKey3"))")
        
        //userDefault  enum
        userDefault.enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
        }
        
        
        //userDefault   cleanAll
        userDefault.cleanAll()
        userDefault.enumerateKeysAndObjectsUsingBlock { (key, dataType) in
            print(" key:\(key)  \n typeString:\(dataType.typeString()) \n toString:\(dataType.toString())")
        }
        print("over")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func childBackBtnClick() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func shareImageBtnClick() {
        let imagePickerVC = ImagePickerViewController()
        //shareImageType  照片选择模式进入
        imagePickerVC.detailType = .imageVideoType
        imagePickerVC.chooseType = .shareImageType
        imagePickerVC.isNewPhotoFront = true
        imagePickerVC.customResultVCName = NSStringFromClass(CustomResultViewConroller.classForCoder())
        imagePickerVC.chooseImagesClosure = {(assetArray, customResultVC) in
            if let customResultVC = customResultVC {
                self.hidesBottomBarWhenPushed = true
                UIApplication.shared.setStatusBarHidden(false, with: .none)
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.pushViewController(customResultVC, animated: true)
            }else{
                print("customResultVC is nil")
            }
        }
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(imagePickerVC, animated: true)
        hidesBottomBarWhenPushed = false
    }
    
    func headImageBtnClick() {
        //headImageType   头像选择模式进入
        let imagePickerVC = ImagePickerViewController()
        //default is false
        imagePickerVC.isNewPhotoFront = false
        //default is .shareImageType
        imagePickerVC.chooseType = .headImageType
        //返回headImage的闭包处理部分
        imagePickerVC.chooseHeadImageClosure = {(headImage, editHeadVC) in
            print("width:\(headImage.size.width)  height:\(headImage.size.height)")
            self.imageView.image = headImage
        }
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(imagePickerVC, animated: true)
        hidesBottomBarWhenPushed = false
    }

    func getImagesViewDidLoad(getImagesVC: GetImagesViewController) {
        getImagesVC.navigationItem.leftBarButtonItem?.title = "hahahaha"
    }
}

