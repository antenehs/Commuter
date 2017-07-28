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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    class func generateProFeaturesVc() -> ProFeaturesViewController {
        let features: [AppFeature] = AppFeatureManager.shared().proOnlyFeatures as! [AppFeature]
        
        let controllers: [OnboardingContentViewController] = features.map { feature -> OnboardingContentViewController in
            let vc = OnboardingContentViewController(title: feature.displayName.uppercased(), body: feature.featureDescription, image: feature.featureImage.mainImage, buttonText: nil, actionBlock: nil)
            
            vc.iconImageView.contentMode = feature.featureImage.imageContentMode
            
            return vc;
        }
        
        ProFeaturesViewController.commonConfig(contentVCs: controllers, dimentions: dimentions)
        
        let viewController = ProFeaturesViewController(backgroundImage: nil , contents: controllers)!
        
        viewController.shouldMaskBackground = false
        viewController.view.backgroundColor = .clear
//        viewController.underPageControlPadding = 170;
        
        return viewController
    }
    
    class var dimentions:  ViewDimentions {
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
    
}

class NewInVersionViewController: TutorialViewController {
    
    class func main() -> NewInVersionViewController {
        return NewInVersionViewController.generateNewInVersionVc()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    class func generateNewInVersionVc() -> NewInVersionViewController {
        
        let first = OnboardingContentViewController(title: "NEARBY DEPARTURES", body: "Redesigned nearby departures and Citybike stations list for instant access.", image: UIImage(named: "newNearbyDepartures"), buttonText: nil, actionBlock: nil)
        first.iconImageView.contentMode = .bottom
        
        let second = OnboardingContentViewController(title: "FULL LINE ROUTE", body: "You can now see the full line route in case you decide to take off at the next stop.", image: UIImage(named: "newFullLine"), buttonText: nil, actionBlock: nil)
        second.iconImageView.contentMode = .top
        
        let third = OnboardingContentViewController(title: "WALKING ROUTE", body: "Now you'll be automatically given walking route to your stop or any selected place on the map.", image: UIImage(named: "newWalkingRouteToSelection"), buttonText: nil, actionBlock: nil)
        third.iconImageView.contentMode = .top
        
        let fourth = OnboardingContentViewController(title: "WALKING RADIUS", body: "See all the stops and nearby places within 5 min walking distance. Handy hu?", image: UIImage(named: "newFiveMinWalk"), buttonText: nil, actionBlock: nil)
        fourth.iconImageView.contentMode = .top
        
        let fifith = OnboardingContentViewController(title: "SAVING IS EASIER", body: "Just tap on the orange center indicator. Tap the star. Few more taps and you have a saved place.", image: UIImage(named: "newSaveFromMap"), buttonText: nil, actionBlock: nil)
        
        fifith.iconImageView.contentMode = .top
        
        NewInVersionViewController.commonConfig(contentVCs: [first, second, third, fourth, fifith])
        
        let viewController = NewInVersionViewController(backgroundImage: UIImage(named: "launch-screen-bkgrnd-1"), contents: [first, second, third, fourth, fifith])!
        
        viewController.shouldBlurBackground = true
        viewController.title = "NEW IN COMMUTER 6.0"
        
        return viewController
    }
}

class TutorialViewController: OnboardingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
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
//        closeItem.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        self.navigationItem.rightBarButtonItem = closeItem
    }
    
    func closeBarButtonTapped()  {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Common helpers
    typealias ViewDimentions = (imageWidth: CGFloat, imageHeight: CGFloat, topSpace: CGFloat, bodyFontSize: CGFloat)
    class var commonDimentions:  ViewDimentions {
        let screenHeight = UIScreen.main.bounds.size.height
        
        if screenHeight < 500 { //iPhone 4s
            return (imageWidth: 200, imageHeight: 250, topSpace: 70, bodyFontSize: 13)
        } else if screenHeight < 600 { //iPhone 5
            return (imageWidth: 225, imageHeight: 300, topSpace: 90, bodyFontSize: 13)
        } else if screenHeight <  900 { //iPhone 7 and plus
            return (imageWidth: 250, imageHeight: 380, topSpace: 110, bodyFontSize: 14)
        } else { //All ipads
            return (imageWidth: 400, imageHeight: 500, topSpace: 200, bodyFontSize: 18)
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



