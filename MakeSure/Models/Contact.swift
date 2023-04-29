//
//  Contact.swift
//  MakeSure
//
//  Created by andreydem on 4/27/23.
//

import Foundation
import SwiftUI

struct Contact: Identifiable {
    let id: UUID
    let name: String
    let dates: [UUID : Date]
    let testsData: [Date : [Test]]
    let image: Image
    let followedDate: Date
}
