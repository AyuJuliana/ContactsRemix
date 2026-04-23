//
//  MyProfileDetailView.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 22/04/26.
//

// MyProfileDetailView.swift
import SwiftUI

struct MyProfileDetailView: View {
    @Binding var me: Contact
    @State private var showEdit = false
    
    var contactImage: Image {
        if let data = me.photoData,
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if !me.imageName.isEmpty {
            return Image(me.imageName)
        }
        return Image(systemName: "person.fill")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    contactImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
                }
                .padding(.top, 20)
                
                VStack(spacing: 4) {
                    Text(me.fullName).font(.title2.bold())
                    Text(me.memoryCue).font(.subheadline).foregroundStyle(.secondary)
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    InfoRow(icon: "phone", iconColor: .green, label: "Phone", value: me.phoneNumber)
                    Divider().padding(.leading, 52)
                    InfoRow(icon: "person.fill", iconColor: .blue, label: "Relationship", value: me.relationship.label)
                    Divider().padding(.leading, 52)
                    InfoRow(icon: "brain", iconColor: .purple, label: "Memory Cue", value: me.memoryCue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditContactView(
                contact: $me,
                onDelete: nil
                )
        }
    }
}

#Preview {
    NavigationStack {
        MyProfileDetailView(me: .constant(ayuk))
    }
}
