//
//  RefreshImagesProvider.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//

import UIKit
import Yang

open class RefreshImagesProvider:
    RefreshViewPrepare,
    RefreshStateMapProtocol,
    RefreshHeaderProvider,
    RefreshFooterProvider
{
    // MARK: Container
    open var containerProvider: RefreshContainerProvider
    
    // MARK: Properties - Views
    internal var indicators: [RefreshState: ImagesInfo] = .init()
    internal lazy var indicator: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
        
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            current: refresh.state,
            in: indicators,
            defaultValue: .init()
        ) // indicators[state] ?? .init()
        
        indicator.yangbatch.remake { make in
            make.center.equalToParent()
            make.width.equal(to: info.size.width)
            make.height.equal(to: info.size.height)
        }
        
    }
    
    open func layoutSubviews(refresh: Refresh) { }
    
    // MARK: Render
    @discardableResult
    open func render(
        state: RefreshState,
        refresh: RefreshStateMapProperties
    ) -> UIImageView {
        
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        ) // indicators[state] ?? .init()
        indicator.animationImages = info.images
        indicator.animationDuration = info.duration
        return indicator
    }
    
    // MARK: Indicator
    open func set(images: [UIImage], duration: TimeInterval, for state: OptionRefreshState) {
        state.states.forEach({
            set(images: images, duration: duration, for: $0)
        })
    }
    
    open func set(images: [UIImage], for state: OptionRefreshState) {
        state.states.forEach({
            set(images: images, duration: .init(images.count) * 0.1, for: $0)
        })
    }
    
    open func set(size: CGSize, for state: OptionRefreshState) {
        state.states.forEach({ set(size: size, for: $0) })
    }
    
    // MARK: Indicator - State
    open func set(images: [UIImage], duration: TimeInterval, for state: RefreshState) {
        if var info = indicators[state] {
            info.images = images
            info.duration = duration
            indicators[state] = info
        } else {
            indicators[state] = .init(images: images, duration: duration)
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
        
        pullingProgress(
            state: refresh.state,
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            progress: value
        )
    }
    
    public func refreshing(refresh: RefreshHeaderStatePropertiesMap) {
        refreshing()
    }
    
    public func finishedRefreshing(
        refresh: RefreshHeaderStatePropertiesMap,
        isNoMoreData: Bool
    ) {
        finishedRefreshing(
            state: refresh.state,
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            isNoMoreData: isNoMoreData
        )
    }
    
    public func resetRefreshing(refresh: RefreshHeaderStatePropertiesMap) {
        resetRefreshing(
            state: refresh.state,
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo
        )
    }
    
    // MARK: Refresh - Footer
    
    public func startRefreshing(refresh: RefreshFooterStatePropertiesMap) {
        startRefreshing()
    }
    
    public func pullingProgress(
        refresh: RefreshFooterStatePropertiesMap,
        progress value: CGFloat
    ) {
        
        pullingProgress(
            state: refresh.state,
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            progress: value
        )
    }
    
    public func refreshing(refresh: RefreshFooterStatePropertiesMap) {
        refreshing()
    }
    
    public func finishedRefreshing(
        refresh: RefreshFooterStatePropertiesMap,
        isNoMoreData: Bool
    ) {
        finishedRefreshing(
            state: refresh.state,
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            isNoMoreData: isNoMoreData
        )
    }
    
    public func resetRefreshing(refresh: RefreshFooterStatePropertiesMap) {
        resetRefreshing(
            state: refresh.state,
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo
        )
    }
    
    // MARK: Refresh - Private
    private func startRefreshing() { }
    
    private func pullingProgress(
        state: RefreshState,
        isAutoFillInfoWhenEmptyStateInfo: Bool,
        progress value: CGFloat
    ) {
        
        let images = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        ).images
        
        guard
            state > .idle,
            images.isEmpty == false
        else {
            return
        }
        
        indicator.stopAnimating()
        setPreview(by: value, images: images)
        
    }
    
    private func refreshing() {
        indicator.startAnimating()
    }
    
    private func finishedRefreshing(
        state: RefreshState,
        isAutoFillInfoWhenEmptyStateInfo: Bool,
        isNoMoreData: Bool
    ) {
        indicator.stopAnimating()
        setPreview(
            by: 0,
            images: loopFillStateInfo(
                isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
                current: state,
                in: indicators,
                defaultValue: .init()
            ).images
        )
    }
    
    private func resetRefreshing(
        state: RefreshState,
        isAutoFillInfoWhenEmptyStateInfo: Bool
    ) {
        indicator.stopAnimating()
        setPreview(
            by: 0,
            images: loopFillStateInfo(
                isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
                current: state,
                in: indicators,
                defaultValue: .init()
            ).images
        )
    }
    
    private func setPreview(by progress: CGFloat, images: [UIImage]) {
        guard images.isEmpty == false else { return }
        
        var index = Int(floor(.init(images.count) * progress))
        if index >= images.count { index = images.count - 1 }
        indicator.image = images[index]
    }
    
}

extension RefreshImagesProvider {
    public struct ImagesInfo: Hashable {
        public var images: [UIImage]
        public var duration: TimeInterval
        public var size: CGSize
        
        public init(images: [UIImage] = [], duration: TimeInterval = 0.2, size: CGSize = .init(width: 32, height: 32)) {
            self.images = images
            self.duration = duration
            self.size = size
        }
    }
}
