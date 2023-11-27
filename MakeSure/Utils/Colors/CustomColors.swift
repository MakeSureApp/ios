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
        gradient: Gradient(colors: [Color(red: 0, green: 1.0/255.0, blue: 119.0/255.0), Color(red: 166.0/255.0, green: 130.0/255.0, blue: 1)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let whiteGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let clearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.clear]),
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
    static let darkBlue = Color("DarkBlueColor")
}

extension Color {
    static let gradientDarkBlue = Color(red: 0, green: 0.003, blue: 0.46)
    static let gradientDarkBlue2 = Color(red: 0, green: 23/255, blue: 119/255)
    static let gradientPurple = Color(red: 0.7, green: 0.46, blue: 1)
    static let gradientPurple2 = Color(red: 0.408, green: 0.318, blue: 0.788)
    static let gradientDarkBlue3 = Color(red: 0.243, green: 0.298, blue: 0.608)
    static let gradientPurple3 = Color(red: 0.569, green: 0.475, blue: 0.871)
    static let lightGreen = Color(red: 95/255, green: 233/255, blue: 134/255)
    static let secondGreen = Color(red: 31/255, green: 184/255, blue: 90/255)
}
