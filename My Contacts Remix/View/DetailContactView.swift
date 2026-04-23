//
//  DetailContact.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 22/04/26.
//

import SwiftUI

struct DetailContactView: View {
    @Binding var contact: Contact
    @State private var showEdit = false
    var onDelete: () -> Void

    var contactImage: Image {
        if let data = contact.photoData,
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if !contact.imageName.isEmpty {
            return Image(contact.imageName)
        }
        return Image(systemName: "person.fill")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // foto pakai GeometryReader supaya fix
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        contactImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 320)
                            .clipped()

                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(width: geo.size.width, height: 320)

                        VStack(spacing: 4) {
                            Text(contact.fullName)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(contact.relationship.color)
                                    .frame(width: 8, height: 8)
                                Text(contact.relationship.label)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 320)  // ← wajib ada

                // tombol call & message — tetap sama
                HStack(spacing: 16) {
                    Button {
                        if let url = URL(string: "tel:\(contact.phoneNumber)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.fill").font(.title2)
                            Text("Call").font(.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                    }
                    .foregroundStyle(.green)

                    Button {
                        if let url = URL(string: "sms:\(contact.phoneNumber)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "message.fill").font(.title2)
                            Text("Message").font(.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                    }
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // info rows — tetap sama
                VStack(spacing: 12) {
                    InfoRow(icon: "phone", iconColor: .green, label: "Phone", value: contact.phoneNumber)
                    Divider().padding(.leading, 52)
                    InfoRow(icon: "person.2", iconColor: contact.relationship.color, label: "Relationship", value: contact.relationship.label)
                    Divider().padding(.leading, 52)
                    InfoRow(icon: "brain", iconColor: .purple, label: "Memory Cue", value: contact.memoryCue)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer(minLength: 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEdit = true
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditContactView(
                contact: $contact,
                onDelete: {
                    onDelete()
                    showEdit = false
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        DetailContactView(
            contact: .constant(fharles),
            onDelete: { }
        )
    }
}


// Komponen row info
struct InfoRow: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 14) {
            // icon circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
    }
}



