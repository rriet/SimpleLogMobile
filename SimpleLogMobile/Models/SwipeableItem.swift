//
//  SwipeableItem.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/10/25.
//

import Foundation

protocol SwipeableItem {
    var isLocked: Bool { get set }
    var allowDelete: Bool { get }
}
