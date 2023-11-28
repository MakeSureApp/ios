//
//  SelectContactItemView.swift
//  MakeSure
//
//  Created by Macbook Pro on 08.11.2023.
//

import SwiftUI

struct SelectContactItemView: View {
    let image: UIImage?
    let date: Date?
    let contact: UserModel
    let isEnabled: Bool
    @Binding var selectedContactIds: [UUID]?

    var isSelected: Bool {
        if let ids = selectedContactIds {
            return ids.contains(contact.id)
        } else {
            return false
        }
    }

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
            
            Button(action: {
                if isEnabled {
                    toggleSelection()
                }
            }) {
                if isEnabled {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .font(.headline)
                            .foregroundColor(.gradientDarkBlue)
                    } else {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .font(.headline)
                            .foregroundColor(.gradientDarkBlue)
                    }
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled {
                toggleSelection()
            }
        }
    }
    
    func toggleSelection() {
        guard var ids = selectedContactIds else { return }
        
        if let index = ids.firstIndex(of: contact.id) {
            ids.remove(at: index)
        } else {
            ids.append(contact.id)
        }
        
        selectedContactIds = ids
    }
}

//#Preview {
//    SelectContactItemView(image: nil, date: nil, contact: <#UserModel#>, selectedContactIds: <#Binding<[UUID]?>#>)
//}
