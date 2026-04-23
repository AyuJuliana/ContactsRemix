//
//  AddProfileScreen.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 21/04/26.
//

import SwiftUI
import PhotosUI

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss

    // ← TAMBAH: binding ke contactList milik ContentView
    @Binding var contacts: [Contact]

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var photoData: Data? = nil
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var memoryCue: String = ""
    @State private var selectedRelationship: Relationship = .friend

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            } else {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                            .foregroundStyle(Color(.systemGray3))
                                    )
                            }

                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                Text("Add Photo")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.black)
                                    .padding(8)
                            }
                            .buttonStyle(.bordered)
                            .onChange(of: selectedItem) { _, newItem in
                                Task {
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
                .listRowBackground(Color.clear)

                Section {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }

                Section {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section {
                    Picker(selection: $selectedRelationship) {
                        ForEach(Relationship.allCases, id: \.label) { rel in
                            HStack {
                                Circle()
                                    .fill(rel.color)
                                    .frame(width: 10, height: 10)
                                Text(rel.label)
                            }
                            .tag(rel)
                        }
                    } label: {
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
                }
            }
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()  // ← tutup sheet, kembali ke ContentView
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveContact()  // ← simpan dulu
                        dismiss()      // ← baru tutup sheet
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .tint(.gray)
                    .disabled(firstName.isEmpty)
                    .disabled(phoneNumber.isEmpty)// ← tidak bisa save kalau blm
                }
            }
        }
    }

    func saveContact() {
        let newContact = Contact(
            firstName: firstName,
            lastName: lastName,
            imageName: "",
            photoData: photoData,
            relationship: selectedRelationship,
            memoryCue: memoryCue,
            phoneNumber: phoneNumber,
            isMe: false,
        )
        contacts.append(newContact)  // ContentView langsung update
    }
}

// dummy binding untuk preview
#Preview {
    AddContactView(contacts: .constant([]))
}
