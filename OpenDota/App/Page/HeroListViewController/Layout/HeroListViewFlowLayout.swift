//
//  HeroListViewFlowLayout.swift
//  OpenDota
//
//  Created by Ivan Fernando on 29/04/20.
//

import UIKit

class HeroListViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let numberOfColumn: CGFloat = 2
        self.minimumLineSpacing = 8
        self.minimumInteritemSpacing = 8
        self.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let cellWidth = ((collectionView.bounds.inset(by: collectionView.layoutMargins).size.width-minimumInteritemSpacing)/numberOfColumn).rounded(.down)
        let cellHeight: CGFloat = cellWidth/1.7 + 76
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.sectionInsetReference = .fromSafeArea
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
}
