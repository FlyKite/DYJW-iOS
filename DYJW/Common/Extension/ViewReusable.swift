//
//  ViewReusable.swift
//  MineSweeper
//
//  Created by FlyKite on 2019/9/10.
//  Copyright © 2019 Doge Studio. All rights reserved.
//

import UIKit

protocol ViewReusable {
    static var reuseIdentifier: String { get }
}

extension ViewReusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ViewReusable { }

extension UICollectionReusableView: ViewReusable { }

extension UITableViewHeaderFooterView: ViewReusable { }

extension UITableView {
    
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: cellType.reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: cellType.reuseIdentifier, bundle: Bundle.main),
                     forCellReuseIdentifier: cellType.reuseIdentifier)
        } else {
            register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type) -> T? {
        return dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) as? T
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Dequeue cell failed at (row: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
    func register<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        if Bundle.main.path(forResource: viewType.reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: viewType.reuseIdentifier, bundle: Bundle.main),
                     forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
        } else {
            register(viewType, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
        }
    }
    
    func dequeueReusableView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T
    }
    
}

enum UICollectionViewElementKind {
    case sectionHeader
    case sectionFooter
    
    fileprivate var elementKind: String {
        switch self {
        case .sectionHeader: return UICollectionView.elementKindSectionHeader
        case .sectionFooter: return UICollectionView.elementKindSectionFooter
        }
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: cellType.reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: cellType.reuseIdentifier, bundle: Bundle.main),
                     forCellWithReuseIdentifier: cellType.reuseIdentifier)
        } else {
            register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        }
    }
    
    func register<T: UICollectionReusableView>(_ viewType: T.Type, forSupplementaryViewOfKind: String) {
        if Bundle.main.path(forResource: viewType.reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: viewType.reuseIdentifier, bundle: Bundle.main),
                     forSupplementaryViewOfKind: forSupplementaryViewOfKind,
                     withReuseIdentifier: viewType.reuseIdentifier)
        } else {
            register(viewType, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: viewType.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Dequeue cell failed at (item: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type, ofKind: String, for indexPath: IndexPath) -> T {
        if let view = dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath) as? T {
            return view
        } else {
            fatalError("Dequeue view failed at (item: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
    func register<T: UICollectionReusableView>(_ viewType: T.Type, ofKind kind: UICollectionViewElementKind) {
        if Bundle.main.path(forResource: viewType.reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: viewType.reuseIdentifier, bundle: Bundle.main),
                     forSupplementaryViewOfKind: kind.elementKind,
                     withReuseIdentifier: viewType.reuseIdentifier)
        } else {
            register(viewType, forSupplementaryViewOfKind: kind.elementKind, withReuseIdentifier: viewType.reuseIdentifier)
        }
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type,
                                                                       ofKind kind: UICollectionViewElementKind,
                                                                       for indexPath: IndexPath) -> T {
        
        if let view = dequeueReusableSupplementaryView(ofKind: kind.elementKind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath) as? T {
            return view
        } else {
            fatalError("Dequeue supplementary view failed at (item: \(indexPath.item), section: \(indexPath.section))")
        }
    }
    
}
