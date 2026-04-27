//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 22/04/26.
//

import SwiftUI

struct DetailContactView: View {
    //Receives a direct connection to one contact in ContentView's contactList
    @Binding var contact: Contact
    //A boolean to control when the EditContactView sheet appears. false = sheet hidden, true = sheet visible. Only accessible from within this view (private).
    @State private var showEdit = false
    //Grabs the dismiss function from the iOS system. Used after a contact is deleted, so this detail screen automatically closes and returns to the grid in ContentView.
    @Environment(\.dismiss) var dismiss
    //A closure (function) sent from ContentView. It doesn't delete by itself, it just passes the delete command to ContentView which actually knows how to remove from the array bcs that is the parents view. () -> Void means it takes no parameters and returns nothing so it is take and return nothing.
    var onDelete: () -> Void
    //calculated automatically each time it's called, not stored
    //check photoData first (photo from gallery)
    var contactImage: Image {
        if let data = contact.photoData,
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        if !contact.imageName.isEmpty { //if none check imageName (photo from Assets.xcassets)
            return Image(contact.imageName)
        }
        return Image(systemName: "person.fill") //if both are missing use the default iOS person icon. This ensures there's always something to display.
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                //GeometryReader accurately measures the available screen width (geo.size.width). Used so the photo always fills the full screen width, gallery photos can be very large and would overflow without being constrained by geo.size.width.
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        contactImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 320) //for making photo constrained
                            .clipped() //clipped() cuts off any photo that goes outside the frame.
                        
                        LinearGradient(//A transparent dark layer over the photo
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .center,
                            endPoint: .bottom //from center transparent to bottom 80% black. Its purpose is to keep the name text and relationship badge at the bottom readable even on bright photos.
                        )
                        .frame(width: geo.size.width, height: 320)
                        //Full name text + relationship badge at the bottom of the photo.
                        VStack(spacing: 4) {
                            Text(contact.fullName)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            HStack(spacing: 6) { //The small colored dot to the left of the relationship text visually indicates the relationship category.
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
                .frame(height: 320) //GeometryReader by default takes all available space, its height is unlimited. This line is required to constrain the GeometryReader's height to 320pt so it doesn't fill the entire screen.
                
                // button call & message
                HStack(spacing: 16) {
                    Button { //green call button
                        //Creates a phone URL scheme, so this is tells to iOS that open the Phone app and dial this number
                        //Ensures the URL is valid and prevents crashes
                        if let url = URL(string: "tel:\(contact.phoneNumber)") {
                            UIApplication.shared.open(url) //send instruction to iOS to open phone app and dial the number
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
                    
                    Button { //blue message button
                        //Same as the Call button but uses the sms: scheme, this opens the Messages app with the number already pre-filled, ready to send a message.
                        if let url = URL(string: "sms:\(contact.phoneNumber)") { //get the phoneNumbr by contact
                            UIApplication.shared.open(url) //send instruction to iOS to open message app and dial the number
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
                
                // info rows
                VStack(spacing: 12) {
                    //Tree info rows each separated by a Divider. InfoRow is a reusable component that accepts an icon, color, label, and value.
                    InfoRow(icon: "phone", iconColor: .green, label: "Phone", value: contact.phoneNumber)
                    Divider().padding(.leading, 52)
                    InfoRow(icon: "person.2", iconColor: contact.relationship.color, label: "Relationship", value: contact.relationship.label)
                    Divider().padding(.leading, 52)
                    InfoRow(icon: "brain", iconColor: .purple, label: "Memory Cue", value: contact.memoryCue)
                }
                .padding()
                .background(Color(.systemBackground)) //hite background that adapts (dark in dark mode).
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer(minLength: 40)
            }
        }
        .ignoresSafeArea(edges: .top) //Makes the photo extend to the top of the screen past the safe area (status bar area).  The photo appears full from top to bottom with no white gap at the top.
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { //Edit" button at the top right corner
                Button("Edit") {
                    showEdit = true //When tapped, showEdit becomes true → the EditContactView sheet automatically appears because it's connected to .sheet(isPresented: $showEdit).
                }
            }
        }
        
        //The edit sheet appears when showEdit = true. contact: $contact = passes the binding so edits save directly to the original contact in contactList.
        .sheet(isPresented: $showEdit) {
            EditContactView(
                contact: $contact,
                onDelete: {
                    showEdit = false
                    onDelete() //The onDelete closure inside the sheet has 3 sequential steps: close the edit sheet and forward the delete command to ContentView (which actually removes from the array)
                    dismiss()//close DetailContactView to return to the grid.
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        DetailContactView(
            contact: .constant(fharles), //Xcode preview using fharles data as an example
            onDelete: { } //onDelete: { } = empty closure because in preview we don't actually need to delete data.
        )
    }
}


// Componen row info
//A reusable component for one info row. Takes 4 parameters: name for the icon, icon color, small label at top (Phone/Relationship/Memory Cue), and the value to display. Used in both DetailContactView and MyProfileDetailView without needing to rewrite the code.
struct InfoRow: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: String
    
    var body: some View {
        HStack(spacing: 14) {
            // icon circle
            ZStack { //Structure of one row: ZStack containing a transparent background circle + icon centered inside it,
                Circle()
                    .fill(iconColor.opacity(0.15)) //circle background color matches the icon color but at only 15% opacity so it's not too prominent.
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value) //value is the actual data being displayed, e.g: label-> phone, value->09192
                    .font(.body)
            }
            
            Spacer()
        }
    }
}
