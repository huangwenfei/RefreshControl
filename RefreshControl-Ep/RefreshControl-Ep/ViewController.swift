//
//  ViewController.swift
//  RefreshControl-Ep
//
//  Created by windy on 2025/8/31.
//

import UIKit
import Yang
import RefreshControl

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: UITableViewDelegate
    enum Section: Int {
        case header, footer
    }
    
    enum SectionRow: Int {
        case text, arrow, images, lottie
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            let section = Section(rawValue: indexPath.section),
            let sectionRow = SectionRow(rawValue: indexPath.row)
        else {
            return
        }
        
        let present: UIViewController
        
        switch section {
        case .header:
            switch sectionRow {
            case .text:   present = HeaderTextTextController()
            case .arrow:  present = HeaderTextArrowController()
            case .images: present = HeaderTextImagesController()
            case .lottie: present = HeaderTextLottieController()
            }
        case .footer:
            switch sectionRow {
            case .text:   present = FooterTextTextController()
            case .arrow:  present = FooterTextArrowController()
            case .images: present = FooterTextImagesController()
            case .lottie: present = FooterTextLottieController()
            }
        }
        
        present.modalPresentationStyle = .fullScreen
        self.present(present, animated: true)
        
    }

}

