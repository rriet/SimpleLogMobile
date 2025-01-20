//
//  zoomPictureView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//

import SwiftUI

struct ZoomPictureView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var crew: Crew?
    
    var body: some View {
        NavigationView {
            if let selectedCrew = crew {
                if let imageData = selectedCrew.picture, let uiImage = UIImage(
                    data: imageData
                ) {
                    VStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding()
                        Spacer()
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                dismiss()
                            }
                        }
                    }
                    .navigationTitle(crew?.name ?? "")
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    Text("No image available")
                        .font(.headline)
                        .padding()
                }
            }
            
        }
        
    }
}
