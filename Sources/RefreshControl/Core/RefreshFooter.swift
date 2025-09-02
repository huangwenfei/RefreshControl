//
//  RefreshFooter.swift
//  Xiaosuimian
//
//
//  `content`: animating content (text, icon, animate, anything)
//  `state content`: refresh state content
//  `time content`: last update time content
//  `[]`: a group fill two lines or a content fill two lines
//
//  `footer-bottom`:
//     top
//          `content`
//       `time content`
//       `state content`
//
//     leading
//       [`content`     `time content`
//        `content`]    `state content`
//
//     bottom
//       `time content`
//       `state content`
//          `content`
//
//     trailing
//       `time content`   [`content`
//       `state content`     `content`]
//
//
//  `footer-trailing`:
//     top
//                    `content`
//       [`state content`     `time content`]
//
//     leading
//       `content`   `state content`     `time content`
//
//     bottom
//       [`state content`     `time content`]
//                    `content`
//
//     trailing
//       `state content`     `time content`     `content`
//
//
//  Created by windy on 2025/7/16.
//

import UIKit
import Yang

// MARK: Refresh Footer Protocols

public protocol RefreshFooterProtocol: Refresh, RefreshDirectionFooter { }

public protocol RefreshDirectionFooter {
    var direction: RefreshFooterDirection { get set }
}

public protocol RefreshFooterProvider {
    func startRefreshing(refresh: RefreshFooterStatePropertiesMap)
    func pullingProgress(refresh: RefreshFooterStatePropertiesMap, progress value: CGFloat)
    func refreshing(refresh: RefreshFooterStatePropertiesMap)
    func finishedRefreshing(refresh: RefreshFooterStatePropertiesMap, isNoMoreData: Bool)
    func resetRefreshing(refresh: RefreshFooterStatePropertiesMap)
}

// MARK: Refresh Header

open class RefreshFooter: Refresh, RefreshFooterProtocol {
    
    // MARK: Types
    public typealias Direction = RefreshFooterDirection
    
    // MARK: Properties - Mode
    open override var stateMode: ContentStateMode { .footer }
    
    // MARK: Properties - Direction
    open var direction: Direction = .bottom {
        didSet {
            prepareDiretion(scrollView: scrollView)
            setNeedsUpdate()
        }
    }
    
    open var isSnapToLastContent: Bool = false
    
    // MARK: Init
    open override func initSetups() {
        super.initSetups()
        
        switch direction {
        case .bottom:   contentAlignment = .leading
        case .trailing: contentAlignment = .trailing
        }
        
    }

    // MARK: Layout
    open override func selfLayout(scrollView: UIScrollView?) {
        super.selfLayout(scrollView: scrollView)
        
        guard let scrollView else { return }
        
        let offset = scrollView.contentOffset
        let bouncesOffset = scrollBreakPointOffset(scrollView: scrollView)
        
        let stateSize = isShowState ? self.stateSize : .zero
        let timeSize = isShowTime ? self.timeSize : .zero
        
        switch direction {
        case .bottom:
            let totalSize = directionSize.totalSize(
                state: stateSize,
                time: timeSize,
                isVertical: true,
                contentAlignment: contentAlignment
            )
            
            self.frame = .init(
                x: 0,
                y: scrollView.frame.height + offset.y - bouncesOffset,
                width: scrollView.frame.width,
                height: totalSize
            )
            
        case .trailing:
            let totalSize = directionSize.totalSize(
                state: stateSize,
                time: timeSize,
                isVertical: false,
                contentAlignment: contentAlignment
            )
            
            self.frame = .init(
                x: scrollView.frame.width + offset.x - bouncesOffset,
                y: 0,
                width: totalSize,
                height: scrollView.frame.height
            )
            
        }
        
//        print(#function, #line, "Pulling Footer", self.frame, offset)
    }
    
    open override func updateConstraints() {
        
        let contentSize = directionSize.content
        let stateSize = isShowState ? self.stateSize : .zero
        let timeSize = isShowTime ? self.timeSize : .zero
        
        switch direction {
        case .bottom:
            
            let backgroundSize = directionSize.backgroundSize(
                state: stateSize,
                time: timeSize,
                isVertical: true,
                contentAlignment: contentAlignment
            )
            
            backgroundContainer.yangbatch.remake { make in
                make.top.equalToParent()
                make.horizontal.equalToParent()
                make.height.equal(to: backgroundSize)
            }
             
            switch contentAlignment {
            case .leading:
                let maxWidth = contentSize + max(stateSize.width, timeSize.width)
                elementsContainer.yangbatch.remake { make in
                    make.width.equal(to: maxWidth)
                    make.vertical.equalToParent()
                    make.center.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.leading.equalToParent()
                    make.trailing.equal(to: stateContainer.yangbatch.leading)
                    make.width.equal(to: contentSize)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
            case .trailing:
                let maxWidth = contentSize + max(stateSize.width, timeSize.width)
                elementsContainer.yangbatch.remake { make in
                    make.width.equal(to: maxWidth)
                    make.vertical.equalToParent()
                    make.center.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.leading.equal(to: stateContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.width.equal(to: contentSize)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
            case .top:
                elementsContainer.yangbatch.remake { make in
                    make.diretionEdge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.top.equalToParent()
                    make.horizontal.equalToParent()
                    make.bottom.equal(to: timeContainer.yangbatch.top)
                    make.height.equal(to: isShowContent ? contentSize : 0)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.top.equal(to: contentContainer.yangbatch.bottom)
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: timeSize.height).multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: stateSize.height).multiplier(by: multiplier)
                }
                
            case .bottom:
                elementsContainer.yangbatch.remake { make in
                    make.diretionEdge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.top.equal(to: stateContainer.yangbatch.bottom)
                    make.bottom.equalToParent()
                    make.height.equal(to: isShowContent ? contentSize : 0)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: timeSize.height).multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.bottom.equal(to: contentContainer.yangbatch.top)
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: stateSize.height).multiplier(by: multiplier)
                }
            }
            
        case .trailing:
            
            let backgroundSize = directionSize.backgroundSize(
                state: stateSize,
                time: timeSize,
                isVertical: false,
                contentAlignment: contentAlignment
            )
            
            backgroundContainer.yangbatch.remake { make in
                make.leading.equalToParent()
                make.vertical.equalToParent()
                make.width.equal(to: backgroundSize)
            }
            
            switch contentAlignment {
            case .leading:
                elementsContainer.yangbatch.remake { make in
                    make.diretionEdge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.leading.equalToParent()
                    make.trailing.equal(to: stateContainer.yangbatch.leading)
                    make.width.equal(to: isShowContent ? contentSize : 0)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: stateSize.width).multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.trailing.equalToParent()
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: timeSize.width).multiplier(by: multiplier)
                }
                
            case .trailing:
                elementsContainer.yangbatch.remake { make in
                    make.diretionEdge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.trailing.equalToParent()
                    make.leading.equal(to: timeContainer.yangbatch.trailing)
                    make.width.equal(to: isShowContent ? contentSize : 0)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: stateSize.width).multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.trailing.equal(to: contentContainer.yangbatch.leading)
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: timeSize.width).multiplier(by: multiplier)
                }
                
            case .top:
                let maxHeight = contentSize + max(stateSize.height, timeSize.height)
                elementsContainer.yangbatch.remake { make in
                    make.height.equal(to: maxHeight)
                    make.horizontal.equalToParent()
                    make.center.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.top.equalToParent()
                    make.bottom.equal(to: stateContainer.yangbatch.top)
                    make.height.equal(to: contentSize)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.top.equal(to: contentContainer.yangbatch.bottom)
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.width.equalToParent().multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.trailing.equalToParent()
                    make.top.equal(to: contentContainer.yangbatch.bottom)
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.width.equalToParent().multiplier(by: multiplier)
                }
                
            case .bottom:
                let maxHeight = contentSize + max(stateSize.height, timeSize.height)
                elementsContainer.yangbatch.remake { make in
                    make.height.equal(to: maxHeight)
                    make.horizontal.equalToParent()
                    make.center.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.bottom.equalToParent()
                    make.top.equal(to: stateContainer.yangbatch.bottom)
                    make.height.equal(to: contentSize)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.top.equal(to: contentContainer.yangbatch.bottom)
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.width.equalToParent().multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.trailing.equalToParent()
                    make.top.equal(to: contentContainer.yangbatch.bottom)
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.width.equalToParent().multiplier(by: multiplier)
                }
            }
        }
        
        super.updateConstraints()
    }
    
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        guard let scrollView else { return }
//        
//        switch direction {
//        case .bottom:
//            visualPositionView.frame = .init(
//                x: 0,
//                y: scrollView.frame.height,
//                width: scrollView.frame.width,
//                height: 0.1
//            )
//            
//        case .trailing:
//            visualPositionView.frame = .init(
//                x: scrollView.frame.width,
//                y: 0,
//                width: 0.1,
//                height: scrollView.frame.height
//            )
//        }
//    }
    
    // MARK: Refresh
    open override func prepareToRefresh(scrollView: UIScrollView) {
        super.prepareToRefresh(scrollView: scrollView)
        
        prepareDiretion(scrollView: scrollView)
    }
    
    private func prepareDiretion(scrollView: UIScrollView?) {
        
        guard let scrollView else { return }
        
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
        switch direction {
        case .bottom:   scrollView.alwaysBounceVertical = true
        case .trailing: scrollView.alwaysBounceHorizontal = true
        }
    }
    
    open override func scrollViewContentOffsetDidChange(oldOffset: CGPoint?, newOffset: CGPoint?) {
        
        guard
            let scrollView
        else {
            return
        }
        
        /// - Tag: Should Pulling ( Bouncing )
        let offset = scrollView.contentOffset
        let breakPoint = breakPoint(scrollView: scrollView)
        let translation: CGFloat
        switch direction {
        case .bottom: translation = offset.y - breakPoint
        case .trailing: translation = offset.x - breakPoint
        }
        
        // breakPoint <= 0, contentSize 还没有计算完, 如果内容少于 bounds.width 会出问题
//        guard breakPoint > 0 else { return }
        
        // 还没有开始触发临界点
        guard translation >= 0 else { return }
        
        /// - Tag: Pulling
        let progress: CGFloat
        
        switch direction {
        case .bottom:
            
            progress = min(max(abs(translation) / frame.height, 0), 1)
            
//            print(#function, #line, "Refresh Footer \(progress) !")
            
        case .trailing:
            
            progress = min(max(abs(translation) / frame.width, 0), 1)
            
//            print(#function, #line, "Refresh Footer \((translation, scrollView.contentOffset.x, frame)) \(progress) !")
            
        }
        
        if progress >= 1 {
            state = .willRefreshing
        } else {
            state = .pulling
        }
        
        self.progress = progress
        
    }
    
    internal override func refreshingTranslationElements() {
        super.refreshingTranslationElements()
        
        guard let scrollView else { return }
        
        let insets = initContentInsets
        
        switch direction {
        case .bottom:   scrollView.contentInset.bottom = insets.bottom + frame.height
        case .trailing: scrollView.contentInset.right = insets.right + frame.width
        }
        
    }
    
    internal override func resetTranslationElements() {
        super.resetTranslationElements()
        
        guard let scrollView else { return }
        
        let insets = initContentInsets
        
        switch direction {
        case .bottom:   scrollView.contentInset.bottom = insets.bottom
        case .trailing: scrollView.contentInset.right = insets.right
        }
        
    }
    
    internal override func breakPoint(scrollView: UIScrollView) -> CGFloat {
        var breakPoint = self.baseBreakPoint(scrollView: scrollView)
        switch direction {
        case .bottom:
            breakPoint -= initContentInsets.bottom + safeInsets.bottom

        case .trailing:
            breakPoint -= initContentInsets.right + safeInsets.right
        }
        return breakPoint
    }
    
    internal override func baseBreakPoint(scrollView: UIScrollView) -> CGFloat {
        let breakPoint: CGFloat
        switch direction {
        case .bottom:
            breakPoint = scrollView.contentSize.height - scrollView.frame.height

        case .trailing:
            breakPoint = scrollView.contentSize.width - scrollView.frame.width
        }
        return breakPoint
    }
    
    /// bounces offset
    internal override func scrollBreakPointOffset(scrollView: UIScrollView) -> CGFloat {
        
        let breakPoint = self.baseBreakPoint(scrollView: scrollView)
        
        let scrollBreakPoint: CGFloat
        switch direction {
        case .bottom:
            scrollBreakPoint = scrollView.contentOffset.y - breakPoint

        case .trailing:
            scrollBreakPoint = scrollView.contentOffset.x - breakPoint
        }
        return max(scrollBreakPoint, 0)
    }
    
}
