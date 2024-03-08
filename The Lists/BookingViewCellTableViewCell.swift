//
//  BookingViewCellTableViewCell.swift
//  The Lists
//
//  Created by James Ngari on 2024-03-08.
//

import UIKit

class BookingViewCellTableViewCell: UITableViewCell {

    let heading = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            heading.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(heading)
            
            NSLayoutConstraint.activate([
                heading.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                heading.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                heading.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                heading.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

}
