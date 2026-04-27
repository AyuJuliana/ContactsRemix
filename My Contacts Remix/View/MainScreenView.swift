//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 20/04/26.
//

import SwiftUI

struct ContactCardView: View {
    var contact: Contact //Card component displayed in the grid. Receives one Contact as the data to display. Doesn't use @Binding because this card only displays data, doesn't modify it.
    var body: some View {
        GeometryReader { geo in //GeometryReader accurately measures the available space. geo.size.width = the actual grid column width. Used so the photo always fills the full column width, without this, gallery photos could overflow or be too small since their original sizes vary.
            ZStack(alignment: .bottomLeading) { // photo at the bottom, gradient above it, name text + badge at the top. All content is anchored to the bottom left corner so the name and badge appear there.
                if let data = contact.photoData, //checks if there's a gallery photo (stored as Data)
                   let uiImage = UIImage(data: data) { // If yes → convert to UIImage then display.
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 180)
                        .clipped()
                } else { // If no → show photo from Assets.xcassets using contact.imageName
                    Image(contact.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 180)
                        .clipped()
                }

                LinearGradient( // Dark gradient layer over the photo — from center transparent to bottom 60% black opacity. So the name text at the bottom left remains readable over any photo color.
                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                    startPoint: .center,
                    endPoint: .bottom
                )

                HStack {
                    Text(contact.firstName)
                        .font(.headline)
                        .foregroundColor(.white) //make the text name is white
                    Spacer()
                    Text(contact.relationship.shortLabel) //retuen letter short text (CF, FM, etc)
                        .font(.caption2)
                        .padding(6)
                        .background(contact.relationship.color) //Badge is circular with color matching the relationship
                        .clipShape(Circle()) // the circle for the badge relationship
                }
                .padding(10)
            }
            .frame(width: geo.size.width, height: 180) //size exactly matches the grid column.
            .cornerRadius(20) //rounded card corner
            .clipped()
        }
        .frame(height: 180) //required because GeometryReader needs an explicit height.
        .overlay(alignment: .top) { //shows MemoryBubble above the card, centered at the top, without affecting the card's size.
            MemoryBubble(text: contact.memoryCue)
        }
    }
}

//Small component that displays the memory cue text above the contact card. Receives one text parameter, the text to show inside the bubble.
struct MemoryBubble: View {
    var text: String
    var body: some View {
        VStack(spacing: 0) {
            //The top part of the bubble, text with a gray capsule/pill background.
            Text(text)
                .font(.caption)
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .shadow(radius: 3)
            
            // Small triangle below the bubble, like a chat bubble tail pointing downward (to the card).
            Triangle()
                .fill(Color(.systemGray6))
                .frame(width: 16, height: 8)
                .shadow(radius: 1)
        }
        .offset(y: -12) // shifts the entire bubble 12pt upward so it appears above the card boundary, not stuck on the card.
    }
}

struct Triangle: Shape { //A custom triangle shape.
    func path(in rect: CGRect) -> Path { //The rectangular area available for this shape
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath() //closes the path with an automatic line from last point back to first. Result is a downward-pointing triangle.
        return path
    }
}


struct ContentView: View {
    let columns = [ //Defines 2 grid columns. GridItem(.flexible()) = column fills available space evenly — if the screen is wider, columns get wider too. Array with 2 elements = 2 columns.
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    //The main data source for the entire app, array of all contacts sorted A-Z by firstName.
    @State private var contactList: [Contact] = [ayuk, fharles, falen, nana, falus, aya, bunana]
        .sorted { $0.firstName < $1.firstName }
    //Stores the active relationship filter. ? = optional, can be nil. nil = no active filter, show all contacts. If filled (e.g. .friend) = only show contacts with that relationship.
    @State private var selectedRelationship: Relationship? = nil
    //Stores the text typed by the user in the search bar. Starts empty "". Every keystroke automatically updates this state → searchedContacts is automatically recalculated → grid automatically updates.
    @State private var searchText: String = ""
    // Controls when the AddContactView sheet appears. false = sheet hidden. true = sheet slides up from the bottom of the screen.
    @State private var showAddContact = false
    
    //Finds the contact with isMe: true from contactList. .first { } = takes the first element meeting the condition.
    var meContact: Contact? { //since it might not be found. Still exists but no longer used directly — replaced by firstIndex in the body.
        contactList.first { $0.isMe } //gives the exact index, allowing you to perform operations to modify data like update, remove, etc
    }
    
    //All contacts except your own profile. .filter { } = takes only elements meeting the condition. !$0.isMe = those whose isMe is false. Used as input for filteredContacts and also to calculate totalContacts.
    var otherContacts: [Contact] {
        contactList.filter { !$0.isMe }
    }
    
    var filteredContacts: [Contact] { //Contacts filtered by the active chip
        guard let selected = selectedRelationship else { return otherContacts } //if no active filter (nil), directly return all otherContacts
        return otherContacts.filter { $0.relationship == selected } //If there's a filter, return only those whose relationship matches the selection.
    }
    
    var searchedContacts: [Contact] { //Contacts filtered by relationship and searched by name
        guard !searchText.isEmpty else { return filteredContacts } //if search is empty, return filteredContacts without name filtering
        return filteredContacts.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) //searches text regardless of uppercase/lowercase and supports local characters, example: "ayu" can match "Ayu" or "AYU".
        }
    }
    
    var groupedContacts: [String: [Contact]] { //Groups searchedContacts by the first letter of the nam
        Dictionary(grouping: searchedContacts) { $0.sectionTitle } //built-in Swift function that creates a dictionary from an array. Computed property in Contact that takes the 1st letter of firstName
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    //Finds the position (index) of the isMe contact in contactList. Finds the index of the first element meeting the condition.
                    if let meIndex = contactList.firstIndex(where: { $0.isMe }) { //direct Binding to the element at that position
                        MyCardView(
                            me: $contactList[meIndex],
                            totalContacts: otherContacts.count //number of contacts excluding own profile, sent to MyCardView for display.
                        )
                        .padding(.horizontal)
                    }
                    ScrollView(.horizontal, showsIndicators: false) { //scrollable left/right so chips aren't cut off if there are too many.  Hides the scroll indicator.
                        HStack(spacing: 8) {
                            Button {
                                selectedRelationship = nil //resets filter to nil (shows all contacts)
                            } label: {
                                Text("All")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(selectedRelationship == nil ? .white : .primary)//Text color and background change based on whether the filter is active
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedRelationship == nil
                                        ? Color.primary
                                        : Color.primary.opacity(0.1)
                                    )
                                    .clipShape(Capsule())
                            }
                            
                            ForEach(Relationship.allCases, id: \.label) { rel in //Loops through all relationships and renders one chip per relationship. uses label as unique identifier
                                RelationshipFilterChip(
                                    relationship: rel,
                                    isSelected: selectedRelationship == rel
                                ) {
                                    selectedRelationship = selectedRelationship == rel ? nil : rel
                                    //if the tapped chip matches the active one → reset to nil (toggle off), if different → set as new filter.
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    Text("\(otherContacts.count) total contacts") // number of all contacts except own profile.
                        .font(.subheadline.weight(.thin))
                        .padding(.horizontal)
                    
                    //Loops through all section letters (A, B, C...) sorted A-Z. .keys = gets all letters from the dictionary.
                    ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                        Text(key) // large letter section header
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) { // 2-column grid that only renders cards visible on screen
                            ForEach(groupedContacts[key]!) { contact in //gets the contact array for this letter section
                                if let index = contactList.firstIndex(where: { $0.id == contact.id }) { // finds the contact's position in the original contactList via id, needed to create a @Binding.
                                    NavigationLink(destination: DetailContactView( //irect Binding to the element at that position, so edits in DetailContactView save back to the array
                                        contact: $contactList[index],
                                        onDelete: {
                                            contactList.remove(at: index) //closure that actually removes from the array when called.
                                        }
                                    )) {
                                        ContactCardView(contact: contact)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.plain) //removes the default blue highligh
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("ContactsCue")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search by name") //Adds the native iOS search bar to the navigation bar. text: $searchText = connected to @State searchText — every keystroke updates state → searchedContacts recalculates → grid updates. prompt: "Search by name" = placeholder text inside the search bar.
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
                AddContactView(contacts: $contactList) //Sheet that slides up from the bottom when showAddContact = true. contacts: $contactList = passes Binding to the entire array, so new contacts added in AddContactView go directly into contactList and the grid automatically updates.
            }
            .animation(.easeInOut(duration: 0.2), value: selectedRelationship) //Smooth 0.2 second animation every time selectedRelationship changes, when the user taps a filter chip. .easeInOut = animation starts slow, speeds up in the middle, then slows down at the end. The grid transitions smoothly, not abruptly.
        }
    }
}


struct MyCardView: View {
    @Binding var me: Contact // direct connection to the isMe contact in contactList, so if the profile is edited, changes save to the original array.
    var totalContacts: Int //number of contacts excluding yourself, received from ContentView for display.
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(destination: MyProfileDetailView(me: $me)) { //Makes the entire card tappable to navigate to MyProfileDetailView. me: $me = passes Binding so profile edits in MyProfileDetailView save back to contactList.
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
                    .font(.footnote.weight(.light))
                    .foregroundColor(.secondary)
            }
        }

        .padding(.horizontal, 0)
    }
}
struct RelationshipFilterChip: View {
    //Reusable filter chip component. relationship = the relationship type this chip represents.
    var relationship: Relationship
    var isSelected: Bool //whether this chip is currently active/selected.
    var onTap: () -> Void //closure called when chip is tapped, the actual action (updating selectedRelationship) happens in ContentView.
    var body: some View {
        HStack{
            VStack{
                Button(action: onTap) { //when tapped, calls the onTap closure. Chip contents: small 8x8pt colored dot + label text. 
                    HStack(spacing: 4) {
                        Circle()
                            .fill(relationship.color)
                            .frame(width: 8, height: 8)
                        
                        Text(relationship.label)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        isSelected
                        ? relationship.color
                        : relationship.color.opacity(0.12) //full color background if active, 12% transparent color background if not.
                    )
                    .clipShape(Capsule())
                }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
