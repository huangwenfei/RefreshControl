//
//  RefreshLottieContentProvider.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/31.
//

#if canImport(Lottie)

open class RefreshLottieContentProvider: RefreshLottieProvider {
    
    // MARK: Init
    public init() {
        super.init(containerProvider: .content)
    }
    
}

#endif
