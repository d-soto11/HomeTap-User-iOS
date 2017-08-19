//
//  HTCollectionViewCell.swift
//  Hometap
//
//  Created by Daniel Soto on 8/18/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit

class HTCollectionViewCell: UICollectionViewCell {
    public var uiUpdates: ((UICollectionViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        uiUpdates?(self)
    }
}
