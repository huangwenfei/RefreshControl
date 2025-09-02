//
//  TestingController.swift
//  RefreshControl-Ep
//
//  Created by windy on 2025/9/1.
//

import UIKit
import Yang
import RefreshControl

class TestingCell: UICollectionViewCell {
    
    // MARK: Types
    static let id = "cell.id"
    
    // MARK: Render
    func render() {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)
        contentView.backgroundColor = UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}

enum ChildVC: Int {
    case header, footer
}

class TestingController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: Class
    class var childMode: ChildVC { .header }
    
    // MARK: Layout
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        return layout
    }()
    
    lazy var collection: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.register(TestingCell.self, forCellWithReuseIdentifier: TestingCell.id)
        view.backgroundColor = .darkGray
        return view
    }()
    
    var direction: UICollectionView.ScrollDirection {
        layout.scrollDirection
    }
    
    lazy var dismiss: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(dismissAction(sender:)), for: .touchUpInside)
        button.setTitle("D", for: .normal)
        return button
    }()
    
    lazy var tool: UISegmentedControl = {
        let view = UISegmentedControl(items: ["T", "B", "L", "T"])
        view.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.white
            ],
        for: .normal)
        view.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 17, weight: .bold),
                .foregroundColor: UIColor.purple
            ],
        for: .selected)
        view.addTarget(self, action: #selector(toolAction(sender:)), for: .valueChanged)
        view.backgroundColor = .purple.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var elementOn: UIView = {
        let view = UIView()
        func button(tag: Refresh.ElementsOn, title: String) -> UIButton {
            let button = UIButton(type: .custom)
            button.tag = tag.rawValue
            button.addTarget(self, action: #selector(elementOnAction(sender:)), for: .touchUpInside)
            button.setTitle(title, for: .normal)
            button.setTitle(title, for: .selected)
            button.setTitleColor(.orange, for: .normal)
            button.setTitleColor(.red, for: .selected)
            return button
        }
        let content = button(tag: .content, title: "Content")
        let state = button(tag: .state, title: "State")
        let time = button(tag: .time, title: "Time")
        content.yang.addToParent(view)
        state.yang.addToParent(view)
        time.yang.addToParent(view)
        content.yangbatch.make { make in
            make.leading.equalToParent()
            make.vertical.equalToParent()
            make.width.equalToParent().multiplier(by: 0.33)
        }
        state.yangbatch.make { make in
            make.leading.equal(to: content.yangbatch.trailing)
            make.vertical.equalToParent()
            make.trailing.equal(to: time.yangbatch.leading)
        }
        time.yangbatch.make { make in
            make.trailing.equalToParent()
            make.vertical.equalToParent()
            make.width.equalToParent().multiplier(by: 0.33)
        }
        view.backgroundColor = .purple.withAlphaComponent(0.5)
        return view
    }()
    
    var contentAlignment: Refresh.ContentAlignment = .leading
    
    // MARK: Layout
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isHeader = Self.childMode == .header
        
        collection.yang.addToParent(view)
        tool.yang.addToParent(view)
        elementOn.yang.addToParent(view)
        dismiss.yang.addToParent(view)
        
        let toolHeight: CGFloat = 50
        
        collection.yangbatch.make { make in
            make.diretionEdge.equalToParent()
        }
        
        tool.selectedSegmentIndex = 2 // leading
        
        tool.yangbatch.make { make in
            make.leading.equalToParent().offset(16)
            make.trailing.equal(to: dismiss.yangbatch.leading).offset(-8)
            make.height.equal(to: toolHeight)
            make.top.equal(to: dismiss)
        }
        
        dismiss.yangbatch.make { make in
            if isHeader {
                make.bottom.equalToParent(.bottomMargin).offset(-20)
            } else {
                make.top.equalToParent(.topMargin).offset(20)
            }
            make.size.equal(to: toolHeight)
            make.trailing.equalToParent().offset(-16)
        }
        
        dismiss.backgroundColor = .purple
        dismiss.layer.cornerRadius = toolHeight * 0.5
        dismiss.layer.masksToBounds = true
        
        elementOn.yangbatch.make { make in
            make.height.equal(to: toolHeight)
            make.leading.equalToParent().offset(16)
            make.trailing.equalToParent().offset(-16)
            if isHeader {
                make.bottom.equal(to: dismiss.yangbatch.top).offset(-8)
            } else {
                make.top.equal(to: dismiss.yangbatch.bottom).offset(8)
            }
        }
        
    }
    
    // MARK: Change
    func update(diretion: UICollectionView.ScrollDirection) {
        guard layout.scrollDirection != diretion else { return }
        layout.scrollDirection = diretion
        layout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestingCell.id, for: indexPath) as? TestingCell
        else {
            return .init()
        }
        
        cell.render()
        
        return cell
        
    }
    
    // MARK: UICollectionViewDelegate
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        layout.scrollDirection == .vertical
            ? .init(width: view.frame.width, height: 80)
            : .init(width: 80, height: view.frame.height)
    }
    
    // MARK: Action
    @objc func refresh(sender: Refresh) {
        print(collection.rcHeader?.state ?? "None", collection.rcFooter?.state ?? "None")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.collection.rcHeader?.finishedRefreshing()
            self.collection.rcFooter?.finishedRefreshing()
            print(self.collection.rcHeader?.state ?? "None", self.collection.rcFooter?.state ?? "None")
        }
    }
    
    @objc func toolAction(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:  contentAlignment = .top
        case 1:  contentAlignment = .bottom
        case 2:  contentAlignment = .leading
        case 3:  contentAlignment = .trailing
        default: contentAlignment = .leading
        }
        collection.rcHeader?.contentAlignment = contentAlignment
        collection.rcFooter?.contentAlignment = contentAlignment
    }
    
    @objc func elementOnAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let element: Refresh.ElementsOn = sender.superview?.subviews
            .reduce(Refresh.ElementsOn.empty, {
                guard ($1 as? UIButton)?.isSelected == false else { return $0 }
                return $0.union(Refresh.ElementsOn(rawValue: $1.tag))
            }) ?? .all
        print(#function, #line, element.isShowContent, element.isShowState, element.isShowTime)
        collection.rcHeader?.update(elementsOn: element)
        collection.rcFooter?.update(elementsOn: element)
    }
    
    @objc func dismissAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
}
