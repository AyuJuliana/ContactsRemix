//
//  ContentView.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 20/04/26.
//

import SwiftUI

struct ContactCardView: View {
    var contact: Contact
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                if let data = contact.photoData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 180)
                        .clipped()
                } else {
                    Image(contact.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 180)
                        .clipped()
                }

                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                    startPoint: .center,
                    endPoint: .bottom
                )

                HStack {
                    Text(contact.firstName)
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Text(contact.relationship.shortLabel)
                        .font(.caption2)
                        .padding(6)
                        .background(contact.relationship.color)
                        .clipShape(Circle())
                }
                .padding(10)
            }
            .frame(width: geo.size.width, height: 180)
            .cornerRadius(20)
            .clipped()
        }
        .frame(height: 180)
        .overlay(alignment: .top) {
            MemoryBubble(text: contact.memoryCue)
        }
    }
}

//normal buble (without triangle, so only shape)
//struct MemoryBubble: View {
//    var text: String
//
//    var body: some View {
//        Text(text)
//            .font(.caption)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(Color(.systemGray6))
//            .clipShape(Capsule())
//            .shadow(radius: 3)
//            .offset(y: -12)
//    }
//}

struct MemoryBubble: View {
    var text: String
    var body: some View {
        VStack(spacing: 0) {
            //Bubble
            Text(text)
                .font(.caption)
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .shadow(radius: 3)
            
            //(triangle)
            Triangle()
                .fill(Color(.systemGray6))
                .frame(width: 16, height: 8)
                .shadow(radius: 1)
        }
        .offset(y: -12)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}


struct ContentView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    //pakai @State, bukan contacts global
    @State private var contactList: [Contact] = [ayuk, fharles, falen, nana, falus, aya, bunana]
        .sorted { $0.firstName < $1.firstName }
    
    @State private var selectedRelationship: Relationship? = nil
    @State private var searchText: String = ""
    @State private var showAddContact = false
    
    // pakai contactList
    var meContact: Contact? {
        contactList.first { $0.isMe }
    }
    
    var otherContacts: [Contact] {
        contactList.filter { !$0.isMe }
    }
    
    var filteredContacts: [Contact] {
        guard let selected = selectedRelationship else { return otherContacts }
        return otherContacts.filter { $0.relationship == selected }
    }
    
    var searchedContacts: [Contact] {
        guard !searchText.isEmpty else { return filteredContacts }
        return filteredContacts.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: searchedContacts) { $0.sectionTitle }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    if let meIndex = contactList.firstIndex(where: { $0.isMe }) {
                        MyCardView(me: $contactList[meIndex])
                            .padding(.horizontal)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                selectedRelationship = nil
                            } label: {
                                Text("All")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(selectedRelationship == nil ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedRelationship == nil
                                        ? Color.primary
                                        : Color.primary.opacity(0.1)
                                    )
                                    .clipShape(Capsule())
                            }
                            
                            ForEach(Relationship.allCases, id: \.label) { rel in
                                RelationshipFilterChip(
                                    relationship: rel,
                                    isSelected: selectedRelationship == rel
                                ) {
                                    selectedRelationship = selectedRelationship == rel ? nil : rel
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                        Text(key)
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(groupedContacts[key]!) { contact in
                                if let index = contactList.firstIndex(where: { $0.id == contact.id }) {
                                    NavigationLink(destination: DetailContactView(
                                        contact: $contactList[index],
                                        onDelete: {
                                            contactList.remove(at: index)
                                        }
                                    )) {
                                        ContactCardView(contact: contact)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search by name")
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showAddContact = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // pass $contactList ke AddContactView
            .sheet(isPresented: $showAddContact) {
                AddContactView(contacts: $contactList)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedRelationship)
        }
    }
}


struct MyCardView: View {
    @Binding var me: Contact

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(destination: MyProfileDetailView(me: $me)) {
                HStack(spacing: 10) {
                    if let data = me.photoData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                    } else {
                        Image(me.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(me.fullName)
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                        Text(me.memoryCue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 0)
            }
            .buttonStyle(.plain)
            Spacer() //make a space after the mycard profile

            VStack(alignment: .leading, spacing: 2) {
                Text("People")
                    .font(.title3.bold())
                Text("Sorted by relationship")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }

        .padding(.horizontal, 0)
    }
}
struct RelationshipFilterChip: View {
    var relationship: Relationship
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Circle()
                    .fill(relationship.color)
                    .frame(width: 8, height: 8)
                
                Text(relationship.label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected
                ? relationship.color
                : relationship.color.opacity(0.12)
            )
            .clipShape(Capsule())
        }
    }
}

#Preview {
    ContentView()
}
