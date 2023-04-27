//
//  CustomColors.swift
//  MakeSure
//
//  Created by andreydem on 21.04.2023.
//

import Foundation
import SwiftUI

class CustomColors {

    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [Color.gradientDarkBlue, Color.gradientPurple]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let secondGradient = LinearGradient(
        gradient: Gradient(colors: [Color.gradientDarkBlue, Color.gradientPurple]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let thirdGradient = LinearGradient(
        gradient: Gradient(colors: [Color.gradientPurple2, Color.gradientDarkBlue2]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let fourthGradient = LinearGradient(
        gradient: Gradient(colors: [Color.gradientDarkBlue3, Color.gradientPurple3]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let whiteGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let grayGradient = LinearGradient(
        gradient: Gradient(colors: [Color.gray]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let darkGray = Color("DarkGrayColor")
    static let purpleColor = Color("PurpleColor")
}

extension Color {
    static let gradientDarkBlue = Color(red: 0, green: 0.003, blue: 0.46)
    static let gradientDarkBlue2 = Color(red: 0, green: 23/255, blue: 119/255)
    static let gradientPurple = Color(red: 0.7, green: 0.46, blue: 1)
    static let gradientPurple2 = Color(red: 0.408, green: 0.318, blue: 0.788)
    static let gradientDarkBlue3 = Color(red: 0.243, green: 0.298, blue: 0.608)
    static let gradientPurple3 = Color(red: 0.569, green: 0.475, blue: 0.871)
}
