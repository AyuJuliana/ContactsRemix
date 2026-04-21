//
//  ContentView.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 20/04/26.
//

import SwiftUI

struct Contact: Identifiable, Hashable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var imageName: String
    var relationship: Relationship
    var memoryCue: String
    var phoneNumber: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var sectionTitle: String {
        String(firstName.prefix(1))
    }
}

enum Relationship {
    case social
    case friend
    case work
    case family
    case closeFriend
    case service
    
    var color: Color {
        switch self {
        case .social: return .purple
        case .friend: return .orange
        case .work: return .cyan
        case .family: return .pink
        case .closeFriend: return .green
        case .service: return .yellow
        }
    }
    
    var shortLabel: String {
        switch self {
        case .social: return "Sc"
        case .friend: return "Fr"
        case .work: return "Wo"
        case .family: return "Fm"
        case .closeFriend: return "CF"
        case .service: return "Sr"
        }
    }
}

// data
var ayuk = Contact(firstName: "Ayu", lastName: "Juliana", imageName: "ayuk", relationship: .family, memoryCue: "my sister", phoneNumber: "+6281199912")

var charles = Contact(firstName: "Charles", lastName: "Leclerc", imageName: "ayuk", relationship: .friend, memoryCue: "my friend", phoneNumber: "+6281199912")

var nana = Contact(firstName: "Nana", lastName: "Leclerc", imageName: "ayuk", relationship: .social, memoryCue: "meet at paddle event", phoneNumber: "+6281199912")

var ana = Contact(firstName: "Ana", lastName: "Ani", imageName: "ayuk", relationship: .work, memoryCue: "Speak Korean", phoneNumber: "+6281199912")
var aya = Contact(firstName: "Ayana", lastName: "Ani", imageName: "ayuk", relationship: .closeFriend, memoryCue: "bestise SHS", phoneNumber: "+6281199912")
var bunana = Contact(firstName: "Bunana", lastName: "Warung", imageName: "ayuk", relationship: .service, memoryCue: "warung bunana jimbaran", phoneNumber: "+6281199912")

var contacts = [ayuk, charles, nana, ana, aya, bunana]
    .sorted { $0.firstName < $1.firstName }


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
    
    var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: contacts) { $0.sectionTitle }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    MyCardView()
                        .padding(.horizontal)
                    ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                        
                        // header
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
            .searchable(text: .constant(""))
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        print("test")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
    
    
    struct MyCardView: View {
        var body: some View {
            HStack(spacing: 16) {
                
                // photo
                Image("ayuk")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                
                // text name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ayuk")
                        .font(.title3.bold())
                    
                    Text("My Card")
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
    
    #Preview {
        ContentView()
    }
