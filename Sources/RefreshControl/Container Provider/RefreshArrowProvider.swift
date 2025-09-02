//
//  RefreshArrowProvider.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//

import UIKit
import Yang

open class RefreshArrowProvider:
    RefreshViewPrepare,
    RefreshStateMapProtocol,
    RefreshHeaderProvider,
    RefreshFooterProvider
{
    
    // MARK: Container
    open var containerProvider: RefreshContainerProvider

    // MARK: Properties - Views
    internal var indicators: [RefreshState: IndicatorInfo] = .init()
    internal lazy var indicator: RefreshArrowIndicator = {
        let view = RefreshArrowIndicator()
        
        return view
    }()
    
    // MARK: Init
    public init(containerProvider: RefreshContainerProvider) {
        self.containerProvider = containerProvider
    }
    
    open func initSetups(refresh: Refresh) {
        indicator.yang.addToParent(refresh.container(by: containerProvider))
    }
    
    // MARK: Layout
    open func updateConstraints(refresh: Refresh) {
        
        indicator.yangbatch.remake { make in
            make.diretionEdge.equalToParent()
        }
        
    }
    
    open func layoutSubviews(refresh: Refresh) {  }
    
    // MARK: Render
    @discardableResult
    open func render(
        state: RefreshState,
        refresh: RefreshStatePropertiesMap
    ) -> RefreshArrowIndicator {
        
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        ) // indicators[state] ?? .init()
        indicator.set(color: info.color)
        indicator.set(size: info.size)
        return indicator
    }
    
    // MARK: Indicator
    open func set(color: UIColor, for state: OptionRefreshState) {
        state.states.forEach({ set(color: color, for: $0) })
    }
    
    open func set(size: CGSize, for state: OptionRefreshState) {
        state.states.forEach({ set(size: size, for: $0) })
    }
    
    // MARK: Indicator - State
    open func set(color: UIColor, for state: RefreshState) {
        if var info = indicators[state] {
            info.color = color
            indicators[state] = info
        } else {
            indicators[state] = .init(color: color)
        }
    }
    
    open func set(size: CGSize, for state: RefreshState) {
        if var info = indicators[state] {
            info.size = size
            indicators[state] = info
        } else {
            indicators[state] = .init(size: size)
        }
    }
    
    // MARK: Refresh - Header
    public func startRefreshing(refresh: RefreshHeaderStatePropertiesMap) {
        startRefreshing()
    }
    
    public func pullingProgress(refresh: RefreshHeaderStatePropertiesMap, progress value: CGFloat) {
        
        switch refresh.direction {
        case .top:     indicator.flipping(to: value >= 1 ? .bottom : .top)
        case .leading: indicator.flipping(to: value >= 1 ? .trailing : .leading)
        }
    }
    
    public func refreshing(refresh: RefreshHeaderStatePropertiesMap) {
        refreshing()
    }
    
    public func finishedRefreshing(refresh: RefreshHeaderStatePropertiesMap, isNoMoreData: Bool) {
        finishedRefreshing(isNoMoreData: isNoMoreData)
    }
    
    public func resetRefreshing(refresh: RefreshHeaderStatePropertiesMap) {
        resetRefreshing()
    }
    
    // MARK: Refresh - Footer
    public func startRefreshing(refresh: RefreshFooterStatePropertiesMap) {
        startRefreshing()
    }
    
    public func pullingProgress(
        refresh: RefreshFooterStatePropertiesMap,
        progress value: CGFloat
    ) {
        
        switch refresh.direction {
        case .bottom:   indicator.flipping(to: value >= 1 ? .top : .bottom)
        case .trailing: indicator.flipping(to: value >= 1 ? .leading : .trailing)
        }
    }
    
    public func refreshing(refresh: RefreshFooterStatePropertiesMap) {
        refreshing()
    }
    
    public func finishedRefreshing(
        refresh: RefreshFooterStatePropertiesMap,
        isNoMoreData: Bool
    ) {
        finishedRefreshing(isNoMoreData: isNoMoreData)
    }
    
    public func resetRefreshing(refresh: RefreshFooterStatePropertiesMap) {
        resetRefreshing()
    }
    
    // MARK: Refresh - Private
    private func startRefreshing() {
        indicator.startRefreshing()
    }
    
    private func refreshing() {
        indicator.refreshing()
    }
    
    private func finishedRefreshing(isNoMoreData: Bool) {
        indicator.finishedRefreshing()
    }
    
    private func resetRefreshing() {
        indicator.resetRefreshing()
    }
    
}

extension RefreshArrowProvider {
    public struct IndicatorInfo: Hashable {
        public var color: UIColor
        public var size: CGSize
        
        public init(color: UIColor = .white, size: CGSize = .init(width: 26, height: 16)) {
            self.color = color
            self.size = size
        }
    }
}
