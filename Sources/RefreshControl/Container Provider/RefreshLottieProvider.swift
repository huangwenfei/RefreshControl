//
//  RefreshLottieProvider.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//

#if canImport(Lottie)

import UIKit
import Yang
import Lottie

open class RefreshLottieProvider:
    RefreshViewPrepare,
    RefreshStateMapProtocol,
    RefreshHeaderProvider,
    RefreshFooterProvider
{
    // MARK: Container
    open var containerProvider: RefreshContainerProvider
    
    // MARK: Properties - Views
    private weak var refresh: Refresh? = nil
    open private(set) var animation: AnimateInfo = .init()
    
    internal var indicators: [RefreshState: StateInfo] = .init()
    internal lazy var indicator: LottieAnimationView = {
        let result = LottieAnimationView()
        return result
    }()
    
    private var isPlayingFlagOn: Bool = false
    
    // MARK: Init
    public init(containerProvider: RefreshContainerProvider) {
        self.containerProvider = containerProvider
    }
    
    open func initSetups(refresh: Refresh) {
        self.refresh = refresh
        indicator.yang.addToParent(refresh.container(by: containerProvider))
    }
    
    // MARK: Layout
    open func updateConstraints(refresh: Refresh) {
        
        indicator.yangbatch.remake { make in
            make.center.equalToParent()
            make.width.equal(to: animation.size.width)
            make.height.equal(to: animation.size.height)
        }
        
    }
    
    open func layoutSubviews(refresh: Refresh) { }
    
    // MARK: Render
    @discardableResult
    open func render(
        state: RefreshState,
        refresh: RefreshStateMapProperties
    ) -> LottieAnimationView {
        
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        ) // indicators[state] ?? .init()
        info.configs(indicator)
        return indicator
    }
    
    // MARK: Loading
    private func loading() {
        
        let name = animation.source
        
        if name.hasSuffix(".lottie") {
            
            DotLottieFile.named(name) { result in
                
                switch result {
                case .failure(let error):
                    #if DEBUG
                    print(name, error.localizedDescription)
                    #else
                    break
                    #endif
                    
                case .success(let lottie):
                    DispatchQueue.main.async {
                        /// 只处理第一个
                        self.indicator.animation = lottie.animations.first?.animation
                        
                        /// 未加载完就触发了 play
                        self.indicator.animationLoaded = { indicator, animation in
                            if self.isPlayingFlagOn {
                                indicator.currentProgress = 0
                                indicator.play()
                                self.isPlayingFlagOn = false
                            }
                        }
                    }
                }
                
            }
            
        } else {
            /// ".json"
            self.indicator.animation = LottieAnimation.named(name)
        }
        
    }
    
    // MARK: Indicator
    open func set(animation: AnimateInfo) {
        
        self.animation = animation
        
        /// - Tag: Init
        indicator.loopMode = animation.loopMode
        indicator.contentMode = animation.contentMode
        indicator.backgroundBehavior = animation.backgroundBehavior
        indicator.animationSpeed = animation.animationSpeed
        indicator.backgroundColor = animation.backgroundColor
        
        /// - Tag: Layout
        refresh?.setNeedsUpdate()
        
        /// - Tag: Loading
        loading()
        
    }
    
    open func set(configs: @escaping StateInfo.Configs, for state: OptionRefreshState) {
        state.states.forEach({
            set(configs: configs, for: $0)
        })
    }
    
    // MARK: Indicator - State
    open func set(configs: @escaping StateInfo.Configs, for state: RefreshState) {
        if var info = indicators[state] {
            info.configs = configs
            indicators[state] = info
        } else {
            indicators[state] = .init(configs: configs)
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
        
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        )
        
        guard
            state > .idle
        else {
            return
        }
        
        info.configs(indicator)
        indicator.currentProgress = value
        
//        print(#function, #line, "Lottie Progress", value, indicator.currentProgress)
        
    }
    
    private func refreshing() {
        indicator.play()
        isPlayingFlagOn = true
    }
    
    private func finishedRefreshing(
        state: RefreshState,
        isAutoFillInfoWhenEmptyStateInfo: Bool,
        isNoMoreData: Bool
    ) {
        indicator.stop()
        indicator.currentProgress = 0
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        )
        info.configs(indicator)
        isPlayingFlagOn = false
    }
    
    private func resetRefreshing(
        state: RefreshState,
        isAutoFillInfoWhenEmptyStateInfo: Bool
    ) {
        indicator.stop()
        indicator.currentProgress = 0
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: indicators,
            defaultValue: .init()
        )
        info.configs(indicator)
        isPlayingFlagOn = false
    }
    
}

extension RefreshLottieProvider {
    public struct AnimateInfo: Hashable {
        public var source: String
        public var size: CGSize
        public var loopMode: Lottie.LottieLoopMode
        public var contentMode: UIView.ContentMode
        public var backgroundBehavior: Lottie.LottieBackgroundBehavior
        public var animationSpeed: CGFloat
        public var backgroundColor: UIColor
        
        public init(
            source: String = "",
            size: CGSize = .init(width: 32, height: 32),
            loopMode: Lottie.LottieLoopMode = .loop,
            contentMode: UIView.ContentMode = .scaleAspectFit,
            backgroundBehavior: Lottie.LottieBackgroundBehavior = .pauseAndRestore,
            animationSpeed: CGFloat = 1,
            backgroundColor: UIColor = .clear
        ) {
            self.source = source
            self.size = size
            self.loopMode = loopMode
            self.contentMode = contentMode
            self.backgroundBehavior = backgroundBehavior
            self.animationSpeed = animationSpeed
            self.backgroundColor = backgroundColor
        }
    }
    
    public struct StateInfo {
        public typealias Configs = (_ view: LottieAnimationView) -> Void
        
        public var configs: Configs
        
        public init(
            configs: @escaping Configs = { _ in })
        {
            self.configs = configs
        }
    }
}

#endif
