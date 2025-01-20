//
//  CrewRowView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//

import SwiftUI

struct CrewRowView: View {
    
    var crew: Crew
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onTapGesture: () -> Void
    let onToggleLock: () -> Void
    let onImageTapGesture: () -> Void

    var body: some View {
        HStack{
            if let imageData = crew.picture, let uiImage = UIImage(data: imageData) {
                // Display the image from the database
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
                    .onTapGesture(perform: onImageTapGesture)
            } else {
                // Generate initials if no image is available
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    Text(crew.initials)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 8)
            }
            VStack(alignment: .leading) {
                Text(crew.name.strUnwrap)
                    .lineLimit(1)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                if !crew.phone.strUnwrap.isEmpty {
                    Text("Phone: \(crew.phone.strUnwrap)")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                }
                if !crew.email.strUnwrap.isEmpty {
                    Text("email: \(crew.email.strUnwrap)")
                        .lineLimit(1)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {onTapGesture()}
            
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .clipped()
        .listRowBackground(Color.theme.background)
        .swipeActions(allowsFullSwipe: false) {
            SwipeActionsView<Crew>(
                item: crew,
                onDelete: onDelete,
                onEdit: onEdit,
                onToggleLock: onToggleLock
            )
        }
    }
    
}
