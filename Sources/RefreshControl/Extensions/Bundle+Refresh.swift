//
//  Bundle+Refresh.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/17.
//

import UIKit

extension Bundle {
    
    public static let srBundle: Bundle? = {
        let containerBundle = Bundle(for: Refresh.self)
        if
            let result = containerBundle.path(
                forResource: "RefreshControl_RefreshControl",
                ofType: "bundle"
            )
        {
            return Bundle(path: result)
        } else {
            return nil
        }
    }()
    
    public static let srArrowImage: UIImage? = {
        if
            let path = srBundle?.path(forResource: "arrow@2x", ofType: "png"),
            let result = UIImage(contentsOfFile: path)
        {
            return result.withRenderingMode(.alwaysTemplate)
        } else {
            return nil
        }
    }()
    
}
