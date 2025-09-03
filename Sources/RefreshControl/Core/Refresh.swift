//
//  Refresh.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/16.
//

import UIKit
import Yang

// MARK: Refresh State
public enum RefreshState: Int, Hashable, Comparable {
    
    /// 闲置 或 准备拖拽
    case idle
    /// 拖拽中，没有达到刷新条件 ( 松手后会重置成 idle )
    case pulling
    /// 拖拽中，已经达到可以刷新的条件 ( 松手后会转为 refreshing 刷新 )
    case willRefreshing
    /// 刷新中，调用刷新回调方法
    case refreshing
    /// 完成刷新，通常表示有新数据，默认会自动设置成 idle
    case refreshed
    /// 完成刷新，没有新数据，不会自动设置成 idle
    case noMoreData
    
    public var option: OptionRefreshState {
        .init(rawValue: 1 << rawValue)
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public var leftEdge: RawValue {
        max(rawValue, 0)
    }
    
    public var rightEdge: RawValue {
        let last = Self.noMoreData.rawValue
        return min(last - rawValue, last)
    }
    
}

public struct OptionRefreshState: OptionSet, Hashable {

    public typealias RawValue = Int
    
    public var rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public static let idle           = RefreshState.idle.option
    public static let pulling        = RefreshState.pulling.option
    public static let willRefreshing = RefreshState.willRefreshing.option
    public static let refreshing     = RefreshState.refreshing.option
    public static let refreshed      = RefreshState.refreshed.option
    public static let noMoreData     = RefreshState.noMoreData.option
    
    public static let all: Self = [
        .idle, .pulling,
        .willRefreshing, .refreshing,
        .refreshed, .noMoreData
    ]
    
    public static let beforeRefresing: Self = [.idle, .pulling]
    public static let currentRefresing: Self = [.willRefreshing, .refreshing]
    public static let afterRefresing: Self = [.refreshed, .noMoreData]
    
    public var states: [RefreshState] {
        var result: [RefreshState] = []
        if self.contains(.idle) { result.append(.idle) }
        if self.contains(.pulling) { result.append(.pulling) }
        if self.contains(.willRefreshing) { result.append(.willRefreshing) }
        if self.contains(.refreshing) { result.append(.refreshing) }
        if self.contains(.refreshed) { result.append(.refreshed) }
        if self.contains(.noMoreData) { result.append(.noMoreData) }
        return result
    }
    
}

// MARK: Refresh Header & Footer
public enum RefreshHeaderDirection: Int, Hashable {
    case top, leading
    
    public var isHorizontal: Bool { self == .leading }
    public var isVertical: Bool { self == .top }
}

public enum RefreshFooterDirection: Int, Hashable {
    case bottom, trailing
    
    public var isHorizontal: Bool { self == .trailing }
    public var isVertical: Bool { self == .bottom }
}

// MARK: Refresh Protocols

public protocol RefreshStateProtocol {
    var state: RefreshState { get set }
}

public protocol RefreshStateTimeAutoCalculate {
    var stateSize: CGSize { get }
    var timeSize: CGSize { get }
}

public protocol RefreshViewPrepare {
    func initSetups(refresh: Refresh)
    func updateConstraints(refresh: Refresh)
    func layoutSubviews(refresh: Refresh)
}

public protocol RefreshLineFeedProtocol { }
extension RefreshLineFeedProtocol {
    public static func dealingLineFeedText(_ text: String) -> String {
        var result: String = ""
        for (index, char) in text.enumerated() {
            guard index != text.count - 1 else {
                result += String(char)
                break
            }
            result += (String(char) + "\n")
        }
        return result
    }
    
    public func dealingLineFeedText(_ text: String) -> String {
        Self.dealingLineFeedText(text)
    }
    
    public static func dealingUnLineFeedText(_ text: String) -> String {
        text.replacingOccurrences(of: "\n", with: "")
    }
    
    public func dealingUnLineFeedText(_ text: String) -> String {
        Self.dealingUnLineFeedText(text)
    }
}

public protocol RefreshStateMapProperties {
    var isAutoFillInfoWhenEmptyStateInfo: Bool { get set }
}

public protocol RefreshStateMapProtocol { }
extension RefreshStateMapProtocol {
    
    public func loopFillStateInfo<R>(isAutoFillInfoWhenEmptyStateInfo: Bool, current: RefreshState, in dict: [RefreshState: R], defaultValue: R) -> R {
        
        guard isAutoFillInfoWhenEmptyStateInfo else {
            return dict[current] ?? defaultValue
        }
        
        let maxCount = max(current.leftEdge, current.rightEdge)
        
        var offsetCount = 0
        
        var result: R = defaultValue
        
        while offsetCount <= maxCount {
            
            if
                let state = RefreshState(rawValue: current.rawValue - offsetCount),
                let value = dict[state]
            {
                result = value
                break
            }
            
            if
                let state = RefreshState(rawValue: current.rawValue + offsetCount),
                let value = dict[state]
            {
                result = value
                break
            }
            
            offsetCount += 1
            
        }
        
        return result
            
    }
    
//    public func mappingState() {  }
    
}

public typealias RefreshStatePropertiesMap = RefreshStateProtocol & RefreshStateMapProperties

public typealias RefreshHeaderStatePropertiesMap = RefreshDirectionHeader & RefreshStatePropertiesMap
public typealias RefreshFooterStatePropertiesMap = RefreshDirectionFooter & RefreshStatePropertiesMap

// MARK: Refresh

open class Refresh: UIView, RefreshStateProtocol, RefreshStateTimeAutoCalculate, RefreshStateMapProperties, RefreshStateMapProtocol {
    
    // MARK: Types
    public typealias ActionClosure = (_ refresh: Refresh) -> Void
    
    // MARK: Properties - Parent
    open private(set) weak var scrollView: UIScrollView? = nil
    
    // MARK: Properties - Action
    open var closure: ActionClosure? = nil
    
    open weak var target: AnyObject? = nil
    open var action: Selector? = nil
    
    // MARK: Properties - Content
    open lazy var elementsContainer: UIView = .init()
    
    open lazy var backgroundContainer: UIView = .init()
    open lazy var contentContainer: UIView = .init()
    open lazy var stateContainer: UIView = .init()
    open lazy var timeContainer: UIView = .init()
    
    open var stateMode: ContentStateMode { fatalError("请使用子类...") }
    open var isHeader: Bool { stateMode == .header }
    open var isFooter: Bool { stateMode == .footer }
    
    open var contentAlignment: ContentAlignment = .leading {
        didSet { setNeedsUpdate() }
    }
    
    open var isShowContent: Bool = true
    
    // MARK: Properties - Safe Insets
    open var isAdjustSafeInsets: Bool = false
    
    internal var safeInsets: UIEdgeInsets {
//        isAdjustSafeInsets ? (scrollView?.safeAreaInsets ?? .zero) : .zero
        (scrollView?.safeAreaInsets ?? .zero)
    }
    
    // MARK: Size
    /// 刷新时显示的高度(竖向)或宽度(横向)
    open var directionSize: DirectionSize = .init(content: 32)
    
    /// 拖拽的时候，背景是否改变高度(竖向)或宽度(横向) —— 调整 directionSize 的值
    open var isBackgroundStretchOn: Bool = false
    
    // MARK: Properties - State
    open var state: RefreshState = .idle {
        didSet {
            if state == .idle {
                self.alpha = isFadeShowWhenPulling ? 0.0 : 1.0
            }
            setNeedsUpdate()
        }
    }
    
    open var isShowState: Bool = true
    
    // 当前状态下的 stateInfo 为空，则默认从上一个状态拿到 info，如果上一个状态也为空则去下一个状态拿，如果下一个也没有，则从上上一个状态拿，如此循环。
    open var isAutoFillInfoWhenEmptyStateInfo: Bool = false
    
    // 达到条件后，直接 finished
    open var initContentInsets: UIEdgeInsets = .zero
    open var isSkipRefreshingState: Bool = false
    
    // MARK: Properties - Time
    open var isShowTime: Bool = true
    
    // MARK: Properties - Progress
    open var progress: CGFloat = 0 {
        didSet { pullingProgress(progress) }
    }
    
//    open func nanProgressClamp(_ value: CGFloat) -> CGFloat {
//        if progress.isNaN { return .zero }
//        else if progress.isSignalingNaN { return .zero }
//        else if progress.isInfinite { return .zero }
//        else if progress.isFinite { return .zero }
//        else { return progress }
//    }
    
    // MARK: Properties - Fade
    open var isFadeShowWhenPulling: Bool = false
    
    // MARK: Properties - Refresh
    open var animationConfiguration: AnimationConfiguration = .init()
    
    // MARK: Properties - Internal
    internal weak var panGestureRecognizer: UIPanGestureRecognizer? = nil
    
    // MARK: Init
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        initSetups()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSetups()
    }
    
    open func initSetups() {
        
        backgroundContainer.yang.addToParent(self)
        elementsContainer.yang.addToParent(self)
        
        contentContainer.yang.addToParent(elementsContainer)
        stateContainer.yang.addToParent(elementsContainer)
        timeContainer.yang.addToParent(elementsContainer)
        
//        elementsContainer.backgroundColor = .blue
//        contentContainer.backgroundColor = .purple
    }
    
    // MARK: Container
    open func container(by provider: RefreshContainerProvider) -> UIView {
        switch provider {
        case .content:    return contentContainer
        case .state:      return stateContainer
        case .time:       return timeContainer
        case .background: return backgroundContainer
        }
    }
    
    // MARK: Layout
    open func selfLayout(scrollView: UIScrollView?) { }
    
    open func setNeedsUpdate() {
        setNeedsUpdateConstraints()
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    open var stateSize: CGSize {
        stateContainer.sizeToFit()
        return stateContainer.frame.size
    }
    
    open var timeSize: CGSize {
        timeContainer.sizeToFit()
        return timeContainer.frame.size
    }
    
    // MARK: Callback
    open func set(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        self.closure = nil
    }

    open func set(action closure: @escaping ActionClosure) {
        self.target = nil
        self.action = nil
        self.closure = closure
    }
    
    // MARK: State
    open func loopFillStateInfo<R>(current: RefreshState, in dict: [RefreshState: R], defaultValue: R) -> R {
        
        loopFillStateInfo(
            isAutoFillInfoWhenEmptyStateInfo: isAutoFillInfoWhenEmptyStateInfo,
            current: current,
            in: dict,
            defaultValue: defaultValue
        )
        
    }
    
    // MARK: Scrollview
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard
            newSuperview != nil,
            let scrollView = newSuperview as? UIScrollView
        else {
            return
        }
        
        self.scrollView = scrollView
        
        removeObservers()
        prepareToRefresh(scrollView: scrollView)
        addObservers()
        
    }
    
    open func prepareToRefresh(scrollView: UIScrollView) {
        
        selfLayout(scrollView: scrollView)
        
        state = .idle
        
    }
    
    // MARK: Obervers - Pan
    private func addObservers() {
        
        scrollView?.addObserver(
            self,
            forKeyPath: #keyPath(UIScrollView.contentOffset),
            options: [.old, .new],
            context: nil
        )
        
        scrollView?.addObserver(
            self,
            forKeyPath: #keyPath(UIScrollView.contentSize),
            options: [.old, .new],
            context: nil
        )
        
        panGestureRecognizer = scrollView?.panGestureRecognizer
        panGestureRecognizer?.addObserver(
            self,
            forKeyPath: #keyPath(UIGestureRecognizer.state),
            options: [.old, .new],
            context: nil
        )
        
        addLanguageObserver()
        
    }
    
    private func removeObservers() {
        
        superview?.removeObserver(
            self, forKeyPath: #keyPath(UIScrollView.contentOffset)
        )
        superview?.removeObserver(
            self, forKeyPath: #keyPath(UIScrollView.contentSize)
        )
        
        panGestureRecognizer?.removeObserver(
            self, forKeyPath: #keyPath(UIGestureRecognizer.state)
        )
        panGestureRecognizer = nil
        
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard isUserInteractionEnabled else { return }
        
        if keyPath == #keyPath(UIScrollView.contentSize) {
            scrollViewContentSizeDidChange(change)
        }
        
        guard isHidden == false else { return }
        
        if keyPath == #keyPath(UIScrollView.contentOffset) {
            scrollViewContentOffsetDidChange(change)
        }
        
        if keyPath == #keyPath(UIPanGestureRecognizer.state) {
            scrollViewPanStateDidChange(change)
        }
        
    }
    
    private func scrollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        let oldStateValue = change?[.oldKey] as? Int
        let oldState = oldStateValue != nil ? UIGestureRecognizer.State(rawValue: oldStateValue!) : nil
        
        let newStateValue = change?[.newKey] as? Int
        let newState = newStateValue != nil ? UIGestureRecognizer.State(rawValue: newStateValue!) : nil
        
        scrollViewPanStateDidChange(oldState: oldState, newState: newState)
        
    }
    
    private func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        let oldOffset = change?[.oldKey] as? CGPoint
        let newOffset = change?[.newKey] as? CGPoint
        
        selfLayout(scrollView: scrollView)
        
        scrollViewContentOffsetDidChange(oldOffset: oldOffset, newOffset: newOffset)
        
    }
    
    private func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        let oldSize = change?[.oldKey] as? CGSize
        let newSize = change?[.newKey] as? CGSize
        
        if oldSize != newSize {
            selfLayout(scrollView: scrollView)
            scrollView?.sendSubviewToBack(self)
            if state < .refreshing {
                initContentInsets = scrollView?.contentInset ?? .zero
//                print(#function, #line, initContentInsets)
            }
        }
        
        scrollViewContentSizeDidChange(oldSize: oldSize, newSize: newSize)
        
    }
    
    
    open func scrollViewPanStateDidChangeDefault(oldState: UIGestureRecognizer.State?, newState: UIGestureRecognizer.State?) {
        
        switch newState {
        case .began:
            state = .idle
            
        case .changed:
            break
            
        case .ended:
            if state == .willRefreshing {
                startRefreshing()
                skipableFinish()
            } else {
                skipableReset()
            }
            
        case .cancelled:
            skipableReset()
            
        default:
            break
        }
        
    }
    
    
    open func scrollViewPanStateDidChange(oldState: UIPanGestureRecognizer.State?, newState: UIPanGestureRecognizer.State?) {
        
        scrollViewPanStateDidChangeDefault(oldState: oldState, newState: newState)
    }
    
    open func scrollViewContentOffsetDidChange(oldOffset: CGPoint?, newOffset: CGPoint?) { }
    
    open func scrollViewContentSizeDidChange(oldSize: CGSize?, newSize: CGSize?) { }
    
    // MARK: Obervers - Language
    private func addLanguageObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChangeAction),
            name: RefreshLocalizable.languageNotifiName,
            object: RefreshLocalizable.shared
        )
    }
    
    @objc private func languageChangeAction() {
        languageDidChange()
    }
    
    open func languageDidChange() {
        /// Rerender Text Elements
    }
    
    // MARK: Refresh
    open var isRefreshing: Bool { state == .refreshing }
    
    open func startRefreshing() {
        
        self.progress = 1.0
        
        UIView.animate(withDuration: animationConfiguration.duration) {
            self.alpha = 1.0
        }
        
    }
    
    open func pullingProgress(_ value: CGFloat) {
//        defer { print(#function, #line, value) }
        guard isFadeShowWhenPulling else { return }
        self.alpha = value
    }
    
    open func finishedRefreshing() {
        finishedRefreshing(isNoMoreData: false)
    }
    
    open func finishedRefreshing(isNoMoreData: Bool) {
        state = isNoMoreData ? .noMoreData : .refreshed
        skipableReset()
    }
    
    open func refreshing() {
        
        self.state = .refreshing
        
        if
            let target,
            let action,
            target.responds(to: action)
        {
            _ = target.perform(action, with: self)
        }
        
        if let closure { closure(self) }
        
    }
    
    open func resetRefreshing() {
        state = .idle
        self.progress = 0.0
        UIView.animate(withDuration: animationConfiguration.duration) {
            self.alpha = 0.0
        }
    }
    
    open func skipableFinish() {
        if isSkipRefreshingState {
            self.refreshing()
        } else {
            UIView.animate(withDuration: animationConfiguration.duration) {
                self.refreshingTranslationElements()
            } completion: { isFinished in
                self.refreshing()
            }
        }
    }
    
    open func skipableReset() {
        if isSkipRefreshingState {
            self.resetRefreshing()
        } else {
            UIView.animate(withDuration: animationConfiguration.duration) {
                self.resetTranslationElements()
            } completion: { isFinished in
                self.resetRefreshing()
            }
        }
    }
    
    // MARK: Internal
    internal func refreshingTranslationElements() {
        
    }
    
    internal func resetTranslationElements() {
        
    }
    
    internal func breakPoint(scrollView: UIScrollView) -> CGFloat {
        .zero
    }
    
    internal func baseBreakPoint(scrollView: UIScrollView) -> CGFloat {
        .zero
    }
    
    internal func scrollBreakPointOffset(scrollView: UIScrollView) -> CGFloat {
        .zero
    }
    
    // MARK: Update
    open func update(elementsOn elements: ElementsOn) {
        isShowContent = elements.isShowContent
        isShowState = elements.isShowState
        isShowTime = elements.isShowTime
        setNeedsUpdate()
    }
    
}

extension Refresh {
    
    public enum ContentStateMode: Int, Hashable {
        case header, footer
    }
    
    public struct DirectionBackgroundInset: Hashable {
        
        public var leading: CGFloat
        public var trailing: CGFloat
        
        public static let zero: Self = .init()
        
        public init(leading: CGFloat = .zero, trailing: CGFloat = .zero) {
            self.leading = leading
            self.trailing = trailing
        }
    }
    
    public struct DirectionSize: Hashable {
        
        /// animating content height or width
        public var content: CGFloat = .zero
        /// if state == nil, -> auto calculate
        public var state: CGFloat? = nil
        /// if time == nil, -> auto calculate
        public var time: CGFloat? = nil
        
        /// if bg == nil, -> bg = content + state + time
        public var background: CGFloat? = nil
        public var backgroundInset: DirectionBackgroundInset = .zero
        
        public init(content: CGFloat, state: CGFloat? = nil, time: CGFloat? = nil, background: CGFloat? = nil, backgroundInset: DirectionBackgroundInset = .zero) {
            
            self.content = content
            self.state = state
            self.time = time
            self.background = background
            self.backgroundInset = backgroundInset
        }
        
        public func totalSize(state: CGSize, time: CGSize, isVertical: Bool, contentAlignment: ContentAlignment) -> CGFloat {
            
            if isVertical {
                switch contentAlignment {
                case .leading, .trailing:
                    return max(content, max(state.height, time.height))
                case .top, .bottom:
                    return content + state.height + time.height
                }
            } else {
                switch contentAlignment {
                case .leading, .trailing:
                    return content + state.width + time.width
                case .top, .bottom:
                    return max(content, max(state.width, time.width))
                }
            }
            
        }
        
        public func backgroundSize(state: CGSize, time: CGSize, isVertical: Bool, contentAlignment: ContentAlignment) -> CGFloat {
            
            let result = totalSize(
                state: state,
                time: time,
                isVertical: isVertical,
                contentAlignment: contentAlignment
            )
            
            let inset = backgroundInset
            
            return result - inset.leading - inset.trailing
        }
        
    }
    
    public enum ContentAlignment: Int, Hashable {
        case leading, trailing, top, bottom
    }
    
    public struct AnimationConfiguration: Hashable {
        public var duration: TimeInterval = 0.25
    }
    
    public struct ElementsOn: RawRepresentable, OptionSet {
        
        public typealias RawValue = Int
        public let rawValue: RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
        
        public static let content: Self = .init(rawValue: 1 << 0)
        public static let state: Self = .init(rawValue: 1 << 1)
        public static let time: Self = .init(rawValue: 1 << 2)
        
        public static let empty: Self = []
        public static let all: Self = [.content, .state, .time]
        
        public var isShowContent: Bool { self.contains(.content) }
        public var isShowState: Bool { self.contains(.state) }
        public var isShowTime: Bool { self.contains(.time) }
        
    }
    
}
