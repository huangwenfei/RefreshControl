//
//  RefreshEmptySpaceFooter.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/24.
//

import UIKit
import Yang

open class EmptySpaceFooter: RefreshFooter {
    
    // MARK: Properties - Provider
    open var provider: RefreshEmptySpaceContentProvider = .init()
    
    // MARK: Properties - State
    open override var state: RefreshState {
        didSet {
            provider.render(state: state, refresh: self)
            setNeedsUpdate()
        }
    }
    
    // MARK: Init
    open override func initSetups() {
        super.initSetups()
        provider.initSetups(refresh: self)
    }
    
    // MARK: Layout
    open override func updateConstraints() {
        provider.updateConstraints(refresh: self)
        super.updateConstraints()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        provider.layoutSubviews(refresh: self)
    }
    
    // MARK: Space
    open func setState(color: UIColor, for state: OptionRefreshState) {
        provider.set(color: color, for: state)
    }
    
    // MARK: Refresh
    open override func startRefreshing() {
        super.startRefreshing()
        provider.startRefreshing(refresh: self)
    }
    
    open override func pullingProgress(_ value: CGFloat) {
        super.pullingProgress(value)
        provider.pullingProgress(refresh: self, progress: value)
    }
    
    open override func refreshing() {
        super.refreshing()
        provider.refreshing(refresh: self)
    }
    
    open override func finishedRefreshing(isNoMoreData: Bool) {
        super.finishedRefreshing(isNoMoreData: isNoMoreData)
        provider.finishedRefreshing(refresh: self, isNoMoreData: isNoMoreData)
    }
    
    open override func resetRefreshing() {
        super.resetRefreshing()
        provider.resetRefreshing(refresh: self)
    }
    
}
