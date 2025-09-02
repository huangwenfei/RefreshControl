//
//  UIScrollView+Refresh.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/16.
//

import UIKit
import Yang

fileprivate struct RcRefreshKeys {
    static var header: UInt8 = 0
    static var footer: UInt8 = 1
}

extension UIScrollView {
    
    public var rcHeader: RefreshHeader? {
        get {
            guard
                let header = objc_getAssociatedObject(
                    self, &RcRefreshKeys.header
                ) as? RefreshHeader
            else {
                return nil
            }
            return header
        }
        set {
            let old = self.rcHeader
            guard newValue !== old else { return }
            
            old?.removeFromSuperview()
            if let newValue { insertSubview(newValue, at: 0) }
            
            objc_setAssociatedObject(
                self,
                &RcRefreshKeys.header,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    public var rcFooter: RefreshFooter? {
        get {
            guard
                let footer = objc_getAssociatedObject(
                    self, &RcRefreshKeys.footer
                ) as? RefreshFooter
            else {
                return nil
            }
            return footer
        }
        set {
            let old = self.rcFooter
            guard newValue !== old else { return }
            
            old?.removeFromSuperview()
            if let newValue { insertSubview(newValue, at: 0) }
            
            objc_setAssociatedObject(
                self,
                &RcRefreshKeys.footer,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
}
