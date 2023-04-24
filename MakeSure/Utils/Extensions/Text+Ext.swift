//
//  Text+Ext.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import SwiftUI

extension Text {
    
    public func foregroundLinearGradient(gradient: LinearGradient) -> some View {
        self.overlay {
            gradient
            .mask(
                self
            )
        }
    }
    
}
