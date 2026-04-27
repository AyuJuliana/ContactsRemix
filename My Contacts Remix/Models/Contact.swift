//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 21/04/26.
//
import SwiftUI

struct Contact: Identifiable, Hashable { //This struct is the core data model representing a single contact in your app. Identifiable is required for Lists and dynamic UI rendering. Hadhable is enables efficient comparison and UI updates. All screens (list, detail, edit) rely on this model.
    var id = UUID() //Each contact has a unique identifier using UUID, so this variable can helps SwiftUI distinguish each item and prevents UI rendering issues
    var firstName: String
    var lastName: String
    var imageName: String //default asset image using data that has been uploaded in assets
    var photoData: Data? = nil //user-uploaded photo when saving the new data, to support fallback when no custom image exists.
    var relationship: Relationship //this is core feature of our app, that categorizes contacts based on social context and 
    var memoryCue: String //Helps users remember context about a contact.
    var phoneNumber: String
    var isMe: Bool //identifies user profile
    
    var fullName: String {
        "\(firstName) \(lastName)" //Dynamically combines first and last name.
    }
    
    var sectionTitle: String {
        String(firstName.prefix(1)) //Used for alphabetical grouping using firstname. Grouping list (A,B,C, etc)
    }
}

enum Relationship: Equatable, CaseIterable { //Enum for defines contact categories in a type-safe way (avoid typo, etc) and for fixed category. Equatable is a Swift protocol that allows a data type to be compared with another instance of the same type to determine if they are equal. This is especially useful for filtering contacts, applying conditional UI logic, or handling user interactions based on the relationship type (we can use == to compare values directly) and we can use for filtering data, conditional UI, and logic decisions. CaseIterable allows an enum to provide a collection of all its cases, we use it for iteration to make looping and improves code efficiency, scalability, and maintainability.
    case social
    case friend // This ensures that a contact can only have one of these predefined categories, preventing invalid or inconsistent values.
    case work //bcs if we use string that can be typo in our data
    case family
    case closeFriend
    case service
    
    var label: String { //for filter
        switch self { //switch self statement is used to check the current enum value and return a corresponding result. Swift enforces exhaustive switching, meaning all enum cases must be handled. If you miss one, the compiler will throw an error.
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
        case .social: return .purple //The return keyword is used because label, color, and shortLabel are computed properties. They do not store values but instead generate values dynamically when accessed.
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
    
} // So by defining UI-related properties inside the enum: UI becomes consistent, logic is centralized, and code is cleaner and easier to scale

struct DraftContact{ //Temporary storage for form input to prevents incomplete data issues (user can saving data when they have this minimum data (firstname, phone number, and the relationship is friend by default)
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var memoryCue: String = ""
    var relationship: Relationship = .friend //for avoid the null value or invalid data
}


