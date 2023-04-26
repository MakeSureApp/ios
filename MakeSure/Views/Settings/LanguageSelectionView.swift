//
//  LanguageSelectionView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import Foundation
import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: AvailableLanguages
    var didSelectLanguage: ((AvailableLanguages) -> Void)?
    var languages = AvailableLanguages.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(languages, id: \.self) { language in
                Button(action: {
                    selectedLanguage = language
                    didSelectLanguage?(language)
                }) {
                    HStack(spacing: 10) {
                        if selectedLanguage == language {
                            Image(systemName: "c heckmark")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.purple)
                        } else {
                            Spacer()
                                .frame(width: 15)
                        }
                        Text(language.rawValue)
                            .font(.poppinsBoldFont(size: 18))
                            .foregroundColor(selectedLanguage == language ? .purple : .black)
                        Spacer()
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .frame(width: 160)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
