//
//  HomeView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @State private var isAnimating: Bool = false
    @State private var isAnimatingTests: Bool = false
    @State private var isAnimatingImage: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 6) {
                topCardView
                    .task {
                        await viewModel.fetchUserData()
                        await withTaskGroup(of: Void.self) { group in
                            group.addTask(priority: .userInitiated) {
                                await viewModel.fetchTestsCount()
                            }
                            
                            group.addTask(priority: .userInitiated) {
                                await viewModel.loadImage()
                            }
                        }
                    }
                secondCardView
                tipsSection
                    .task {
                        await viewModel.fetchTips()
                    }
                if viewModel.hasLoadedTips {
                    cardList
                }
            }
            .padding(.horizontal)
        }
    }
}

private extension HomeView {
    var topCardView: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(CustomColors.fourthGradient)
            .frame(height: 150)
            .overlay {
                ZStack {
                    VStack {
                        if viewModel.hasLoadedUser {
                            // Photo section
                            VStack {
                                if viewModel.isLoadingImage, viewModel.image == nil {
                                    // Loading animation
                                    Circle()
                                        .foregroundColor(.gradientDarkBlue)
                                        .frame(width: 81, height: 81)
                                        .overlay(
                                            RotatingShapesLoader(animate: $isAnimatingImage)
                                                .frame(maxWidth: 35)
                                                .onAppear {
                                                    isAnimatingImage = true
                                                }
                                                .onDisappear {
                                                    isAnimatingImage = false
                                                }
                                        )
                                } else if let image = viewModel.image {
                                    // Photo
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 81, height: 81)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                        .onTapGesture {
                                            viewModel.showPhotoMenu.toggle()
                                        }
                                } else {
                                    // Default placeholder
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 81, height: 81)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // User info section
                            HStack {
                                VStack {
                                    if viewModel.hasLoadedTests {
                                        Text("\(viewModel.testsDone)")
                                            .font(.interRegularFont(size: 20))
                                            .foregroundColor(.white)
                                        Text("tests_done".localized)
                                            .font(.interRegularFont(size: 12))
                                            .foregroundColor(.white)
                                            .minimumScaleFactor(0.8)
                                    } else if viewModel.isLoadingTests {
                                        RowOfShapesLoader(animate: $isAnimatingTests, count: 3, spacing: 2)
                                            .frame(maxWidth: 60)
                                            .padding(.top, 10)
                                            .onAppear {
                                                isAnimatingTests = true
                                            }
                                            .onDisappear {
                                                isAnimatingTests = false
                                            }
                                    }
                                }
                                .frame(width: 80)
                                
                                Spacer()
                                
                                if let user = viewModel.user {
                                    Text(user.name)
                                        .font(.poppinsBoldFont(size: 18))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    if let user = viewModel.user {
                                        Text("\(user.birthdate.getAge)")
                                            .font(.interRegularFont(size: 20))
                                            .foregroundColor(.white)
                                        Text("years_old".localized)
                                            .font(.interRegularFont(size: 12))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: 80)
                            }
                        } else if viewModel.isLoadingUser {
                            // Loading animation
                            RotatingShapesLoader(animate: $isAnimating)
                                .frame(maxWidth: 100)
                                .onAppear {
                                    isAnimating = true
                                }
                                .onDisappear {
                                    isAnimating = false
                                }
                        } else {
                            // No internet connection
                            Text("check_internet_connection".localized)
                                .font(.interSemiBoldFont(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .padding(.horizontal, 12)
                    .foregroundColor(.white)
                    
                    if viewModel.showPhotoMenu {
                        // Photo menu overlay
                        HStack {
                            Image(systemName: "arrowtriangle.left.fill")
                                .resizable()
                            VStack {
                                Button {
                                    viewModel.requestPhoto()
                                } label: {
                                    Text("change".localized)
                                        .font(.interRegularFont(size: 16))
                                        .foregroundColor(.black)
                                }
                                .padding(.top, 6)
                                
                                Divider()
                                    .frame(maxWidth: 110)
                                
                                Button {
                                    viewModel.showImagePhoto = true
                                } label: {
                                    Text("show".localized)
                                        .font(.interRegularFont(size: 16))
                                        .foregroundColor(.black)
                                }
                                .padding(.bottom, 6)
                            }
                            .padding(.vertical, 2)
                            .background(.white)
                            .cornerRadius(12)
                        }
                        .padding(.leading, 210)
                        .padding(.bottom, 50)
                    }
                }
            }
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
                    Text("order_new_box".localized)
                        .font(.poppinsMediumFont(size: 18))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
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
            Text("tips_heading".localized)
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
                        Text(category.name)
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
                .padding(.bottom)
            }
        }
    }
}

private extension HomeView {
    var cardList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.filteredCards) { card in
                ZStack(alignment: .bottomLeading) {
                    cardBackgroundImage(for: card.id)
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
                .onAppear {
                    viewModel.loadImageIfNeeded(for: card)
                }
            }
        }
    }

    func cardBackgroundImage(for id: UUID) -> some View {
        Group {
            if let image = viewModel.tipImages[id] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            } else {
                Image("mockTipsImage2")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            }
        }
    }

    func categoryImage(for category: String) -> some View {
        switch category {
        case "dates":
            return Image(systemName: "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        case "health":
            return Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        case "education":
            return Image(systemName: "book")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        case "self-development":
            return Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        default:
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
