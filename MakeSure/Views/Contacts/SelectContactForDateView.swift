//
//  SelectContactForDateView.swift
//  MakeSure
//
//  Created by andreydem on 5/1/23.
//

import SwiftUI

struct SelectContactForDateView: View {
    @StateObject var viewModel: ContactsViewModel
    let date: Date
    @State private var selectedContact: Contact?
    @State private var selectedContactIdForDate: UUID?
    
    var body: some View {
        VStack {
            HStack {
                Text("My contacts")
                    .font(.poppinsBoldFont(size: 23))
                    .padding()
                Spacer()
                Button {
                    withAnimation {
                        viewModel.selectedDate = nil
                    }
                } label: {
                    Text("Cancel")
                        .font(.poppinsRegularFont(size: 18))
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            HStack {
                Text("Sort by")
                    .font(.poppinsRegularFont(size: 14))
                Picker("Sort by", selection: $viewModel.sortBy) {
                    Text("Date followed").tag(ContactsViewModel.SortBy.dateFollowed)
                    Text("Recent meetings").tag(ContactsViewModel.SortBy.dateRecentMeetings)
                }
                .pickerStyle(MenuPickerStyle())
                .font(.poppinsBoldFont(size: 10))
                .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, -14)
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.contacts) { contact in
                        SelectContactItemView(viewModel: viewModel, contact: contact, selectedContactId: $selectedContactIdForDate)
                    }
                }
            }
            Button {
                if let id = selectedContactIdForDate {
                    viewModel.addDate(date, with: id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            viewModel.selectedDate = nil
                        }
                    }
                }
            } label: {
                Text("SAVE DATE")
                    .font(.rubicBoldFont(size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(selectedContactIdForDate != nil ? .white : .black)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(selectedContactIdForDate != nil ? CustomColors.mainGradient : CustomColors.whiteGradient)
                            .shadow(color: .gray, radius: 2, x: 0, y: 1)
                    )
            }
            .padding(.horizontal)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedContactIdForDate = nil
        }
        .background(.white)
    }
}

struct SelectContactItemView: View {
    @ObservedObject var viewModel: ContactsViewModel
    let contact: Contact
    @Binding var selectedContactId: UUID?

    var body: some View {
        HStack {
            Image(uiImage: contact.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 63, height: 63)
                .clipShape(Circle())
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.poppinsBoldFont(size: 14))
                
                let date = viewModel.getLastDateWith(contact: contact)
                
                if let metDateString = viewModel.getMetDateString(date), let date {
                    Text(metDateString)
                        .font(.poppinsRegularFont(size: 9))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.metDateColor(date: date))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Button(action: {
                selectedContactId = contact.id
            }) {
                if contact.id == selectedContactId {
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
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedContactId = contact.id
        }
    }
}

struct SelectContactForDateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectContactForDateView(viewModel: ContactsViewModel(), date: Date())
    }
}
