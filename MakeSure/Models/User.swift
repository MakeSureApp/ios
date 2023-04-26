//
//  User.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI

struct BlockedUser: Identifiable, Hashable {
    var id: UUID
    var username: String
    var name: String
    var imageName: String
}
