//
//  RefreshTextProvider.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//

import UIKit
import Yang

open class RefreshTextProvider:
    RefreshViewPrepare,
    RefreshStateMapProtocol,
    RefreshLineFeedProtocol,
    RefreshHeaderProvider,
    RefreshFooterProvider
{
    // MARK: Container
    open var containerProvider: RefreshContainerProvider
    
    // MARK: Properties - Views
    internal var values: [RefreshState: LabelInfo] = .init()
    internal lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: Init
    public init(containerProvider: RefreshContainerProvider) {
        self.containerProvider = containerProvider
    }
    
    open func initSetups(refresh: Refresh) {
        valueLabel.yang.addToParent(refresh.container(by: containerProvider))
    }
    
    // MARK: Layout
    open func updateConstraints(refresh: Refresh) {
        
        valueLabel.yangbatch.remake { make in
            make.diretionEdge.equalToParent()
        }
        
    }
    
    open func layoutSubviews(refresh: Refresh) { }
    
    // MARK: Render
    @discardableResult
    open func render(
        state: RefreshState,
        refresh: RefreshStatePropertiesMap
    ) -> UILabel {
        let info = loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: refresh.isAutoFillInfoWhenEmptyStateInfo,
            current: state,
            in: values,
            defaultValue: .init()
        )
        valueLabel.text = info.text
        valueLabel.font = info.font
        valueLabel.textColor = info.color
        return valueLabel
    }
    
    open func convertSources(isLineFeed: Bool) {
        isLineFeed ? convertToLineFeedSources() : convertToUnLineFeedSources()
    }
    
    open func convertToLineFeedSources() {
        values = .init(uniqueKeysWithValues: values.map({
            ($0.key, $0.value.lineFeed())
        }))
    }
    
    open func convertToUnLineFeedSources() {
        values = .init(uniqueKeysWithValues: values.map({
            ($0.key, $0.value.unlineFeed())
        }))
    }
    
    open func size(directionSize: Refresh.DirectionSize) -> CGSize {
        let result: CGSize
        if let size = directionSize.state {
            result = .init(width: size, height: size)
        } else {
            
            let sizes = values.map({
                let attributeds: [NSAttributedString.Key : Any] = [
                    .font: $0.value.font,
                    .foregroundColor: $0.value.color.cgColor
                ]
                let attributes = NSAttributedString(string: $0.value.text, attributes: attributeds)
                return attributes.size()
            })
            
            let maxWidth = sizes.max(by: { $0.width < $1.width }) ?? .zero
            let maxHeight = sizes.max(by: { $0.height < $1.height }) ?? .zero
            
            if maxWidth.width < maxHeight.height {
                result = maxHeight
            } else {
                result = maxWidth
            }
        }
        return result
    }
    
    // MARK: Setter
    open func set(text: String, isInsetLineFeedToText: Bool, for state: OptionRefreshState) {
        state.states.forEach({
            set(
                text: text,
                isInsetLineFeedToText: isInsetLineFeedToText,
                for: $0
            )
        })
    }
    
    open func set(textFont font: UIFont, for state: OptionRefreshState) {
        state.states.forEach({ set(textFont: font, for: $0) })
    }
    
    open func set(textColor color: UIColor, for state: OptionRefreshState) {
        state.states.forEach({ set(textColor: color, for: $0) })
    }
    
    // MARK: Setter - State
    open func set(text: String, isInsetLineFeedToText: Bool, for state: RefreshState) {
        let text = isInsetLineFeedToText ? dealingLineFeedText(text) : text
        if var info = values[state] {
            info.text = text
            info.isLineFeedText = isInsetLineFeedToText
            values[state] = info
        } else {
            values[state] = .init(text: text, isLineFeedText: isInsetLineFeedToText)
        }
    }
    
    open func set(textFont font: UIFont, for state: RefreshState) {
        if var info = values[state] {
            info.font = font
            values[state] = info
        } else {
            values[state] = .init(font: font)
        }
    }
    
    open func set(textColor color: UIColor, for state: RefreshState) {
        if var info = values[state] {
            info.color = color
            values[state] = info
        } else {
            values[state] = .init(color: color)
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

extension RefreshTextProvider {
    public struct LabelInfo: Hashable {
        public var text: String
        public var isLineFeedText: Bool
        public var font: UIFont
        public var color: UIColor
        
        public init(
            text: String = "",
            isLineFeedText: Bool = false,
            font: UIFont = .systemFont(ofSize: 14),
            color: UIColor = .gray
        ) {
            self.text = text
            self.isLineFeedText = isLineFeedText
            self.font = font
            self.color = color
        }
        
        public func lineFeed() -> Self {
            guard isLineFeedText == false else { return self }
            var linefeed = self
            linefeed.text = RefreshTextProvider.dealingLineFeedText(linefeed.text)
            linefeed.isLineFeedText = true
            return linefeed
        }
        
        public mutating func lineFeeded() {
            guard isLineFeedText == false else { return }
            self.text = RefreshTextProvider.dealingLineFeedText(text)
            self.isLineFeedText = true
        }
        
        public func unlineFeed() -> Self {
            guard isLineFeedText else { return self }
            var linefeed = self
            linefeed.text = RefreshTextProvider.dealingUnLineFeedText(linefeed.text)
            linefeed.isLineFeedText = false
            return linefeed
        }
        
        public mutating func unlineFeeded() {
            guard isLineFeedText else { return }
            self.text = RefreshTextProvider.dealingUnLineFeedText(text)
            self.isLineFeedText = false
        }
    }
}
