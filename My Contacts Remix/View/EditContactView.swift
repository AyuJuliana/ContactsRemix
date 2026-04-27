//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 22/04/26.
//

import SwiftUI
import PhotosUI //hotosUI to access PhotosPicker, Apple's official component to open the iPhone photo gallery.

struct EditContactView: View {
    //Grabs the dismiss function from the iOS system. Called to close this sheet, whether the user taps xmark (cancel), checkmark (save), or after confirming a delete.
    @Environment(\.dismiss) var dismiss
    //A direct connection to the contact being edited in ContentView's contactList. Not a copy, changes saved via saveEdit() directly affect the original data. Like editing the original document, not a photocopy.
    @Binding var contact: Contact
    //An optional closure to delete the contact. The ? means it can be nil, if nil, the Delete button won't appear (used for My Profile). If it has a value, the Delete button shows (used for regular contacts). () -> Void = takes no parameters, returns nothing.
    var onDelete: (() -> Void)?
    //A boolean to control when the delete confirmation alert appears. false = alert not visible (default). Changes to true when the user taps the "Delete Contact" button in the bottom bar.
    @State private var showDeleteAlert = false
    //A flag indicating whether the contact being edited is the user's own profile. Default false = regular contact. If true = My Profile. Used to hide the Relationship and Memory Cue sections when editing My Profile, because own profile doesn't need those fields.
    var isMe: Bool = false //we used for editing my contact
    
    //These are all temporary data during the editing process. Filled from the original contact data when the view appears (via .onAppear)
    //We not directly edit contact ? , so user can cancel, if we edited the binding directly, changes couldn't be undone. This data is only copied to contact when the user taps Save.
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var memoryCue: String = ""
    @State private var selectedRelationship: Relationship = .friend //default value of relationship
    @State private var selectedItem: PhotosPickerItem? = nil //item selected from the gallery.
    @State private var profileImage: Image? = nil //the Image version to display as a preview in the form.
    @State private var photoData: Data? = nil // raw bytes of the photo to be saved to the Contact
    //All three start as nil but are filled by .onAppear from the existing contact data.
    
    var body: some View {
        NavigationStack {
            Form {
                // foto
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            //checks if a photo exists. If yes → show the photo in a 150x150 circle with a 4pt white border.
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            // If no → show a gray circle placeholder with a person icon.
                            } else {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                            .foregroundStyle(Color(.systemGray3))
                                    )
                            } //In Edit view, profileImage is usually already filled from .onAppear if the contact previously had a photo.
                            
                            //Apple's official component to open the photo gallery. Selection is where the user's chosen photo is stored selection: $selectedItem = connected to state, when user picks a photo, selectedItem is automatically filled. matching: .images = only show photos, not videos. photosLibrary: .shared to access main library
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Text("Change Photo")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.black)
                                    .padding()
                            }
                            .buttonStyle(.bordered)
                            
                            //Called automatically every time selectedItem changes.
                            .onChange(of: selectedItem) { _, newItem in
                                Task { //run asynchronously so the UI doesn't freeze.
                                    
                                    //fetches the photo as Data from the gallery asynchronously. try ? if it fails, result is nil, no crash.  If successful, save to photoData (to be saved to Contact later) and update profileImage (for live preview in the form).
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        photoData = data
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear) //removes the default gray background from this Section so the photo appears to float.
                .padding(.vertical, -12) // reduces top and bottom section padding by 20pt — so the photo isn't too far from the section below it.
                
                Section {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                if !isMe{ //if !isMe = this block only shows if isMe is false (regular contact). If isMe = true (My Profile), both sections are hidden, because own profile doesn't need relationship and memory cue fields.
                    Section {
                        //Picker to select relationship with a colored dot for each option. .tag(rel) = unique identifier for each option.
                        Picker(selection: $selectedRelationship) {
                            ForEach(Relationship.allCases, id: \.self) { rel in
                                HStack {
                                    Circle().fill(rel.color).frame(width: 10, height: 10)
                                    Text(rel.label)
                                }
                                .tag(rel)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("Relationship").foregroundStyle(Color.gray)
                                Spacer()
                                Circle().fill(selectedRelationship.color).frame(width: 10, height: 10)
                            }
                        }
                    }
                    
                    Section {
                        //Memory Cue is limited to 10 words using .onChange — split separates into a word array, prefix(10) takes the first 10, joined recombines them.
                        TextField("Memory Cue", text: $memoryCue)
                            .onChange(of: memoryCue) { _, newValue in
                                let words = newValue.split(separator: " ")
                                if words.count > 10 {
                                    memoryCue = words.prefix(10).joined(separator: " ")
                                }
                            }
                    } footer: {
                        Text("A short note to help you remember this person.\nMax 10 words.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
            }
            .navigationTitle("Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss() //When tapped, closes the sheet without saving anything, because we never call saveEdit(). Temporary data (firstName, lastName, etc.) is automatically discarded when the view closes.
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveEdit() //When tapped, runs saveEdit() first to copy data to the contact binding, then dismiss() to close the sheet.
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }

                //if onDelete != nil = the Delete button only appears if onDelete is not nil. If onDelete = nil (My Profile), this button won't be visible at all.
                if onDelete != nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) { //role: .destructive for red destructive button, for warning and the color is red
                            showDeleteAlert = true //When tapped delete, sets showDeleteAlert = true to show confirmation first.
                        } label: {
                            Text("Delete Contact")
                                .foregroundStyle(.red)
                                .padding(6)
                        }
                    }
                }
            }
            //lert appears when showDeleteAlert = true
            .alert("Delete Contact?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {//role: .destructive for red destructive button, for warning and the color is red
                    onDelete?() //If the user taps Delete: onDelete?() is called with ?() because onDelete is optional, if nil it won't crash
                    dismiss() //closes the sheet.
                }
                Button("Cancel", role: .cancel) { }
            } message: { // part shows the contact's name to be deleted so the user is sure.
                Text("\(contact.fullName) will be deleted.")
            }
            
        }
        
        //  Runs once when the view first appears. Copies all data from contact (binding) to temporary state. This is why the fields are immediately filled with existing data when the edit form opens, the user doesn't have to retype everything.
        .onAppear {
            firstName = contact.firstName
            lastName = contact.lastName
            phoneNumber = contact.phoneNumber
            memoryCue = contact.memoryCue
            selectedRelationship = contact.relationship
            photoData = contact.photoData //For the photo: checks photoData first (gallery)
            if let data = contact.photoData,
               let uiImage = UIImage(data: data) {
                profileImage = Image(uiImage: uiImage)
            } else if !contact.imageName.isEmpty { //if none checks imageName (asset). if both are missing profileImage stays nil → placeholder appears.
                profileImage = Image(contact.imageName)
            }
        }
    }
    
    //Copies all values from temporary state to the contact binding. Because contact is @Binding, changes immediately propagate to contactList in ContentView, the grid automatically re-renders with new data.
    func saveEdit() {
        contact.firstName = firstName
        contact.lastName = lastName
        contact.phoneNumber = phoneNumber
        contact.memoryCue = memoryCue
        contact.relationship = selectedRelationship
        if let newData = photoData { //updates the photo only if the user picked a new photo. If the user didn't change the photo, photoData still contains the old photo data → the old photo is preserved.
            contact.photoData = newData
        }
    }
}

#Preview {
    EditContactView(
        contact: .constant(fharles), //a dummy binding that can't be changed
        onDelete: { } //
    )
}


