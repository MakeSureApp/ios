//
//  HomeView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 6) {
                topCardView
                secondCardView
                tipsSection
                cardList
            }
            .padding(.horizontal)
        }
        .padding(.top, -40)
    }
}

private extension HomeView {
    var topCardView: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(CustomColors.fourthGradient)
            .frame(height: 150)
            .overlay(
                VStack {
                    Image("mockPhotoImageHome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 81, height: 81)
                    HStack {
                        VStack {
                            Text("\(viewModel.testsDone)")
                                .font(.interRegularFont(size: 20))
                            Text("Tests done")
                                .font(.interRegularFont(size: 12))
                        }
                        Spacer()
                        Text(viewModel.name)
                            .font(.poppinsBoldFont(size: 18))
                        Spacer()
                        VStack {
                            Text("\(viewModel.age)")
                                .font(.interRegularFont(size: 20))
                            Text("Years old")
                                .font(.interRegularFont(size: 12))
                        }
                    }
                }
                .padding()
                .padding(.horizontal, 12)
                .foregroundColor(.white)
            )
    }
}

private extension HomeView {
    var secondCardView: some View {
        ZStack {
            Image("orderNewBoxCardImage")
                .resizable()
                .frame(height: 75)
                .cornerRadius(10)
            HStack {
                VStack(alignment: .leading) {
                    Text("Order New box")
                        .font(.poppinsMediumFont(size: 18))
                        .foregroundColor(.white)
                    Text("1 490 руб.")
                        .font(.poppinsBoldFont(size: 11))
                        .foregroundColor(.white)
                }
                .padding(.leading, 30)
                Spacer()
                Image("orderBoxImage")
                    .resizable()
                    .frame(width: 173, height: 115)
                    .padding(.bottom, -6)
                    .padding(.trailing, -4)
            }
        }
        .onTapGesture {
            viewModel.orderNewBoxClicked()
        }
    }
}

private extension HomeView {
    var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(.poppinsBoldFont(size: 25))
                .foregroundColor(Color.gradientPurple2)
            HStack {
                ForEach(viewModel.tipCategories, id: \.self) { category in
                    Button(action: {
                        if let index = viewModel.selectedCategories.firstIndex(of: category) {
                            viewModel.selectedCategories.remove(at: index)
                        } else {
                            viewModel.selectedCategories.append(category)
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.poppinsBoldFont(size: 10))
                            .frame(height: 20)
                            .padding(.horizontal, 10)
                            .background(viewModel.selectedCategories.contains(category) ? category.color : .white)
                            .foregroundColor(viewModel.selectedCategories.contains(category) ? .white : category.color)
                            .cornerRadius(20)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(category.color, lineWidth: 1.88)
                            }
                    }
                    .padding(.trailing, 4)
                }
            }
        }
    }
}

private extension HomeView {
    var cardList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.filteredCards) { card in
                ZStack(alignment: .bottomLeading) {
                    cardBackgroundImage(for: card)
                    VStack(alignment: .leading, spacing: 5) {
                        categoryImage(for: card.category)
                            .fontWeight(.bold)
                            .padding(.top, 12)
                        Spacer()
                        if let description = card.description {
                            Text(description)
                                .font(.poppinsRegularFont(size: 13))
                                .foregroundColor(.white)
                        }
                        Text(card.title)
                            .font(.poppinsMediumFont(size: 32))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                    }
                    .padding(.leading, 10)
                }
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                .onTapGesture {
                    viewModel.openTipsDetails(card.url)
                }
            }
        }
    }

    func cardBackgroundImage(for card: Card) -> some View {
        Image(card.image)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }

    func categoryImage(for category: Category) -> some View {
        switch category {
        case .dates:
            return Image(systemName: "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        case .selfDevelopment:
            return Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        case .health:
            return Image(systemName: "staroflife")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
