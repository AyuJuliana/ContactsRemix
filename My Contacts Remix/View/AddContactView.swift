//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 21/04/26.
//

import SwiftUI
import PhotosUI //PhotosUI is imported to access the iPhone photo library without this, PhotosPicker won't work.
struct AddContactView: View { //This view acts as a data entry interface where users input new contact information.
    @Environment(\.dismiss) var dismiss //function from the iOS system. When called (dismiss()), this sheet closes and returns to the previous screen (ContentView).
    
    //Receives a direct connection to ContentView's contactList array. Not a copy, changes here affect the original array in ContentView.
    @Binding var contacts: [Contact]
    
    //Stores the photo item selected by the user from the gallery. ? means it can be empty (nil), initially no photo is selected. PhotosPickerItem is a data type from the PhotosUI framework.
    @State private var selectedItem: PhotosPickerItem? = nil
    //Stores the photo as a SwiftUI Image, used specifically to display a preview in the form. It's nil until the user selects a photo.
    @State private var profileImage: Image? = nil
    //🇬🇧 Stores the photo as raw bytes (Data) this is what gets saved into the Contact struct. Image can't be stored in a struct, but Data can. Starts as nil until the user picks a photo.
    @State private var photoData: Data? = nil
    //Temporarily stores each form field's content while the user types. Starts as empty string "". Every change in the TextField automatically updates these @State values because they're connected with $. We used private state to protect internal state (encapsulation) so the data should not be accessed or modified from outside
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var memoryCue: String = ""
    // Stores the currently selected relationship. Its type is Relationship (not optional) so it always has a value, it can never be empty. Defaults to .friend so there's always a selection from the start. Typically from a Picker (dropdown-like component).
    @State private var selectedRelationship: Relationship = .friend
    
    var body: some View {
        NavigationStack { //NavigationStack is needed so the toolbar (xmark and checkmark buttons) can appear at the top. Without this, the toolbar won't show.
            Form { //Form is a built-in SwiftUI component that automatically renders an iOS style list, with gray background, separated rows, and Sections with headers.
                Section { //one group in the form
                    HStack {
                        Spacer() // make the photo and add photo in center of the content
                        VStack(spacing: 10) {
                            if let profileImage { //checks if a photo has been selected
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            } else {
                                Circle() //If no photo yet, show a placeholder, a gray circle with a person icon in the center.
                                    .fill(Color(.systemGray5))
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                            .foregroundStyle(Color(.systemGray3))
                                    )
                            }
                            
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) { //Apple's official component to open the photo gallery. Selection is where the user's chosen photo is stored selection: $selectedItem = connected to state, when user picks a photo, selectedItem is automatically filled. matching: .images = only show photos, not videos. photosLibrary: .shared to access main library
                                Text("Add Photo")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.black)
                                    .padding(8)
                            }
                            .buttonStyle(.bordered)
                            .onChange(of: selectedItem) { _, newItem in //Called automatically every time selectedItem changes (user picks a new photo).
                                Task { //Task = runs code asynchronously so the UI doesn't freeze. Photo taking process and time (isn't instant)
                                    if let data = try? await newItem?.loadTransferable(type: Data.self), //loadTransferable = loads the photo as Data (raw bytes) from the gallery asynchronously. try? = if it fails, result is nil, no crash. Data.self = the format we take
                                       
                                        //Change Data → image that can be displayed, we can use UIImage
                                       let uiImage = UIImage(data: data) {
                                        photoData = data
                                        //if successful, save to photoData (for Contact)
                                        profileImage = Image(uiImage: uiImage)
                                        //If successful, save to photoData (for Contact) and profileImage (for preview).
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                //Removes the default gray background from this Section so the photo appears floating, not boxed inside a gray container.
                
                Section {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    //Phone number field. .keyboardType(.phonePad) = automatically shows a numeric keyboard when this field is tapped, making it easier to enter phone numbers.
                }
                
                Section {
                    Picker(selection: $selectedRelationship) { //Picker = dropdown to select a relationship. selection: $selectedRelationship = connected to state.
                        
                        //loops through all 6 relationship options. Each option shows a colored dot + label text after choose the relationship, dot will show.
                        ForEach(Relationship.allCases, id: \.self) { rel in
                            HStack {
                                Circle()
                                    .fill(rel.color)
                                    .frame(width: 10, height: 10)
                                Text(rel.label)
                            }
                            .tag(rel) //unique identifier for each option so the Picker knows which one is selected.
                        }
                    }
                    label: { //the row display in the form gray "Relationship" text + active selection's colored dot on the right.
                        HStack(spacing: 6) {
                            Text("Relationship")
                                .foregroundStyle(Color.gray)
                                .opacity(0.5)
                            Spacer()
                            Circle()
                                .fill(selectedRelationship.color)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                
                Section {
                    TextField("Memory Cue", text: $memoryCue)
                    
                    // Memory cue field with a 10-word limit. Every time the user types, .onChange is triggered.
                        .onChange(of: memoryCue) { _, newValue in
                            //splits the text into an array of words by spaces. If word count exceeds 10, trim with .prefix(10) then rejoin with .joined(separator: " ")
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
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //X button at the top left. placement: .cancellationAction = iOS automatically places it in the cancel position (left). When tapped, dismiss() closes the sheet without saving anything and back to content view.
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                //Checkmark button at the top right. placement: .confirmationAction = iOS places it in the confirm position (right). When tapped, runs saveContact() first then dismiss()back to content view then .disabled(firstName.isEmpty) = button can't be tapped if firstName and phoneNumber is empty.
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveContact()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .tint(.gray)
                    .disabled(firstName.isEmpty)
                    .disabled(phoneNumber.isEmpty)
                }
            }
        }
    }
    
    // Function that runs when the user taps the checkmark. Creates a new Contact from all the @State values the user filled in.
    func saveContact() {
        let newContact = Contact(
            firstName: firstName,
            lastName: lastName,
            imageName: "", //empty because the photo comes from the gallery (stored in photoData, not as an asset).
            photoData: photoData, //stored in photoData, not as an asset.
            relationship: selectedRelationship,
            memoryCue: memoryCue,
            phoneNumber: phoneNumber,
            isMe: false, //isMe: false = the new contact is not the user's own profile.
        )
        contacts.append(newContact)  //adds to the binding array — because of @Binding, the change immediately propagates to contactList in ContentView and the grid automatically updates
    }
}

#Preview {
    AddContactView(contacts: .constant([])) //a dummy binding with an empty array so the preview doesn't crash since @Binding requires a value.
}
