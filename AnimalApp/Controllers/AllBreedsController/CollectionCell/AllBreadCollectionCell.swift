//
//  AllBreadCollectionCell.swift
//  AnimalApp
//
//  Created by apple on 30/06/24.
//

import UIKit

class AllBreadCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var backgroundVw: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupCellAppearance()
        }
    
    private func setupCellAppearance() {
          
        self.backgroundVw.layer.cornerRadius = 8
        self.backgroundVw.layer.masksToBounds = false
        self.backgroundVw.layer.borderWidth = 1.0
        self.backgroundVw.layer.borderColor = UIColor.lightGray.cgColor
        
       }
    
}
