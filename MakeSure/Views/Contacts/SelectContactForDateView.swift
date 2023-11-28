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
    @State private var selectedContactIdForDate: UUID?
    @State private var isAnimating: Bool = false
    @State private var selectedContactIds: [UUID]?
    
    var body: some View {
        VStack {
            HStack {
                Text("my_contacts_section".localized)
                    .font(.montserratBoldFont(size: 23))
                    .padding()
                Spacer()
                Button {
                    withAnimation {
                        viewModel.selectedDate = nil
                    }
                } label: {
                    Text("cancel_button".localized)
                        .font(.montserratRegularFont(size: 18))
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            HStack {
                Text("sort_by_label".localized)
                    .font(.montserratRegularFont(size: 14))
                Picker("sort_by_label".localized, selection: $viewModel.sortBy) {
                    Text("date_followed_option".localized).tag(ContactsViewModel.SortBy.dateFollowed)
                    Text("recent_dates_option".localized).tag(ContactsViewModel.SortBy.dateRecentMeetings)
                }
                .pickerStyle(MenuPickerStyle())
                .font(.montserratBoldFont(size: 10))
                .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, -14)
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.contacts) { contact in
                        let isEnabled = !viewModel.checkIfContactBlockedMe(user: contact)
                        if isEnabled {
                            SelectContactItemView(
                                image: viewModel.contactsImages[contact.id], date: viewModel.getLastDateWith(contact: contact), contact: contact, isEnabled: true, selectedContactIds: .constant([selectedContactIdForDate].compactMap { $0 })
                            )
                        }
                    }
                }
            }
            Button {
                if let id = selectedContactIdForDate {
                    Task {
                        await viewModel.addDate(date, with: id)
                    }
                }
            } label: {
                Text("save_date_button".localized.uppercased())
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
            .disabled(viewModel.isAddingDate)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedContactIdForDate = nil
        }
        .background(.white)
        .zIndex(0)
        
        if viewModel.isAddingDate {
            RotatingShapesLoader(animate: $isAnimating, color: .black)
                .frame(maxWidth: 80)
                .onAppear {
                    isAnimating = true
                }
                .onDisappear {
                    isAnimating = false
                }
                .zIndex(1)
        }
    }
}

struct SelectContactForDateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectContactForDateView(viewModel: ContactsViewModel(), date: Date())
    }
}
