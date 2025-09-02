//
//  RefreshEmptySpaceProvider.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//


import UIKit
import Yang

open class RefreshEmptySpaceProvider:
    RefreshViewPrepare,
    RefreshStateMapProtocol,
    RefreshLineFeedProtocol,
    RefreshHeaderProvider,
    RefreshFooterProvider
{
    // MARK: Container
    open var containerProvider: RefreshContainerProvider
    
    // MARK: Properties - Views
    internal var spaces: [RefreshState: SpaceInfo] = .init()
    internal lazy var spaceView: UIView = .init()
    
    // MARK: Init
    public init(containerProvider: RefreshContainerProvider) {
        self.containerProvider = containerProvider
    }
    
    open func initSetups(refresh: Refresh) {
        spaceView.yang.addToParent(refresh.container(by: containerProvider))
    }
    
    // MARK: Layout
    open func updateConstraints(refresh: Refresh) {
        
        spaceView.yangbatch.remake { make in
            make.diretionEdge.equalToParent()
        }
        
    }
    
    open func layoutSubviews(refresh: Refresh) { }
    
    // MARK: Render
    @discardableResult
    open func render(
        state: RefreshState,
        refresh: RefreshStatePropertiesMap
    ) -> UIView {
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: spaces,
            defaultValue: .init()
        )
        spaceView.backgroundColor = info.color
        return spaceView
    }
    
    // MARK: Setter
    open func set(color: UIColor, for state: OptionRefreshState) {
        state.states.forEach({ set(color: color, for: $0) })
    }
    
    // MARK: Setter - Privates
    open func set(color: UIColor, for state: RefreshState) {
        if var info = spaces[state] {
            info.color = color
            spaces[state] = info
        } else {
            spaces[state] = .init(color: color)
        }
    }
    
    // MARK: Refresh - Header
    open func startRefreshing(refresh: RefreshHeaderStatePropertiesMap) { }
    open func pullingProgress(refresh: RefreshHeaderStatePropertiesMap, progress value: CGFloat) { }
    open func refreshing(refresh: RefreshHeaderStatePropertiesMap)  { }
    open func finishedRefreshing(refresh: RefreshHeaderStatePropertiesMap, isNoMoreData: Bool)  { }
    open func resetRefreshing(refresh: RefreshHeaderStatePropertiesMap)  { }
    
    // MARK: Refesh - Footer
    open func startRefreshing(refresh: RefreshFooterStatePropertiesMap)  { }
    open func pullingProgress(refresh: RefreshFooterStatePropertiesMap, progress value: CGFloat)  { }
    open func refreshing(refresh: RefreshFooterStatePropertiesMap)  { }
    open func finishedRefreshing(refresh: RefreshFooterStatePropertiesMap, isNoMoreData: Bool)  { }
    open func resetRefreshing(refresh: RefreshFooterStatePropertiesMap)  { }
    
}

extension RefreshEmptySpaceProvider {
    public struct SpaceInfo: Hashable {
        public var color: UIColor
        
        public init(
            color: UIColor = .clear
        ) {
            self.color = color
        }
    }
}
