//
//  SwipeActionView.swift
//  SimpleLog
//
//  Created by Ricardo Brito Riet Correa on 1/1/25.
//

import SwiftUI

struct SwipeActionsView<T: SwipeableItem>: View {
    var item: T
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onToggleLock: () -> Void
    
    var body: some View {
        if item.isLocked {
            Button( "Unlock", systemImage: "lock") {
                onToggleLock()
            }
            .tint(.blue)
        } else {
            Button("Delete", systemImage: item.allowDelete ?  "trash" : "trash.slash") {
                onDelete()
            }
            .tint(item.allowDelete ? .red : .gray)
            
            Button("Edit", systemImage: item.isLocked ? "pencil.slash" : "pencil") {
                onEdit()
            }
            .tint(.green)
            
            Button( "Lock", systemImage: "lock.open") {
                onToggleLock()
            }
            .tint(.blue)
        }
    }
}
