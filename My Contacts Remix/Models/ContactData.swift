//
//  ContactData.swift
//  My Contacts Remix
//
//  Created by Ni Komang Ayu Juliana on 21/04/26.
//
import SwiftUI

var ayuk = Contact(firstName: "Ayu", lastName: "Juliana", imageName: "ayuk", relationship: .family, memoryCue: "my profile", phoneNumber: "+6281199912", isMe: true)

var fharles = Contact(firstName: "Fharles", lastName: "Leclerc", imageName: "ayuk", relationship: .friend, memoryCue: "my friend", phoneNumber: "+6281199912", isMe: false)

var nana = Contact(firstName: "Nana", lastName: "Leclerc", imageName: "ayuk", relationship: .social, memoryCue: "meet at paddle event", phoneNumber: "+6281199912", isMe: false)

var falen = Contact(firstName: "Falen", lastName: "Cia", imageName: "ayuk", relationship: .work, memoryCue: "people ADA 2026", phoneNumber: "+6281199912", isMe: false)

var falus = Contact(firstName: "Falus", lastName: "Cia", imageName: "ayuk", relationship: .family, memoryCue: "my sister", phoneNumber: "+6281199912", isMe: false)

var aya = Contact(firstName: "Ayana", lastName: "Ani", imageName: "ayuk", relationship: .closeFriend, memoryCue: "bestise SHS", phoneNumber: "+6281199912", isMe: false)

var bunana = Contact(firstName: "Bunana", lastName: "Warung", imageName: "ayuk", relationship: .service, memoryCue: "warung bunana jimbaran", phoneNumber: "+6281199912", isMe: false)

var contacts = [ayuk, fharles, falen, nana, falus, aya, bunana]
    .sorted { $0.firstName < $1.firstName }
