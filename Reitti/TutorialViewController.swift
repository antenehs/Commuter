//
//  KeyboardTutorialViewController.swift
//  EmojiKeyboard
//
//  Created by Anteneh Sahledengel on 5/4/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

import UIKit

class ProFeaturesViewController: TutorialViewController {
    
    class func main() -> ProFeaturesViewController {
        return ProFeaturesViewController.generateProFeaturesVc()
    }
    
    class func generateProFeaturesVc() -> ProFeaturesViewController {
        let features: [AppFeature] = AppFeatureManager.shared().proOnlyFeatures as! [AppFeature]
        
        let controllers: [OnboardingContentViewController] = features.map { feature -> OnboardingContentViewController in
            let vc = OnboardingContentViewController(title: feature.displayName.uppercased(), body: feature.featureDescription, image: feature.featureImage.mainImage, buttonText: nil, actionBlock: nil)
            
            vc.iconImageView.contentMode = feature.featureImage.featureImageViewContentMode()
            
            return vc;
        }
        
        ProFeaturesViewController.commonConfig(contentVCs: controllers)
        
        let viewController = ProFeaturesViewController(backgroundImage: nil , contents: controllers)!
        
        viewController.shouldMaskBackground = false
        viewController.view.backgroundColor = .clear
        viewController.title = "PRO FEATURES"
        
        return viewController
    }
    
}

class NewInVersionViewController: TutorialViewController {
    
    class func main() -> NewInVersionViewController {
        return NewInVersionViewController.generateNewInVersionVc()
    }
    
    class func generateNewInVersionVc() -> NewInVersionViewController {
        
        let richReminders = OnboardingContentViewController(title: "RICH REMINDERS", body: "Easily configure recurring routes to get rich notifications and automatic route suggestion.", image: UIImage(named: "richReminders"), buttonText: nil, actionBlock: nil)
        richReminders.iconImageView.contentMode = .top
        
        let fullLineRoute = OnboardingContentViewController(title: "FULL LINE ROUTE", body: "You can now see the full line route in case you decide to take off at the next stop.", image: UIImage(named: "newFullLine"), buttonText: nil, actionBlock: nil)
        fullLineRoute.iconImageView.contentMode = .top
        
        let walkingRoute = OnboardingContentViewController(title: "WALKING ROUTE", body: "Now you'll be automatically given walking route to your stop or any selected place on the map.", image: UIImage(named: "newWalkingRouteToSelection"), buttonText: nil, actionBlock: nil)
        walkingRoute.iconImageView.contentMode = .top
        
        let walkingRadius = OnboardingContentViewController(title: "WALKING RADIUS", body: "See all the stops and nearby places within 5 min walking distance. Handy hu?", image: UIImage(named: "newFiveMinWalk"), buttonText: nil, actionBlock: nil)
        walkingRadius.iconImageView.contentMode = .top
        
        let saveFromMap = OnboardingContentViewController(title: "SAVING IS EASIER", body: "Just tap on the orange center indicator. Tap the star. Few more taps and you have a saved place.", image: UIImage(named: "newSaveFromMap"), buttonText: nil, actionBlock: nil)
        
        saveFromMap.iconImageView.contentMode = .top
        
        var controllers: [OnboardingContentViewController] = []
        if AppFeatureManager.proFeaturesAvailable() {
            controllers = [richReminders]
        } else {
            controllers = [fullLineRoute, walkingRoute, walkingRadius, saveFromMap]
        }
        
        NewInVersionViewController.commonConfig(contentVCs: controllers)
        
        let viewController = NewInVersionViewController(backgroundImage: nil, contents: controllers)!
        
        viewController.shouldMaskBackground = false
        viewController.view.backgroundColor = .clear
        viewController.title = "NEW IN COMMUTER \(AppManager.currentAppVersion()!)"
        
        return viewController
    }
}

class TutorialViewController: OnboardingViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
        
        self.pageControl.hidesForSinglePage = true
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.view.backgroundColor = .clear
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let closeItem = UIBarButtonItem(image: UIImage(named: "close-button-white")?.asa_resized(toSize: CGSize(width: 25, height: 25)), style: .plain, target: self, action: #selector(closeBarButtonTapped))
        closeItem.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = closeItem
    }
    
    func closeBarButtonTapped()  {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Common helpers
    typealias ViewDimentions = (imageWidth: CGFloat, imageHeight: CGFloat, topSpace: CGFloat, bodyFontSize: CGFloat)
    
    class var commonDimentions:  ViewDimentions {
        let screenHeight = UIScreen.main.bounds.size.height
        
        if screenHeight < 500 { //iPhone 4s
            return (imageWidth: 200, imageHeight: 250, topSpace: 15, bodyFontSize: 13)
        } else if screenHeight < 600 { //iPhone 5
            return (imageWidth: 200, imageHeight: 250, topSpace: 10, bodyFontSize: 13)
        } else if screenHeight < 700 { //iPhone 7
            return (imageWidth: 220, imageHeight: 300, topSpace: 30, bodyFontSize: 14)
        } else if screenHeight < 900 { //iPhone 7 plus
            return (imageWidth: 250, imageHeight: 350, topSpace: 50, bodyFontSize: 14)
        } else { //All ipads
            return (imageWidth: 400, imageHeight: 500, topSpace: 160, bodyFontSize: 18)
        }
    }
    
    class func commonConfig(contentVCs: Array<OnboardingContentViewController>, dimentions: ViewDimentions? = nil) {
        GroupConfig(contentVCs) { vc in
            let dimentions = dimentions ?? TutorialViewController.commonDimentions
            
            vc.topPadding = dimentions.topSpace
            vc.underIconPadding = 40
            vc.underTitlePadding = 14
            
            vc.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
            vc.titleLabel.textColor = UIColor.white
            vc.bodyLabel.font = UIFont.systemFont(ofSize: dimentions.bodyFontSize)
            
            vc.actionButton.isHidden = vc.actionButton.titleLabel?.text == nil
            vc.actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            vc.actionButton.backgroundColor = AppManager.systemGreenColor()
            vc.actionButton.layer.cornerRadius = 15
            
            vc.iconWidth = dimentions.imageWidth
            vc.iconHeight = dimentions.imageHeight
            vc.iconImageView.image = vc.iconImageView.image?.asa_resized(toWidth: dimentions.imageWidth)
            vc.iconImageView.clipsToBounds = true
            
            if vc.iconImageView.contentMode == .bottom {
                let maskView = UIImageView(image: UIImage(named: "topFadeImageMask")?.asa_resized(toSize: CGSize(width: 1000, height: dimentions.imageHeight)))
                maskView.contentMode = .scaleToFill
                maskView.frame = CGRect(x: 0, y: 0, width: dimentions.imageWidth, height: dimentions.imageHeight)
                vc.iconImageView.mask = maskView
            }
        }
    }
}

@discardableResult
public func GroupConfig<Type>(_ objects : Array<Type>, block: @escaping (_ object: Type) -> Void) -> Array<Type> {
    objects.forEach { block($0) }
    
    return objects
}

@discardableResult
public func Init<Type>(_ value : Type, block: (_ object: Type) -> Void) -> Type {
    block(value)
    
    return value
}



