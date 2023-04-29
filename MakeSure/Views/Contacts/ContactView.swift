//
//  ContactView.swift
//  MakeSure
//
//  Created by andreydem on 4/29/23.
//

import SwiftUI

struct ContactView: View {
    let contact: Contact
    @ObservedObject var viewModel: ContactsViewModel
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
                        contact.image
                            .resizable()
                            .frame(width: 157, height: 157)
                            .clipShape(Circle())
                            .shadow(color: .white, radius: 30)
                        
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
                    let testsData = viewModel.getLatestsTests(contact)
                    
                    HStack {
                        Text(testsData?.date.toString ?? "No tests")
                            .font(.poppinsMediumFont(size: 20))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    if let testsData {
                        ForEach(testsData.tests, id: \.self) { test in
                            HStack {
                                Circle()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(Color.lightGreen)
                                Text(test.name)
                                    .font(.poppinsLightFont(size: 15))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Negative")
                                    .font(.poppinsLightFont(size: 15))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("Learn more")
                                .font(.poppinsRegularFont(size: 15))
                                .foregroundColor(.gray)
                                .underline()
                        }
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .resizable()
                                .frame(width: 23, height: 17.5)
                                .foregroundColor(Color.gradientDarkBlue2)
                                .padding()
                            Text("SHARE MY LATEST TEST")
                                .font(.rubicBoldFont(size: 15))
                                .foregroundColor(Color.gradientDarkBlue2)
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
                                Text("ADD DATE")
                                    .font(.rubicBoldFont(size: 15))
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                            }
                        }

                        Spacer()
                    }
                    HStack {
                        Button {
                            viewModel.showContactCalendar = false
                        } label: {
                            Text("Block user")
                                .font(.poppinsRegularFont(size: 15))
                                .foregroundColor(.gray)
                                .underline()
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .onTapGesture {
                    viewModel.showContactCalendar = false
                }
            }
            if viewModel.showContactCalendar {
                VStack {
                    Spacer()
                    GraphicalDatePicker(viewModel: viewModel, currentMonth: Date(), isFromContactView: true, contactId: contact.id)
                        .padding(.bottom, 30)
                }
                .onTapGesture {
                    viewModel.showContactCalendar = false
                }
            }
        }
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        let tests: [Test] = [
            Test(id: UUID(), name: "HIV"),
            Test(id: UUID(), name: "Syphilis"),
            Test(id: UUID(), name: "Chlamydia"),
            Test(id: UUID(), name: "Gonorrhea"),
            Test(id: UUID(), name: "Hepatite B"),
            Test(id: UUID(), name: "HPV")]
        
        ContactView(contact: Contact(id: UUID(), name: "Joyce", dates: [:], testsData: [Date.from(year: 2023, month: 1, day: 13) : tests], image: Image("mockContactImage2"), followedDate: Date()), viewModel: ContactsViewModel())
    }
}
