//
//  AddEditCrewView.swift
//  SimpleLogMobile
//
//  Created by Ricardo Brito Riet Correa on 1/17/25.
//

import SwiftUI

struct AddEditCrewView: View {
    
    // Environment property to dismiss the current view
    @Environment(\.dismiss) var dismiss
    
    var crewVM: CrewViewModel
    
    // Crew from the database or nil
    @Binding var crewToEdit: Crew?
    
    // Displayed crew model
    @State private var crew = CrewModel()
    
    @State private var isNameInvalid: Bool = false
    
    @State private var showImagePickerOptions = false
    @State private var showImagePicker = false
    @State private var isCamera = false
    @StateObject var alertManager = AlertManager()
    
    init(_ crew: Binding<Crew?>, crewVM: CrewViewModel) {
        self._crewToEdit = crew
        self.crewVM = crewVM
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        if let imageData = crew.picture, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .onTapGesture {
                                    showImagePickerOptions.toggle()
                                }
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                Text(crewToEdit?.initials ?? "")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {
                                showImagePickerOptions.toggle()
                            }
                        }
                        Text("Tap to add/edit photo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                InputField(
                    "Name",
                    textValue: $crew.name,
                    isInvalid: $isNameInvalid,
                    isRequired: true,
                    capitalization: .words,
                    customValidation: { input in
                        checkExists(name: input)
                    }
                )
                
                InputField(
                    "Phone",
                    textValue: $crew.phone,
                    inputType: .phone,
                    capitalization: .never
                )
                
                InputField(
                    "Email",
                    textValue: $crew.email,
                    inputType: .email,
                    capitalization: .never
                )
                
                InputField(
                    "Notes",
                    textValue: $crew.notes,
                    lines: 5,
                    capitalization: .sentences
                )
                
                Toggle(isOn: $crew.isFavorite) {
                    Text("Favorite")
                        .font(.title2)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCrew()
                    }
                    .disabled(
                        isNameInvalid
                    )
                }
            }
            .navigationTitle(crewToEdit == nil ? "Add Crew" : "Edit Crew")
            .navigationBarTitleDisplayMode(.inline)
            
            .alert(item: $alertManager.currentAlert) { alertInfo in
                alertManager.getAlert(alertInfo)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: isCamera ? .camera : .photoLibrary) { image in
                    if let image = image {
                        self.crew.picture = image.jpegData(compressionQuality: 0.8)
                    }
                }
            }
            .actionSheet(isPresented: $showImagePickerOptions, content: getActionSheet)
            .onAppear {
                initializeFields()
            }
        }
    }
    
    
    private func initializeFields() {
        guard let receivedCrew = crewToEdit else { return }
        crew.update(from: receivedCrew)
    }
    
    private func getActionSheet() -> ActionSheet {
        let buttonCamera: ActionSheet.Button = .default(
            Text("Camera"),
            action: {
                isCamera = true
                showImagePicker = true
            }
        )
        let buttonLibrary: ActionSheet.Button = .default(
            Text("Photo Library"),
            action: {
                isCamera = false
                showImagePicker = true
            }
        )
        let buttonRemove: ActionSheet.Button = .destructive(
            Text("Remove Photo"),
            action: {
                self.crew.picture = nil
            }
        )
        let buttonCancel: ActionSheet.Button = .cancel()
        
        return ActionSheet(
            title: Text("Select Image"),
            buttons: [buttonCamera, buttonLibrary, buttonRemove, buttonCancel]
        )
    }
    
    
    private func saveCrew() {
        do {
            if crewToEdit == nil {
                // Adding a new Crew
                try crewVM.addCrew(crew)
            } else {
                try crewVM.editCrew( crewToEdit!, newCrew: crew)
            }
            try crewVM.fetchCrewList()
        } catch let details as ErrorDetails {
            // Handle specific error details
            alertManager.showAlert(.error(details: details))
            return
        } catch {
            // Handle unexpected errors
            alertManager.showAlert(.simple(
                title: "Unexpected Error",
                message: error.localizedDescription
            ))
            return
        }
        
        // Dismiss the view after a successful save
        dismiss()
    }
    
    private func checkExists(name: String) -> InputField.ErrorType? {
        
        // if Type is not nil, User is editing an existing Aircraft.
        // Skip duplicate check only if the Registration is the same as the original Registration.
        if let crw = crewToEdit, crw.name.strUnwrap.uppercased() == name.uppercased() {
            return nil
        }
        
        do {
            if try crewVM.checkExist(name) {
                // Return the error type if duplicate found
                return .invalidFormat("This Crew Name already exists.")
            } else {
                return nil
            }
        } catch {
            return .invalidFormat("There was an unknown error reading from database.")
        }
    }
}
