//
//  HomeView.swift
//  MakeSure
//
//  Created by andreydem on 4/24/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var isAnimating: Bool = false
    @State private var isAnimatingTests: Bool = false
    @State private var isAnimatingImage: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 6) {
                topCardView
                    .task {
                        await viewModel.getUserData()
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
            .task {
                await viewModel.fetchUserData()
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
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
                            Group {
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
                                        .scaledToFill()
                                        .frame(width: 81, height: 81)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                        
                                } else {
                                    // Default placeholder
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 81, height: 81)
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                if viewModel.image != nil {  viewModel.showPhotoMenu.toggle()
                                } else if !viewModel.isLoadingImage {
                                    viewModel.showPickPhotoMenu.toggle()
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
                                
                                    Text(viewModel.name)
                                        .font(.montserratBoldFont(size: 18))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                
                                Spacer()
                                
                                VStack {
                                        Text("\(viewModel.birthdate.getAge)")
                                            .font(.interRegularFont(size: 20))
                                            .foregroundColor(.white)
                                        Text("years_old".localized)
                                            .font(.interRegularFont(size: 12))
                                            .foregroundColor(.white)
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
                        HStack {
                            Spacer()
                            HStack {
                                Image(systemName: "arrowtriangle.left.fill")
                                    .resizable()
                                    .frame(width: 30, height: 40)
                                    .foregroundColor(.white)
                                VStack {
                                    Button {
                                        viewModel.requestPhoto()
                                        viewModel.showPhotoMenu.toggle()
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
                                        viewModel.showPhotoMenu.toggle()
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
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 50)
                    } else if viewModel.showPickPhotoMenu {
                        HStack {
                            Spacer()
                            HStack(alignment: .center) {
                                Image(systemName: "arrowtriangle.left.fill")
                                    .resizable()
                                    .frame(width: 22, height: 34)
                                    .foregroundColor(.white)
                                Button {
                                    viewModel.requestPhoto()
                                    viewModel.showPickPhotoMenu.toggle()
                                } label: {
                                    Text("add_photo".localized)
                                        .font(.interRegularFont(size: 16))
                                        .foregroundColor(.black)
                                }
                                .padding(8)
                                .background(.white)
                                .cornerRadius(12)
                            }
                            .padding(.bottom, 45)
                            .padding(.trailing, 4)
                        }
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
                        .font(.montserratMediumFont(size: 18))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(.white)
                    Text("1 490 руб.")
                        .font(.montserratBoldFont(size: 11))
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
            withAnimation {
                viewModel.mainViewModel.showOrderBoxView = true
            }
        }
    }
}

private extension HomeView {
    var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("tips_heading".localized)
                .font(.montserratBoldFont(size: 25))
                .foregroundColor(Color.gradientPurple2)
//            HStack {
//                ForEach(viewModel.tipCategories, id: \.self) { category in
//                    Button(action: {
//                        if let index = viewModel.selectedCategories.firstIndex(of: category) {
//                            viewModel.selectedCategories.remove(at: index)
//                        } else {
//                            viewModel.selectedCategories.append(category)
//                        }
//                    }) {
//                        Text(category.displayName)
//                            .font(.montserratBoldFont(size: 10))
//                            .fixedSize(horizontal: true, vertical: false)
//                            .frame(height: 20)
//                            .padding(.horizontal, 10)
//                            .background(viewModel.selectedCategories.contains(category) ? category.color : .white)
//                            .foregroundColor(viewModel.selectedCategories.contains(category) ? .white : category.color)
//                            .cornerRadius(20)
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(category.color, lineWidth: 1.88)
//                            }
//                    }
//                    .padding(.trailing, 4)
//                }
//                .padding(.bottom)
//            }
        }
    }
}

private extension HomeView {
    var cardList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.filteredCards) { card in
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        cardBackgroundImage(for: card.id)
                        VStack(alignment: .leading, spacing: 5) {
                            categoryImage(for: card.category)
                                .fontWeight(.bold)
                                .padding(.top, 12)
                            Spacer()
                            if let description = card.displayDescription {
                                Text(description)
                                    .font(.montserratRegularFont(size: 13))
                                    .foregroundColor(.white)
                            }
                            Text(card.displayTitle)
                                .font(.montserratMediumFont(size: 32))
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
                        viewModel.openTipsDetails(card.displayUrl)
                    }
                    .contentShape(Rectangle())
                    .onAppear {
                        viewModel.loadImageIfNeeded(for: card)
                    }
                }
                .frame(height: 200, alignment: .top)
            }
        }
    }

    func cardBackgroundImage(for id: UUID) -> some View {
        Group {
            if let image = viewModel.tipImages[id] {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            } else {
                Image("mockTipsImage2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
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
        HomeView()
            .environmentObject(HomeViewModel(mainViewModel: MainViewModel()))
    }
}
