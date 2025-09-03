//
//  TestingRefresh.swift
//  RefreshControl-Ep
//
//  Created by windy on 2025/9/1.
//

import UIKit
import RefreshControl

// MARK: Refresh

struct TestingRefreshSources {
    
    static let angryImages: [UIImage] = (0 ... 11)
        .map { index in
            var idxStr = "\(index)"
            if idxStr.count < 2 { idxStr = "0" + idxStr }
            let image = UIImage(named: "angry_\(idxStr)")
            return image
        }
        .compactMap({
            $0
        })
    
    static let catImages: [UIImage] = (0 ... 10)
        .map { index in
            var idxStr = "\(index)"
            if idxStr.count < 2 { idxStr = "0" + idxStr }
            let image = UIImage(named: "cat_\(idxStr)")
            return image
        }
        .compactMap({
            $0
        })
    
}

// MARK: Header

struct TestingRefreshHeader {
    
    static func text(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshHeader.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextTextHeader {
        
        let header = RefreshTextTextHeader()
        header.contentAlignment = contentAlignment
        header.direction = direction
        header.directionSize = .init(content: 90)
        header.update(elementsOn: elementsOn)
        header.set(target: target, action: action)
        header.setState(text: "调整排序", for: [.idle, .pulling])
        header.setState(text: "释放进入", for: .willRefreshing)
        header.setState(text: "进入中...", for: .refreshing)
        header.setState(textFont: .systemFont(ofSize: 14), for: .all)
        header.setState(textColor: .lightGray, for: .all)
        header.setTime(text: "\(Date())", for: .all)
        header.setTitle(text: "Text", for: .all)
        header.setTitle(textFont: .systemFont(ofSize: 18), for: .all)
        header.setTitle(textColor: .red, for: [.idle, .pulling])
        header.setTitle(textColor: .green, for: .willRefreshing)
        header.setTitle(textColor: .yellow, for: .refreshing)
        return header
    }
    
    static func arrow(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshHeader.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextArrowHeader {
        
        let header = RefreshTextArrowHeader()
        header.contentAlignment = contentAlignment
        header.direction = direction
        header.update(elementsOn: elementsOn)
        header.set(target: target, action: action)
        header.setState(text: "调整排序", for: [.idle, .pulling])
        header.setState(text: "释放进入", for: [.willRefreshing, .refreshing])
        header.setState(textFont: .systemFont(ofSize: 14), for: .all)
        header.setState(textColor: .lightGray, for: .all)
        header.setTime(text: "\(Date())", for: .all)
        header.setIndicator(color: .lightGray, for: .all)
        header.setIndicator(size: .init(width: 18, height: 14), for: .all)
        return header
    }
    
    static func images(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshHeader.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextImagesHeader {

        let header = RefreshTextImagesHeader()
        header.contentAlignment = contentAlignment
        header.direction = direction
        header.directionSize = .init(content: 90)
        header.update(elementsOn: elementsOn)
        header.set(target: target, action: action)
        header.setState(text: "调整排序", for: [.idle, .pulling])
        header.setState(text: "释放进入", for: [.willRefreshing, .refreshing])
        header.setState(textFont: .systemFont(ofSize: 14), for: .all)
        header.setState(textColor: .lightGray, for: .all)
        header.setTime(text: "\(Date())", for: .all)
        header.setIndicator(size: .init(width: 52, height: 52), for: .all)

        // 设置普通状态的动画图片
        header.setIndicator(images: TestingRefreshSources.catImages, for: [.idle, .pulling])

        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        header.setIndicator(images: TestingRefreshSources.angryImages, for: [.willRefreshing, .refreshing])

        return header
    }
    
}

#if canImport(Lottie)
import Lottie

extension TestingRefreshHeader {
    static func lottie(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshHeader.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextLottieHeader {
        
        let header = RefreshTextLottieHeader()
        header.contentAlignment = contentAlignment
        header.direction = direction
        header.directionSize = .init(content: 90)
        header.update(elementsOn: elementsOn)
        header.set(target: target, action: action)
        header.setState(text: "调整排序", for: .beforeRefresing)
        header.setState(text: "释放进入", for: .currentRefresing)
        header.setState(textFont: .systemFont(ofSize: 14), for: .all)
        header.setState(textColor: .lightGray, for: .all)
        header.setTime(text: "\(Date())", for: .all)
        header.set(animation: .init(source: "Rocket", size: .init(width: 90, height: 90)))
        return header
    }
}
#endif


// MARK: Footer

struct TestingRefreshFooter {
    
    static func text(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshFooter.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextTextFooter {

        let footer = RefreshTextTextFooter()
        footer.contentAlignment = contentAlignment
        footer.direction = direction
        footer.directionSize = .init(content: 90)
        footer.update(elementsOn: elementsOn)
        footer.set(target: target, action: action)
        footer.setState(text: "调整排序", for: [.idle, .pulling])
        footer.setState(text: "释放进入", for: .willRefreshing)
        footer.setState(text: "进入中...", for: .refreshing)
        footer.setState(textFont: .systemFont(ofSize: 14), for: .all)
        footer.setState(textColor: .lightGray, for: .all)
        footer.setTime(text: "\(Date())", for: .all)
        footer.setTitle(text: "Text", for: .all)
        footer.setTitle(textFont: .systemFont(ofSize: 18), for: .all)
        footer.setTitle(textColor: .red, for: [.idle, .pulling])
        footer.setTitle(textColor: .green, for: .willRefreshing)
        footer.setTitle(textColor: .yellow, for: .refreshing)
        return footer
    }
    
    static func arrow(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshFooter.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextArrowFooter {

        let footer = RefreshTextArrowFooter()
        footer.contentAlignment = contentAlignment
        footer.direction = direction
        footer.update(elementsOn: elementsOn)
        footer.set(target: target, action: action)
        footer.setState(text: "调整排序", for: [.idle, .pulling])
        footer.setState(text: "释放进入", for: [.willRefreshing, .refreshing])
        footer.setState(textFont: .systemFont(ofSize: 14), for: .all)
        footer.setState(textColor: .lightGray, for: .all)
        footer.setTime(text: "\(Date())", for: .all)
        footer.setIndicator(color: .lightGray, for: .all)
        footer.setIndicator(size: .init(width: 18, height: 14), for: .all)
        return footer
    }
    
    static func images(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshFooter.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextImagesFooter {

        let footer = RefreshTextImagesFooter()
        footer.contentAlignment = contentAlignment
        footer.direction = direction
        footer.directionSize = .init(content: 90)
        footer.update(elementsOn: elementsOn)
        footer.set(target: target, action: action)
        footer.setState(text: "调整排序", for: [.idle, .pulling])
        footer.setState(text: "释放进入", for: [.willRefreshing, .refreshing])
        footer.setState(textFont: .systemFont(ofSize: 14), for: .all)
        footer.setState(textColor: .lightGray, for: .all)
        footer.setTime(text: "\(Date())", for: .all)
        footer.setIndicator(size: .init(width: 52, height: 52), for: .all)

        // 设置普通状态的动画图片
        footer.setIndicator(images: TestingRefreshSources.catImages, for: [.idle, .pulling])

        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        footer.setIndicator(images: TestingRefreshSources.angryImages, for: [.willRefreshing, .refreshing])

        return footer
    }
    
}

#if canImport(Lottie)
import Lottie

extension TestingRefreshFooter {
    static func lottie(
        elementsOn: Refresh.ElementsOn = .all,
        contentAlignment: Refresh.ContentAlignment = .leading,
        direction: RefreshFooter.Direction,
        target: AnyObject,
        action: Selector
    ) -> RefreshTextLottieFooter {

        let footer = RefreshTextLottieFooter()
        footer.contentAlignment = contentAlignment
        footer.direction = direction
        footer.directionSize = .init(content: 90)
        footer.update(elementsOn: elementsOn)
        footer.set(target: target, action: action)
        footer.setState(text: "调整排序", for: .beforeRefresing)
        footer.setState(text: "释放进入", for: .currentRefresing)
        footer.setState(textFont: .systemFont(ofSize: 14), for: .all)
        footer.setState(textColor: .lightGray, for: .all)
        footer.setTime(text: "\(Date())", for: .all)
        footer.set(animation: .init(source: "Rocket", size: .init(width: 90, height: 90)))
        return footer
    }
}
#endif


extension UICollectionView.ScrollDirection {
    public var header: RefreshHeader.Direction {
        switch self {
        case .vertical:   return .top
        case .horizontal: return .leading
        @unknown default: return .top
        }
    }
    
    public var footer: RefreshFooter.Direction {
        switch self {
        case .vertical:   return .bottom
        case .horizontal: return .trailing
        @unknown default: return .bottom
        }
    }
}
