//
//  TestingHeaderController.swift
//  RefreshControl-Ep
//
//  Created by windy on 2025/9/1.
//

import UIKit
import RefreshControl

class HeaderTestingController: TestingController {
    class override var childMode: ChildVC { .header }
}

class HeaderTextTextController: HeaderTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcHeader = TestingRefreshHeader.text(
            direction: direction.header,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}

class HeaderTextArrowController: HeaderTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcHeader = TestingRefreshHeader.arrow(
            direction: direction.header,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}

class HeaderTextImagesController: HeaderTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcHeader = TestingRefreshHeader.images(
            direction: direction.header,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}

#if canImport(Lottie)
class HeaderTextLottieController: HeaderTestingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.rcHeader = TestingRefreshHeader.lottie(
            direction: direction.header,
            target: self,
            action: #selector(refresh(sender:))
        )
    }
    
}
#endif
