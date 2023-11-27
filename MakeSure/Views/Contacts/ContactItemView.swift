//
//  ContactItemView.swift
//  MakeSure
//
//  Created by Macbook Pro on 08.11.2023.
//

import SwiftUI

struct ContactItemView: View {
    let image: UIImage?
    let date: Date?
    let contact: UserModel
    
    var body: some View {
        HStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 63, height: 63)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 63, height: 63)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.montserratBoldFont(size: 14))
                
                if let metDateString = date.getMetDateString, let date {
                    Text(metDateString)
                        .font(.montserratRegularFont(size: 9))
                        .foregroundColor(date.getMetDateTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(date.getMetDateBackgroundColor)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .cornerRadius(10)
    }
}

//#Preview {
//    ContactItemView()
//}
