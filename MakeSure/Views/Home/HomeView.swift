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
        GeometryReader { geometry in
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
                        //cardList
                        CustomGridLayoutView(width: geometry.size.width)
                            .environmentObject(viewModel)
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
                                if viewModel.isLoadingImage || viewModel.isUploadingImage {
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
                                } else if let image = viewModel.image, !viewModel.showPhoto {
                                    // Photo
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 81, height: 81)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                    
                                } else {
                                    // Default placeholder
                                    if viewModel.showPhoto {
                                       Spacer()
                                            .frame(width: 81, height: 81)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 81, height: 81)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .onTapGesture {
                                if !viewModel.isUploadingImage {
                                    viewModel.requestPhoto()
                                }
                            }
                            .onLongPressGesture {
                                if viewModel.image != nil, !viewModel.isLoadingImage, !viewModel.isUploadingImage {
                                    withAnimation {
                                        viewModel.showPhoto.toggle()
                                    }
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
                                    if appEnvironment.localizationManager.getLanguage() == .RU {
                                        Text(viewModel.birthdate.getAge.russianAgeSuffix)
                                            .font(.interRegularFont(size: 12))
                                            .foregroundColor(.white)
                                    } else {
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
        Spacer()
//        VStack(alignment: .leading, spacing: 20) {
//            ForEach(viewModel.filteredCards) { card in
//                CardView(image: viewModel.tipImages[card.id], card: card) {
//                    viewModel.loadImageIfNeeded(for: card)
//                } onTap: {
//                    viewModel.openTipsDetails(card.displayUrl)
//                }
//            }
//        }
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

struct CustomGridLayoutView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    let width: CGFloat

    var body: some View {
        ScrollView {
            LazyVStack {
                    let fullWidth = width - 40
                    let thirdWidth = fullWidth / 3
                    let twoThirdsWidth = 2 * thirdWidth
                    let fullHeigth = thirdWidth * 1.3
                    
                    let totalCards = viewModel.filteredCards.count
                    let cards = viewModel.cards
                    let spacing = 6.0
                    
                    if totalCards > 2 {
                        HStack(spacing: spacing) {
                            VStack(spacing: spacing + 4) {
                                CardView(image: viewModel.tipImages[cards[0].id], card: cards[0], width: thirdWidth, height: thirdWidth, titleAligment: .topLeading, isSmallSize: true) {
                                    viewModel.loadImageIfNeeded(for: cards[0])
                                } onTap: {
                                    viewModel.openTipsDetails(cards[0].displayUrl)
                                }
                                CardView(image: viewModel.tipImages[cards[1].id], card: cards[1], width: thirdWidth, height: thirdWidth, titleAligment: .bottomLeading, isSmallSize: true) {
                                    viewModel.loadImageIfNeeded(for: cards[1])
                                } onTap: {
                                    viewModel.openTipsDetails(cards[1].displayUrl)
                                }
                            }
                            CardView(image: viewModel.tipImages[cards[2].id], card: cards[2], width: twoThirdsWidth, height: (thirdWidth + spacing) * 2, titleAligment: .bottomLeading) {
                                viewModel.loadImageIfNeeded(for: cards[2])
                            } onTap: {
                                viewModel.openTipsDetails(cards[2].displayUrl)
                            }
                        }
                        .frame(height: (thirdWidth + spacing) * 2)
                        
                        if totalCards > 3 {
                            if totalCards != 5 {
                                CardView(image: viewModel.tipImages[cards[3].id], card: cards[3], width: fullWidth, height: fullHeigth, titleAligment: .topLeading) {
                                    viewModel.loadImageIfNeeded(for: cards[3])
                                } onTap: {
                                    viewModel.openTipsDetails(cards[3].displayUrl)
                                }
                            }
                            if totalCards == 5 || totalCards > 5 {
                                let firstIndex = totalCards == 5 ? 3 : 4
                                let secondIndex = totalCards == 5 ? 4 : 5
                                HStack(spacing: spacing) {
                                    CardView(image: viewModel.tipImages[cards[firstIndex].id], card: cards[firstIndex], width: fullWidth / 2, height: fullHeigth, titleAligment: .bottomLeading, isSmallSize: true) {
                                        viewModel.loadImageIfNeeded(for: cards[firstIndex])
                                    } onTap: {
                                        viewModel.openTipsDetails(cards[firstIndex].displayUrl)
                                    }
                                    CardView(image: viewModel.tipImages[cards[secondIndex].id], card: cards[secondIndex], width: fullWidth / 2, height: fullHeigth, titleAligment: .topLeading, isSmallSize: true) {
                                        viewModel.loadImageIfNeeded(for: cards[secondIndex])
                                    } onTap: {
                                        viewModel.openTipsDetails(cards[secondIndex].displayUrl)
                                    }
                                }
                            }
                            if totalCards > 6 {
                                let remainingCards = Array(viewModel.filteredCards.dropFirst(6))
                                ForEach(Array(remainingCards.enumerated()), id: \.element.id) { index, card in
                                    let aligment: Alignment = index % 2 == 1 ? .topLeading : .bottomLeading
                                    CardView(image: viewModel.tipImages[card.id], card: card, width: fullWidth, height: fullHeigth, titleAligment: aligment) {
                                        viewModel.loadImageIfNeeded(for: card)
                                    } onTap: {
                                        viewModel.openTipsDetails(card.displayUrl)
                                    }
                                    
                                }
                            }
                        }
                    } else {
                        ForEach(Array(viewModel.filteredCards.enumerated()), id: \.element.id) { index, card in
                            CardView(image: viewModel.tipImages[card.id], card: card, width: fullWidth, height: fullHeigth, titleAligment: .top) {
                                viewModel.loadImageIfNeeded(for: card)
                            } onTap: {
                                viewModel.openTipsDetails(card.displayUrl)
                            }
                        }
                    }
                }
        }
    }

}



struct CardView: View {
    let image: UIImage?
    var card: TipsModel
    let width: CGFloat
    let height: CGFloat
    let titleAligment: Alignment
    var isSmallSize: Bool = false
    var loadImage: () -> Void
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            ZStack(alignment: titleAligment) {
                cardBackgroundImage(for: card.id)
                
                VStack(alignment: .leading, spacing: 5) {
                    if titleAligment == .bottomLeading {
                        Spacer()
                        if let description = card.displayDescription {
                            Text(description)
                                .font(.montserratRegularFont(size: isSmallSize ? 8 : 12))
                                .foregroundColor(.white)
                        }
                        Text(card.displayTitle)
                            .font(.montserratMediumFont(size: isSmallSize ? 12 : 16))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                    } else {
                        Text(card.displayTitle)
                            .font(.montserratMediumFont(size: isSmallSize ? 12 : 18))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        if let description = card.displayDescription {
                            Text(description)
                                .font(.montserratRegularFont(size: isSmallSize ? 8 : 14))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .padding(.top, isSmallSize ? 10 : 18)
                .padding(.horizontal, isSmallSize ? 8 : 20)
            }
            
        }
        .frame(width: width, height: height)
        .cornerRadius(14)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onAppear {
            loadImage()
        }
    }
    
    
    func cardBackgroundImage(for id: UUID) -> some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                Image("mockTipsImage2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HomeViewModel(mainViewModel: MainViewModel()))
    }
}
