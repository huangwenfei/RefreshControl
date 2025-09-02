//
//  RefreshArrowIndicator.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/17.
//

import UIKit
import Yang

open class RefreshArrowIndicator: UIView {
    
    // MARK: Properties
    open lazy var arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = Bundle.srArrowImage
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()
    
    open lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            view.style = .medium
        } else {
            view.style = .white
        }
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commit()
    }
    
    open func commit() {
        
        arrowImageView.yang.addToParent(self)
        
        indicator.yang.addToParent(self)
        indicator.alpha = 0
        
    }
    
    // MARK: Layout
    open override func updateConstraints() {
        
        arrowImageView.yangbatch.remake { make in
            make.width.equal(to: 24)
            make.height.equal(to: 12)
            make.center.equalToParent()
        }
        
        indicator.yangbatch.remake { make in
            make.width.equal(to: 16)
            make.height.equal(to: 16)
            make.center.equalToParent()
        }
        
        super.updateConstraints()
    }
    
    // MARK: Appearance
    open func set(color: UIColor) {
        arrowImageView.tintColor = color
        indicator.color = color
    }
    
    open func set(size: CGSize) {
        
        arrowImageView.yangbatch.update { make in
            make.width.offset(size.width)
            make.height.offset(size.height)
        }
        
        indicator.yangbatch.update { make in
            make.width.offset(size.width)
            make.height.offset(size.height)
        }
        
        self.setNeedsUpdateConstraints()
    }
    
    // MARK: Animate
    private func animatingArrow(isShow: Bool) {
        
        isShow ? (arrowImageView.alpha = 0) : (arrowImageView.alpha = 1)
        UIView.animate(withDuration: 0.2) {
            isShow ? (self.arrowImageView.alpha = 1) : (self.arrowImageView.alpha = 0)
        }
        
    }
    
    private func animatingIndicator(isShow: Bool) {
        
        isShow ? (indicator.alpha = 0) : (indicator.alpha = 1)
        UIView.animate(withDuration: 0.2) {
            isShow ? (self.indicator.alpha = 1) : (self.indicator.alpha = 0)
        }
        
    }
    
    open func startRefreshing() { }
    
    open func refreshing() {
        
        animatingArrow(isShow: false)
        
        indicator.startAnimating()
        animatingIndicator(isShow: true)
        
    }
    
    open func finishedRefreshing() {
        
        indicator.stopAnimating()
        resetRefreshing()
        
    }
    
    open func resetRefreshing() {
        
        animatingArrow(isShow: true)
        animatingIndicator(isShow: false)
        
    }
    
    // MARK: Refresh
    open func flipping(to flip: Flipping) {
        
        UIView.animate(withDuration: 0.2) {
            switch flip {
            case .top:      self.arrowImageView.transform = .init(rotationAngle: -.pi * 0.5)
            case .bottom:   self.arrowImageView.transform = .init(rotationAngle: .pi * 0.5)
            case .leading:  self.arrowImageView.transform = .init(scaleX: -1, y: 1)
            case .trailing: self.arrowImageView.transform = .identity
            }
        }
        
    }
    
}

extension RefreshArrowIndicator {
    public enum Flipping: Int, Hashable {
        case top, bottom, leading, trailing
    }
}
