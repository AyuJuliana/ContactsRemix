//
//  ContentView.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 20/04/26.
//

import SwiftUI

//struct Contact: Identifiable, Hashable {
//    var id = UUID()
//    var firstName: String
//    var lastName: String
//    var imageName: String
//    var relationship: Relationship
//    var memoryCue: String
//    var phoneNumber: String
//    var isMe: Bool
//    
//    var fullName: String {
//        "\(firstName) \(lastName)"
//    }
//
//    var sectionTitle: String {
//        String(firstName.prefix(1))
//    }
//}
//
//enum Relationship: Equatable  {
//    case social
//    case friend
//    case work
//    case family
//    case closeFriend
//    case service
//    
//    var label: String { //for filter
//        switch self {
//        case .social:      return "Social"
//        case .friend:      return "Friend"
//        case .work:        return "Work"
//        case .family:      return "Family"
//        case .closeFriend: return "Close Friend"
//        case .service:     return "Service"
//        }
//    }
//    
//    var color: Color {
//        switch self {
//        case .social: return .purple
//        case .friend: return .orange
//        case .work: return .cyan
//        case .family: return .pink
//        case .closeFriend: return .green
//        case .service: return .yellow
//        }
//    }
//    
//    var shortLabel: String {
//        switch self {
//        case .social: return "Sc"
//        case .friend: return "Fr"
//        case .work: return "Wo"
//        case .family: return "Fm"
//        case .closeFriend: return "CF"
//        case .service: return "Sr"
//        }
//    }
//    
//    static let allCases: [Relationship] = [
//        .closeFriend, .family, .friend, .work, .social, .service
//    ]
//}


// data
//var ayuk = Contact(firstName: "Ayu", lastName: "Juliana", imageName: "ayuk", relationship: .family, memoryCue: "my profile", phoneNumber: "+6281199912", isMe: true)
//
//var fharles = Contact(firstName: "Fharles", lastName: "Leclerc", imageName: "ayuk", relationship: .friend, memoryCue: "my friend", phoneNumber: "+6281199912", isMe: false)
//
//var nana = Contact(firstName: "Nana", lastName: "Leclerc", imageName: "ayuk", relationship: .social, memoryCue: "meet at paddle event", phoneNumber: "+6281199912", isMe: false)
//
//var falen = Contact(firstName: "Falen", lastName: "Cia", imageName: "ayuk", relationship: .work, memoryCue: "people ADA 2026", phoneNumber: "+6281199912", isMe: false)
//
//var falus = Contact(firstName: "Falus", lastName: "Cia", imageName: "ayuk", relationship: .family, memoryCue: "my sister", phoneNumber: "+6281199912", isMe: false)
//
//var aya = Contact(firstName: "Ayana", lastName: "Ani", imageName: "ayuk", relationship: .closeFriend, memoryCue: "bestise SHS", phoneNumber: "+6281199912", isMe: false)
//
//var bunana = Contact(firstName: "Bunana", lastName: "Warung", imageName: "ayuk", relationship: .service, memoryCue: "warung bunana jimbaran", phoneNumber: "+6281199912", isMe: false)
//
//var contacts = [ayuk, fharles, falen, nana, falus, aya, bunana]
//    .sorted { $0.firstName < $1.firstName }


struct ContactCardView: View {
    var contact: Contact
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // photo
            Image(contact.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(20)
            
            // overlay text
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(18)
            
            // name + badge (relationship)
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
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    //State filter. nil = tampilkan semua
    @State private var selectedRelationship: Relationship? = nil
    //State searching
    @State private var searchText: String = ""

    var meContact: Contact? {
        contacts.first { $0.isMe }
    }

    var otherContacts: [Contact] {
        contacts.filter { !$0.isMe }
    }

    // Contact yang sudah difilter (atau semua kalau nil)
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
    
    // Pakai filteredContacts, bukan otherContacts langsung
    var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: searchedContacts) { $0.sectionTitle }
    }

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    if let me = meContact {
                        MyCardView(me: me)
                            .padding(.horizontal)
                    }

                    // chip filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {

                            // Chip "All" untuk reset filter
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
                                    // Tap chip yang sama for back to all
                                    selectedRelationship = selectedRelationship == rel ? nil : rel
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Grid image
                    ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                        Text(key)
                            .font(.title2.bold())
                            .padding(.horizontal)

                        Divider()
                            .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(groupedContacts[key]!) { contact in
                                ContactCardView(contact: contact)
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
                    Button { print("test") } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedRelationship)
        }
    }
}
    

struct MyCardView: View {
    var me: Contact  // parameter contact to know this is me or no

    var body: some View {
        HStack(spacing: 16) {
            Image(me.imageName)         // pakai data dari contact
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(me.fullName)       // nama dari data
                    .font(.title3.bold())

                Text(me.memoryCue)     // memoryCue sebagai subtitle
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .cornerRadius(16)

        VStack(alignment: .leading) {
            Text("People")
                .font(.title3.bold())

            Text("Sorted by relationship")
                .font(.subheadline)
        }
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
