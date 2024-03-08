//
//  BookingsModel.swift
//  The Lists
//
//  Created by James Ngari on 2024-03-08.
//

import Foundation

struct BookingsModel: Codable {
    let passengerName: String
    let startStation: Int64
    let exitStation: Int64
}
