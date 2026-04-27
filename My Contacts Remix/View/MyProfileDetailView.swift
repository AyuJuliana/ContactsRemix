//
//  MyProfileDetailView.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 22/04/26.
//

// MyProfileDetailView.swift
import SwiftUI

struct MyProfileDetailView: View {
    //A direct connection to the contact with isMe: true in ContentView's contactList
    @Binding var me: Contact
    //A boolean to control when the EditContactView sheet appears. false = sheet hidden (default). Changes to true when the user taps the "Edit" button in the toolbar, the sheet automatically appears.
    @State private var showEdit = false
    //A computed property that determines which photo to display
    var contactImage: Image {
        if let data = me.photoData, //checks photoData (photo from gallery, stored as raw bytes Data)
           let uiImage = UIImage(data: data) { //f none checks imageName (photo from Assets.xcassets)
            return Image(uiImage: uiImage)
        }
        if !me.imageName.isEmpty { //if both missing uses the built-in iOS person.fill icon. if let is used for safe unwrapping optionals, prevents crashes if the value is nil.
            return Image(me.imageName)
        }
        return Image(systemName: "person.fill")
    }
    
    var body: some View {
        ScrollView { //makes all content scrollable up/down, useful if content is longer than the screen.
            VStack(spacing: 0) {
                // accurately measures the available screen width and stores it in geo.size.width. Used so the photo always fills the full screen width without overflowing,  especially important for gallery photos which can be very large
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        contactImage
                            .resizable()
                            .scaledToFill() // fills the frame completely cropping if needed,
                            .frame(width: geo.size.width, height: 320)
                            .clipped()//cuts off anything outside the frame.

                        LinearGradient( //A transparent dark layer stacked on top of the photo.
                            colors: [.clear, .black.opacity(0.6)], //From the center of the photo it's transparent (.clear). getting darker towards the bottom up to 60% black opacity. Its purpose is to keep the name text at the bottom readable even on bright or white photos.
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(width: geo.size.width, height: 320)

                        VStack(spacing: 4) {
                            Text(me.fullName)
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 320) //Required because GeometryReader by default takes all available vertical space, it could fill the entire screen. This line constrains the GeometryReader's height to exactly 320pt.

                // button call & message
                HStack(spacing: 16) {
                    Button { //button call
                        //Creates a phone URL scheme, so this is tells to iOS that open the Phone app and dial this number
                        //Ensures the URL is valid and prevents crashes
                        if let url = URL(string: "tel:\(me.phoneNumber)") {
                            UIApplication.shared.open(url) //send instruction to iOS to open phone app and dial the number
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.fill").font(.title2) //phone symbol
                            Text("Call").font(.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                    }
                    .foregroundStyle(.green)

                    Button { //blue message button
                        //Same as the Call button but uses the sms: scheme, this opens the Message
                        if let url = URL(string: "sms:\(me.phoneNumber)") {
                            UIApplication.shared.open(url) ////send instruction to iOS to open message app and dial the number
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "message.fill").font(.title2) //message symbol
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
                    InfoRow(icon: "phone", iconColor: .green, label: "Phone", value: me.phoneNumber)
                    Divider().padding(.leading, 52)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer(minLength: 40)
            }
        }
        .ignoresSafeArea(edges: .top) //Makes the photo extend to the top of the screen past the safe area (status bar area with time and battery).
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { //"Edit" text button at the top right of the navigation bar.
                Button("Edit") { showEdit = true } //When tapped, showEdit becomes true → .sheet(isPresented: $showEdit) automatically detects this change and displays the EditContactView sheet.
            }
        }
        .sheet(isPresented: $showEdit) { //The edit sheet appears when showEdit = true
            EditContactView(
                contact: $me, //binding so edit results save directly to the original profile in contactList
                onDelete: nil, //no delete closure, because own profile shouldn't be deletable, so the Delete button won't appear in EditContactView
                isMe: true //to hide the Relationship and Memory Cue sections.
            )
        }
    }
}

#Preview {
    NavigationStack {
        MyProfileDetailView(me: .constant(ayuk)) //using ayuk data as an example bcs ayuk is the contact with isMe: true. This is a dummy binding that can't be changed, only for Xcode preview purposes.
    }
}
