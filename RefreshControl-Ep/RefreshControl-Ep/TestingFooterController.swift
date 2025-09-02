//
//  TestingFooterController.swift
//  RefreshControl-Ep
//
//  Created by windy on 2025/9/1.
//

import UIKit
import RefreshControl

class FooterTestingController: TestingController {
    class override var childMode: ChildVC { .footer }
}

class FooterTextTextController: FooterTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcFooter = TestingRefreshFooter.text(
            direction: direction.footer,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}

class FooterTextArrowController: FooterTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcFooter = TestingRefreshFooter.arrow(
            direction: direction.footer,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}

class FooterTextImagesController: FooterTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcFooter = TestingRefreshFooter.images(
            direction: direction.footer,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}

#if canImport(Lottie)
class FooterTextLottieController: FooterTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcFooter = TestingRefreshFooter.lottie(
            direction: direction.footer,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}
#endif
