//
//  HelpView.swift
//  MakeSure
//
//  Created by andreydem on 4/26/23.
//

import SwiftUI

struct HelpView: View {
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

                VStack(spacing: 30) {
                    HStack {
                        Text("help_section".localized)
                            .font(.montserratLightFont(size: 56))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 46, height: 46)
                            .foregroundColor(.white)
                        Spacer()
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("FAQ")
                            .font(.montserratBoldFont(size: 33))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("what_is_make_sure_question".localized)
                            .font(.montserratMediumFont(size: 17))
                            .foregroundColor(.white)
                        Text("make_sure_description".localized)
                            .font(.montserratLightFont(size: 16))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("what_is_make_sure_question".localized)
                            .font(.montserratMediumFont(size: 17))
                            .foregroundColor(.white)
                        Text("make_sure_description".localized)
                            .font(.montserratLightFont(size: 16))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("what_is_make_sure_question".localized)
                            .font(.montserratMediumFont(size: 17))
                            .foregroundColor(.white)
                        Text("make_sure_description".localized)
                            .font(.montserratLightFont(size: 16))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding([.leading, .trailing, .bottom], 30)
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
