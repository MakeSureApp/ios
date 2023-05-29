//
//  ContactView.swift
//  MakeSure
//
//  Created by andreydem on 4/29/23.
//

import SwiftUI

struct ContactView: View {
    
    @EnvironmentObject var viewModel: ContactsViewModel
    @EnvironmentObject var testsViewModel: TestsViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    let contact: UserModel
    @State private var showSharingTestView = false
    @State private var isAnimating: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            CustomColors.thirdGradient
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding([.top, .leading], 16)
                .padding(.bottom, -12)
                VStack {
                    ZStack(alignment: .trailing) {
                        Spacer()
                        if let image = viewModel.contactsImages[contact.id] {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 157, height: 157)
                                .clipShape(Circle())
                                .shadow(color: .white, radius: 30)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 157, height: 157)
                                .clipShape(Circle())
                                .shadow(color: .white, radius: 30)
                        }
                        
                        let date = viewModel.getLastDateWith(contact: contact)
                        if let metDateString = viewModel.getMetDateString(date), let date {
                            Text(metDateString)
                                .font(.poppinsRegularFont(size: 9))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(viewModel.metDateColor(date: date))
                                .cornerRadius(8)
                                .padding(.bottom, 130)
                                .padding(.trailing, -40)
                        }
                    }
                    Text(contact.name)
                        .font(.poppinsBoldFont(size: 16))
                        .foregroundColor(.white)
                        .padding()
                    
                    if testsViewModel.isLoadingContactTests {
                        RotatingShapesLoader(animate: $isAnimating)
                            .frame(width: 100)
                            .padding(.top, 50)
                            .onAppear {
                                isAnimating = true
                            }
                            .onDisappear {
                                isAnimating = false
                            }
                    } else if testsViewModel.hasLoadedContactTests {
                        if !testsViewModel.contactLastTests.isEmpty {
                            if let date = testsViewModel.contactLastTests.first?.date {
                                HStack {
                                    Spacer()
                                    Text(date.toString)
                                        .font(.poppinsMediumFont(size: 20))
                                        .foregroundColor(.white)
                                        .padding(4)
                                    Spacer()
                                }
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(testsViewModel.contactLastTests) { test in
                                    TestView(test: test)
                                }
                            }
                            HStack {
                                Spacer()
                                Button {
                                    testsViewModel.learnMoreBtnClicked()
                                } label: {
                                    Text("learn_more_button".localized)
                                        .font(.poppinsLightFont(size: 14))
                                        .foregroundColor(.gray)
                                        .underline()
                                }
                            }
                        } else {
                            Spacer()
                            Text("no_tests_for_contact".localized)
                                .font(.poppinsBoldFont(size: 16))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    Spacer()
                    Button {
                        showSharingTestView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .resizable()
                                .frame(width: 23, height: 17.5)
                                .foregroundColor(Color.gradientDarkBlue2)
                                .padding()
                            Text("share_latest_test_button".localized.uppercased())
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(Color.gradientDarkBlue2)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .padding()
                            Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.white)
                        )
                    }
                    HStack {
                        Spacer()
                        Button {
                            viewModel.showContactCalendar.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                Text("add_date_button".localized.uppercased())
                                    .font(.rubicBoldFont(size: 15))
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Button {
                            Task {
                                await viewModel.addUserToBlacklist(id: contact.id, contacts: homeViewModel.user?.contacts)
                            }
                            if viewModel.hasAddedUserToBlacklist {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("block_user_button".localized)
                                .font(.poppinsRegularFont(size: 15))
                                .foregroundColor(.gray)
                                .underline()
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.showContactCalendar = false
                }
            }
            if showSharingTestView, let date = testsViewModel.lastTests.first?.date {
                VStack {
                    Spacer()
                    ShareLastTestView(isShowView: $showSharingTestView, contact: contact, date: date)
                        .environmentObject(viewModel)
                }
            }
            if viewModel.showContactCalendar {
                VStack {
                    Spacer()
                    GraphicalDatePicker(viewModel: viewModel, testsViewModel: testsViewModel, currentMonth: Date(), isFromContactView: true, contactId: contact.id)
                        .padding(.bottom, 30)
                }
            }
        }
        .task {
            await testsViewModel.fetchContactsTests(id: contact.id)
        }
        .onDisappear {
            testsViewModel.removeContactData()
        }
    }
}

struct ShareLastTestView: View {
    @EnvironmentObject var viewModel: ContactsViewModel
    @Binding var isShowView: Bool
    let contact: UserModel
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("confirm_share_test_message".localized)
                    .font(.rubicBoldFont(size: 16))
                    .foregroundColor(.gradientDarkBlue)
                +
                Text(" \(date.toString) ")
                    .font(.rubicBoldFont(size: 16))
                    .foregroundColor(.gradientDarkBlue)
                    .underline()
                +
                Text("with_label".localized)
                    .font(.rubicBoldFont(size: 16))
                    .foregroundColor(.gradientDarkBlue)
                +
                Text(" \(contact.name)?")
                    .font(.rubicBoldFont(size: 16))
                    .foregroundColor(.gradientDarkBlue)
            }
            .padding([.leading, .top, .trailing], 16)
            HStack(spacing: 12) {
                Button(action: {
                    isShowView = false
                }) {
                    Text("cancel_button".localized.uppercased())
                        .font(.rubicBoldFont(size: 15))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gradientPurple)
                        )
                        .overlay {
                            (CustomColors.secondGradient)
                                .mask(
                                    Text("cancel_button".localized.uppercased())
                                        .font(.rubicBoldFont(size: 15))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                )
                        }
                }
                Button(action: {
                    viewModel.shareMyLatestTest(with: contact.id, date: date)
                    isShowView = false
                }) {
                    Text("share_button".localized.uppercased())
                        .font(.rubicBoldFont(size: 15))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .padding(.vertical, 2)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(CustomColors.mainGradient)
                        )
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 160)
        .background(.white)
        .cornerRadius(20)
        .padding()
    }
}

//struct ContactView_Previews: PreviewProvider {
//    static var previews: some View {
//        let tests: [Test] = [
//            Test(id: UUID(), name: "HIV"),
//            Test(id: UUID(), name: "Syphilis"),
//            Test(id: UUID(), name: "Chlamydia"),
//            Test(id: UUID(), name: "Gonorrhea"),
//            Test(id: UUID(), name: "Hepatite B"),
//            Test(id: UUID(), name: "HPV")]
//
//        ContactView(contact: UserModel(id: UUID(), name: "Joyce", birthdate: Date(), sex: "female", phone: "+79001234567"), viewModel: ContactsViewModel())
//    }
//}
