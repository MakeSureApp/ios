//
//  ViewwingImageView.swift
//  MakeSure
//
//  Created by andreydem on 5/1/23.
//

import SwiftUI

struct ViewingImageView: View {
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        viewModel.showImagePhoto = false
                    }
                } label: {
                    Text("cancel_button".localized)
                        .font(.poppinsRegularFont(size: 18))
                        .foregroundColor(.black)
                        .padding()
                }
            }
            Spacer()
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
            }
            Spacer()
        }
        .background(.white)
    }
}

struct ViewingImageView_Previews: PreviewProvider {
    static var previews: some View {
        ViewingImageView(viewModel: HomeViewModel())
    }
}
