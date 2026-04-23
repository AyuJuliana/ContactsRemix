//
//  Contact.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 21/04/26.
//
import SwiftUI

struct Contact: Identifiable, Hashable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var imageName: String
    var photoData: Data? = nil
    var relationship: Relationship
    var memoryCue: String
    var phoneNumber: String
    var isMe: Bool
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var sectionTitle: String {
        String(firstName.prefix(1))
    }
}

enum Relationship: Equatable, CaseIterable { //we want to make iteration
    case social
    case friend
    case work
    case family
    case closeFriend
    case service
    
    var label: String { //for filter
        switch self {
        case .social:      return "Social"
        case .friend:      return "Friend"
        case .work:        return "Work"
        case .family:      return "Family"
        case .closeFriend: return "Close Friend"
        case .service:     return "Service"
        }
    }
    
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

struct DraftContact{
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var memoryCue: String = ""
    var relationship: Relationship = .friend
}
