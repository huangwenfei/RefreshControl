//
//  RefreshTextTextHeader.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//

import UIKit
import Yang

open class RefreshTextTextHeader: RefreshHeader {
    
    // MARK: Properties - Provider
    open var stateProvider: RefreshTextStateProvider = .init()
    open var timeProvider: RefreshTextTimeProvider = .init()
    open var titleProvider: RefreshTextTextProvider = .init()
    
    // MARK: Properties
    open override var state: RefreshState {
        didSet {
            stateProvider.render(state: state, refresh: self)
            timeProvider.render(state: state, refresh: self)
            titleProvider.render(state: state, refresh: self)
            setNeedsUpdate()
        }
    }
    
    open override var direction: RefreshHeader.Direction {
        didSet {
            stateProvider.convertSources(isLineFeed: direction.isHorizontal)
            timeProvider.convertSources(isLineFeed: direction.isHorizontal)
            titleProvider.convertSources(isLineFeed: direction.isHorizontal)
            self.state = state
        }
    }
    
    // MARK: Init
    open override func initSetups() {
        super.initSetups()
        stateProvider.initSetups(refresh: self)
        timeProvider.initSetups(refresh: self)
        titleProvider.initSetups(refresh: self)
    }
    
    // MARK: Layout
    open override func updateConstraints() {
        stateProvider.updateConstraints(refresh: self)
        timeProvider.updateConstraints(refresh: self)
        titleProvider.updateConstraints(refresh: self)
        super.updateConstraints()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        stateProvider.layoutSubviews(refresh: self)
        timeProvider.layoutSubviews(refresh: self)
        titleProvider.layoutSubviews(refresh: self)
    }
    
    open override var stateSize: CGSize {
        stateProvider.size(directionSize: directionSize)
    }
    
    open override var timeSize: CGSize {
        timeProvider.size(directionSize: directionSize)
    }
    
    // MARK: Stete
    open func setState(text: String, for state: OptionRefreshState) {
        self.setState(text: text, isInsetLineFeedToText: direction.isHorizontal, for: state)
    }
    
    open func setState(text: String, isInsetLineFeedToText: Bool, for state: OptionRefreshState) {
        stateProvider.set(text: text, isInsetLineFeedToText: isInsetLineFeedToText, for: state)
    }
    
    open func setState(textFont font: UIFont, for state: OptionRefreshState) {
        stateProvider.set(textFont: font, for: state)
    }
    
    open func setState(textColor color: UIColor, for state: OptionRefreshState) {
        stateProvider.set(textColor: color, for: state)
    }
    
    // MARK: Time
    open func setTime(text: String, for state: OptionRefreshState) {
        self.setTime(text: text, isInsetLineFeedToText: direction.isHorizontal, for: state)
    }
    
    open func setTime(text: String, isInsetLineFeedToText: Bool, for state: OptionRefreshState) {
        timeProvider.set(text: text, isInsetLineFeedToText: isInsetLineFeedToText, for: state)
    }
    
    open func setTime(textFont font: UIFont, for state: OptionRefreshState) {
        timeProvider.set(textFont: font, for: state)
    }
    
    open func setTime(textColor color: UIColor, for state: OptionRefreshState) {
        timeProvider.set(textColor: color, for: state)
    }
    
    // MARK: Indicator
    open func setTitle(text: String, for state: OptionRefreshState) {
        self.setTitle(text: text, isInsetLineFeedToText: direction.isHorizontal, for: state)
    }
    
    open func setTitle(text: String, isInsetLineFeedToText: Bool, for state: OptionRefreshState) {
        titleProvider.set(text: text, isInsetLineFeedToText: isInsetLineFeedToText, for: state)
    }
    
    open func setTitle(textFont font: UIFont, for state: OptionRefreshState) {
        titleProvider.set(textFont: font, for: state)
    }
    
    open func setTitle(textColor color: UIColor, for state: OptionRefreshState) {
        titleProvider.set(textColor: color, for: state)
    }
    
    // MARK: Refresh
    open override func startRefreshing() {
        super.startRefreshing()
        stateProvider.startRefreshing(refresh: self)
        timeProvider.startRefreshing(refresh: self)
        titleProvider.startRefreshing(refresh: self)
    }
    
    open override func pullingProgress(_ value: CGFloat) {
        super.pullingProgress(value)
        stateProvider.pullingProgress(refresh: self, progress: value)
        timeProvider.pullingProgress(refresh: self, progress: value)
        titleProvider.pullingProgress(refresh: self, progress: value)
    }
    
    open override func refreshing() {
        super.refreshing()
        stateProvider.refreshing(refresh: self)
        timeProvider.refreshing(refresh: self)
        titleProvider.refreshing(refresh: self)
    }
    
    open override func finishedRefreshing(isNoMoreData: Bool) {
        super.finishedRefreshing(isNoMoreData: isNoMoreData)
        stateProvider.finishedRefreshing(refresh: self, isNoMoreData: isNoMoreData)
        timeProvider.finishedRefreshing(refresh: self, isNoMoreData: isNoMoreData)
        titleProvider.finishedRefreshing(refresh: self, isNoMoreData: isNoMoreData)
    }
    
    open override func resetRefreshing() {
        super.resetRefreshing()
        stateProvider.resetRefreshing(refresh: self)
        timeProvider.resetRefreshing(refresh: self)
        titleProvider.resetRefreshing(refresh: self)
    }
    
}
