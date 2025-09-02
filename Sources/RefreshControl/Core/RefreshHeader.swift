//
//  RefreshHeader.swift
//  Xiaosuimian
//
//
//  `content`: animating content (text, icon, animate, anything)
//  `state content`: refresh state content
//  `time content`: last update time content
//  `[]`: a group fill two lines or a content fill two lines
//
//  `header-top`:
//     top
//          `content`
//       `state content`
//       `time content`
//
//     leading
//       [`content`     `state content`
//        `content`]    `time content`
//
//     bottom
//       `state content`
//       `time content`
//          `content`
//
//     trailing
//       `state content`   [`content`
//       `time content`     `content`]
//
//
//  `header-leading`:
//     top
//                    `content`
//       [`time content`    `state content`]
//
//     leading
//       `content`   `time content`    `state content`
//
//     bottom
//       [`time content`     `state content`]
//                    `content`
//
//     trailing
//       `time content`    `state content`     `content`
//
//
//  Created by windy on 2025/7/17.
//

import UIKit
import Yang

// MARK: Refresh Header Protocols

public protocol RefreshHeaderProtocol: Refresh, RefreshDirectionHeader { }

public protocol RefreshDirectionHeader {
    var direction: RefreshHeaderDirection { get set }
}

public protocol RefreshHeaderProvider {
    func startRefreshing(refresh: RefreshHeaderStatePropertiesMap)
    func pullingProgress(refresh: RefreshHeaderStatePropertiesMap, progress value: CGFloat)
    func refreshing(refresh: RefreshHeaderStatePropertiesMap)
    func finishedRefreshing(refresh: RefreshHeaderStatePropertiesMap, isNoMoreData: Bool)
    func resetRefreshing(refresh: RefreshHeaderStatePropertiesMap)
}

// MARK: Refresh Header

open class RefreshHeader: Refresh, RefreshHeaderProtocol {
    
    // MARK: Types
    public typealias Direction = RefreshHeaderDirection
    
    // MARK: Properties - Mode
    open override var stateMode: ContentStateMode { .header }
    
    // MARK: Properties - Direction
    open var direction: Direction = .top {
        didSet {
            prepareDiretion(scrollView: scrollView)
            setNeedsUpdate()
        }
    }
    
    // MARK: Init
    open override func initSetups() {
        super.initSetups()
        
        switch direction {
        case .top:     contentAlignment = .leading
        case .leading: contentAlignment = .trailing
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
        case .top:
            let totalSize = directionSize.totalSize(
                state: stateSize,
                time: timeSize,
                isVertical: true,
                contentAlignment: contentAlignment
            )
            
            self.frame = .init(
                x: 0,
                y: -totalSize + offset.y + bouncesOffset,
                width: scrollView.frame.width,
                height: totalSize
            )
            
        case .leading:
            let totalSize = directionSize.totalSize(
                state: stateSize,
                time: timeSize,
                isVertical: false,
                contentAlignment: contentAlignment
            )
            
            self.frame = .init(
                x: -totalSize + offset.x + bouncesOffset,
                y: 0,
                width: totalSize,
                height: scrollView.frame.height
            )
            
        }
        
//        print(#function, #line, "Pulling Header", self.frame, offset)
        
    }
    
    open override func updateConstraints() {
        
        let contentSize = directionSize.content
        let stateSize = isShowState ? self.stateSize : .zero
        let timeSize = isShowTime ? self.timeSize : .zero
        
        switch direction {
        case .top:
            
            let backgroundSize = directionSize.backgroundSize(
                state: stateSize,
                time: timeSize,
                isVertical: true,
                contentAlignment: contentAlignment
            )
            
            backgroundContainer.yangbatch.remake { make in
                make.bottom.equalToParent()
                make.horizontal.equalToParent()
                make.height.equal(to: backgroundSize)
            }
            
            switch contentAlignment {
            case .leading:
                elementsContainer.yangbatch.remake { make in
                    make.edge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.leading.equalToParent()
                    make.trailing.equalToParent(isShowContent ? .centerX : .leading)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.trailing.equalToParent()
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
            case .trailing:
                elementsContainer.yangbatch.remake { make in
                    make.edge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.trailing.equalToParent()
                    make.leading.equalToParent(.centerX)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.trailing.equal(to: contentContainer.yangbatch.leading)
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.height.equalToParent().multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.trailing.equal(to: contentContainer.yangbatch.leading)
                    make.top.equal(to: stateContainer.yangbatch.bottom)
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
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
                    make.bottom.equal(to: stateContainer.yangbatch.top)
                    make.height.equal(to: isShowContent ? contentSize : 0)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.top.equal(to: contentContainer.yangbatch.bottom)
                    make.horizontal.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: stateSize.height).multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.bottom.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: timeSize.height).multiplier(by: multiplier)
                }
                
            case .bottom:
                elementsContainer.yangbatch.remake { make in
                    make.diretionEdge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.top.equal(to: timeContainer.yangbatch.bottom)
                    make.bottom.equalToParent()
                    make.height.equal(to: isShowContent ? contentSize : 0)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.top.equalToParent()
                    make.horizontal.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: stateSize.height).multiplier(by: multiplier)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.horizontal.equalToParent()
                    make.bottom.equal(to: contentContainer.yangbatch.top)
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.height.equal(to: timeSize.height).multiplier(by: multiplier)
                }
            }
            
        case .leading:
            
            let backgroundSize = directionSize.backgroundSize(
                state: stateSize,
                time: timeSize,
                isVertical: false,
                contentAlignment: contentAlignment
            )
            
            backgroundContainer.yangbatch.remake { make in
                make.trailing.equalToParent()
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
                    make.trailing.equal(to: timeContainer.yangbatch.leading)
                    make.width.equal(to: isShowContent ? contentSize : 0)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equal(to: contentContainer.yangbatch.trailing)
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: timeSize.width).multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.trailing.equalToParent()
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: stateSize.width).multiplier(by: multiplier)
                }
                
            case .trailing:
                elementsContainer.yangbatch.remake { make in
                    make.diretionEdge.equalToParent()
                }
                
                contentContainer.yangbatch.remake { make in
                    make.vertical.equalToParent()
                    make.trailing.equalToParent()
                    make.leading.equal(to: stateContainer.yangbatch.trailing)
                    make.width.equal(to: isShowContent ? contentSize : 0)
                }
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: timeSize.width).multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.trailing.equal(to: contentContainer.yangbatch.leading)
                    make.vertical.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
                    case (true, _):  multiplier = 1
                    case (false, _): multiplier = 0.001
                    }
                    make.width.equal(to: stateSize.width).multiplier(by: multiplier)
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
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
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
                
                stateContainer.yangbatch.remake { make in
                    make.trailing.equalToParent()
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
                
                timeContainer.yangbatch.remake { make in
                    make.leading.equalToParent()
                    make.bottom.equal(to: contentContainer.yangbatch.top)
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowTime, isShowState) {
                    case (true, true):  multiplier = 0.5
                    case (true, false): multiplier = 1
                    case (false, _):    multiplier = 0.001
                    }
                    make.width.equalToParent().multiplier(by: multiplier)
                }
                
                stateContainer.yangbatch.remake { make in
                    make.trailing.equalToParent()
                    make.bottom.equal(to: contentContainer.yangbatch.top)
                    make.top.equalToParent()
                    let multiplier: CGFloat
                    switch (isShowState, isShowTime) {
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
//        case .top:
//            visualPositionView.frame = .init(
//                x: 0,
//                y: 0,
//                width: scrollView.frame.width,
//                height: 0.1
//            )
//            
//        case .leading:
//            visualPositionView.frame = .init(
//                x: 0,
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
        case .top:     scrollView.alwaysBounceVertical = true
        case .leading: scrollView.alwaysBounceHorizontal = true
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
        case .top:     translation = offset.y - breakPoint
        case .leading: translation = offset.x - breakPoint
        }
        
        // breakPoint > 0, contentSize 还没有计算完, 如果内容少于 bounds.width 会出问题
//        guard breakPoint <= 0 else { return }
        
        // 还没有开始触发临界点
        guard translation < 0 else { return }
        
        /// - Tag: Pulling
        let progress: CGFloat
        
        switch direction {
        case .top:
            
            progress = min(max(abs(translation) / frame.height, 0), 1)
            
//            print(#function, #line, "Refresh Header \((offset.y, initContentInsets.top, scrollView.safeAreaInsets.top)) \(translation) \(frame.height) \(progress) !")
            
        case .leading:
            
            progress = min(max(abs(translation) / frame.width, 0), 1)
            
//            print(#function, #line, "Refresh Header \((translation, scrollView.contentOffset.x, frame.width)) \(progress) !")
            
        }
        
        if progress >= 1 {
            state = .willRefreshing
        } else {
            state = .pulling
        }
        
        self.progress = progress
     
//        print(#function, #line, "Refresh Header", self.progress)
        
    }
    
    internal override func refreshingTranslationElements() {
        super.refreshingTranslationElements()
        
        guard let scrollView else { return }
        
        let insets = initContentInsets
        
        switch direction {
        case .top:     scrollView.contentInset.top = insets.top + frame.height
        case .leading: scrollView.contentInset.left = insets.left + frame.width
        }
        
    }
    
    internal override func resetTranslationElements() {
        super.resetTranslationElements()
        
        guard let scrollView else { return }
        
        let insets = initContentInsets
        
        switch direction {
        case .top:     scrollView.contentInset.top = insets.top
        case .leading: scrollView.contentInset.left = insets.left
        }
        
    }
    
    internal override func breakPoint(scrollView: UIScrollView) -> CGFloat {

        var breakPoint = self.baseBreakPoint(scrollView: scrollView)
        switch direction {
        case .top:     breakPoint -= initContentInsets.top + safeInsets.top
        case .leading: breakPoint -= initContentInsets.left + safeInsets.left
        }
        return breakPoint
    }
    
    internal override func baseBreakPoint(scrollView: UIScrollView) -> CGFloat {
        
        let breakPoint: CGFloat
        switch direction {
        case .top:     breakPoint = 0
        case .leading: breakPoint = 0
        }
        return breakPoint
    }
    
    /// bounces offset
    internal override func scrollBreakPointOffset(scrollView: UIScrollView) -> CGFloat {
        
        let breakPoint = self.baseBreakPoint(scrollView: scrollView)
        
        let scrollBreakPoint: CGFloat
        switch direction {
        case .top:
            scrollBreakPoint = breakPoint - scrollView.contentOffset.y

        case .leading:
            scrollBreakPoint = breakPoint - scrollView.contentOffset.x
        }
//        print(#function, #line, "Pulling Header", scrollBreakPoint)
        return max(scrollBreakPoint, 0)
    }
    
}
