# MediaPicker多媒体文件选取库
自动获取系统相册内的多媒体文件然后选择，具有多种模式

## pods安装
```ruby
source 'http://112.124.41.46/yougoods-ios/xgn.git'
target `<Your Target Name>` do
pod 'MediaPicker'
end
```

## 参数解释与使用
####配置属性优先级

1、强烈建议配置的属性为必须配置  
2、建议配置的属性需要检查配置是否正确  
3、可供选择的配置在特殊情况下需要配置  

####配置属性来源

1、配置属性一部分为静态属性，直接采用  MPProoerty.xxx = ...   进行配置  
2、其他属性需要创建ImagePickerViewController实例，采用   实例.xxx = ...  进行配置，这里用  picker   代表实例进行展示

####互相关联的属性
互相关联的属性用 (\*a)、(\*b)标明，采用同样标识的属性互相关联，需要特别注意，互相关联的属性都属于同一个优先级

####强烈建议配置的属性

1(*a)、选择模式，头像模式或分享模式，默认为分享模式

	名称: chooseType
	用法: MPProoerty.chooseType = ...

2(*a)、头像选择模式回调

	名称: chooseHeadImageClosure
	用法: MPProoerty.chooseHeadImageClosure = ...

3(*a)、分享模式image回调

	名称: chooseShareImageClosure
	用法: MPProoerty.chooseShareImageClosure = ...


####建议配置的属性

1、主题颜色

	名称: themeColor
	用法: MPProoerty.themeColor = ...

2(*b)、图片选择按钮背景色，chooseType = headImageType 时无效

	名称: selectBackgroundColor
	用法: MPProoerty.selectBackgroundColor = ...

3(*b)、图片选择按钮文字颜色，chooseType = headImageType 时无效

	名称: selectNumTextColor
	用法: MPProoerty.selectNumTextColor = ...

4(*b)、勾选图片

	名称: selectImage
	用法: MPProoerty.selectImage = ...

5(*b)、是否在shareImage模式下启用勾选图片

	名称: isUseSelectImageInShareImageType
	用法: MPProoerty.isUseSelectImageInShareImageType = ...

5、分享模式image回调指定图片的大小，chooseType = headImageType 时无效

	名称: resultImageTargetSize
	用法: MPProoerty.resultImageTargetSize = ...

6、展示模式，默认为present式，设置为false变为push式

	名称: isShowByPresent
	用法: MPProoerty.isShowByPresent = ...

7、navigationBar左侧导航按钮属性配置

	名称: leftBarBtnAttributeClosure
	用法: picker.leftBarBtnAttributeClosure.xxx = ...

8、navigationBar右侧导航按钮属性配置

	名称: rightBarBtnAttributeClosure
	用法: picker.rightBarBtnAttributeClosure.xxx = ...

9(*c)、是否需要拍照按钮

	名称: isNeedCameraBtn
	用法: picker.isNeedCameraBtn = ...

10(*c)、拍照按钮图片

	名称: cameraBtnImage
	用法: picker.cameraBtnImage = ...

11、选择是否新的照片在前

	名称: isNewPhotoFront
	用法: picker.isNewPhotoFront = ...
	
12、navigationItem属性配置回调

	名称: navigationAttributeClosure
	用法: picker.navigationAttributeClosure = ...

13、是否在选择照片后还需要进行裁剪

	名称: isNeedEdit
	用法: MPProoerty.isNeedEdit = ...

14、是否拍照后直接进行编辑或使用回调，而不再回到列表页

	名称: isUseTakePhotoDirect
	用法: MPProoerty.isUseTakePhotoDirect = ...
####可供选择配置的属性

1、选择分享模式时的最大可选图片数量，默认为9，chooseType = headImageType 时无效

	名称: maxChooseNum
	用法: MPProoerty.maxChooseNum = ...

2、分享模式PHAsset回调，chooseType = headImageType 时无效

	名称: chooseShareAssetClosure
	用法: MPProoerty.chooseShareAssetClosure = ...

3、失败回调

	名称: failClosure
	用法: MPProoerty.failClosure = ...

4、进入MediaPlayer的页面的tabBar是否显示，用于返回后自动恢复原状，默认为true

	名称: isComingVCTabBarShow
	用法: MPProoerty.isComingVCTabBarShow = ...

5、进入MediaPlayer的页面的navigationBar是否显示，用于返回后自动恢复原状，默认为true

	名称: isComingVCNavigationBarShow
	用法: MPProoerty.isComingVCNavigationBarShow = ...

6、进入MediaPlayer的页面的statusBar是否显示，用于返回后自动恢复原状，默认为true

	名称: isComingVCStatusBarShow
	用法: MPProoerty.isComingVCStatusBarShow = ...

7、选择类型，默认为只选择图片

	名称: detailType
	用法: picker.detailType = ...
