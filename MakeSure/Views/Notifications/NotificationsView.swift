//
//  NotificationsView.swift
//  MakeSure
//
//  Created by Macbook Pro on 19.06.2023.
//

import SwiftUI

struct NotificationsView: View {
    
    @EnvironmentObject var viewModel: NotificationsViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var isAnimating: Bool = false
    private let userService = UserSupabaseService()
    @State private var selectedItemPosition: CGRect = .zero
    
    var body: some View {
        
        VStack {
            HStack {
                Button {
                    withAnimation {
                        viewModel.selectedNotification = nil
                        homeViewModel.showNotificationsView.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 12, height: 20)
                        .foregroundStyle(CustomColors.darkBlue)
                }
                
                Spacer()
                Text("notifications_section".localized)
                    .font(.montserratBoldFont(size: 17))
                    .foregroundStyle(CustomColors.darkBlue)
                Spacer()
            }
            .padding(.horizontal, 16)
            if viewModel.isLoading {
                Spacer()
                RotatingShapesLoader(animate: $isAnimating, color: .black)
                    .frame(maxWidth: 100)
                    .onAppear {
                        isAnimating = true
                    }
                    .onDisappear {
                        isAnimating = false
                    }
                Spacer()
            } else if viewModel.hasLoaded {
                ScrollView {
                    VStack {
                        ForEach(viewModel.groupedNotifications, id: \.key) { (formattedDate, notifications) in
                            Section(header:
                                        Text(formattedDate)
                                .font(.montserratBoldFont(size: 14))
                                .foregroundStyle(CustomColors.darkBlue)
                                .padding(.top, 30)
                            ) {
                                ForEach(notifications) { notification in
                                    NotificationItemView(notification: notification, userService: userService, tappedItem: $viewModel.selectedNotification, selectedItemPosition: $selectedItemPosition)
                                }
                            }
                        }
                    }
                }
                .scrollDisabled(viewModel.selectedNotification != nil)
            } else {
                VStack {
                    Spacer()
                    Text("no_notifications".localized)
                        .font(.montserratMediumFont(size: 18))
                        .foregroundStyle(.black)
                    Spacer()
                }
            }
        }
        .blur(radius: viewModel.selectedNotification != nil ? 10 : 0)
        .overlay(selectedItemOverlay)
        .background(.white)
        .onTapGesture {
            withAnimation {
                viewModel.selectedNotification = nil
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchNotifications()
            }
            
        }
    }
    
    private var selectedItemOverlay: some View {
            VStack {
                if let selectedNotification = viewModel.selectedNotification {
                    NotificationItemView(notification: selectedNotification, userService: userService, tappedItem: $viewModel.selectedNotification, selectedItemPosition: $selectedItemPosition)

                    .frame(width: selectedItemPosition.width + 30, height: selectedItemPosition.height)
                    //.fixedSize()
                    
                    HStack {
                        Button(action: {
                            Task {
                                await viewModel.deleteNotification()
                            }
                        }, label: {
                            Text("delete_button".localized)
                                .font(.montserratBoldFont(size: 16))
                                .foregroundStyle(.red)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(.black.opacity(0.1))
                                .cornerRadius(14)
                                .shadow(color: .white, radius: 4)
                        })
                        Spacer()
                    }
                    .padding(30)
                }
            }
            .position(x: selectedItemPosition.midX - 16, y: selectedItemPosition.minY + 16)
    }

}

struct NotificationItemView: View {
    var notification: NotificationModel
    var userService: UserSupabaseService
    @Binding var tappedItem: NotificationModel?
    @Binding var selectedItemPosition: CGRect
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(alignment: .bottom) {
                    notification.getIcon(userService: userService)
                        .onTapGesture {
                            if let item = tappedItem, item.id != notification.id {
                                withAnimation {
                                    tappedItem = nil
                                }
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(notification.title)
                            .font(.montserratBoldFont(size: 14))
                            .foregroundStyle(CustomColors.darkBlue)
                        Text(notification.description ?? "")
                            .font(.montserratRegularFont(size: 14))
                            .frame(height: geometry.size.height - 12)
                            .foregroundStyle(CustomColors.darkBlue)
                        HStack {
                            Spacer()
                            Text(getTime(notification.createdAt))
                                .font(.montserratRegularFont(size: 12))
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding()
                    .background(Color(red: 240/255.0, green: 240/255.0, blue: 240/255.0))
                    .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
                    .cornerRadius(4, corners: [.bottomLeft])
                    .onTapGesture {
                        if let item = tappedItem, item.id != notification.id {
                            withAnimation {
                                tappedItem = nil
                            }
                        }
                    }
                    .onLongPressGesture {
                        withAnimation {
                            let frame = geometry.frame(in: .global)
                            selectedItemPosition = frame
                            tappedItem = notification
                        }
                    }
                }
                .onTapGesture {
                    if let item = tappedItem, item.id != notification.id {
                        withAnimation {
                            tappedItem = nil
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(minHeight: 60)
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .onTapGesture {
            if let item = tappedItem, item.id != notification.id {
                withAnimation {
                    tappedItem = nil
                }
            }
        }
    }
    
    
    func getTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

struct UserIconView: View {
    let userId: UUID
    let userService: UserSupabaseService

    @State private var userPhotoUrl: URL?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 45, height: 45)
            } else {
                if let url = userPhotoUrl {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                    }
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 45, height: 45)
                }
            }
        }
        .onAppear {
            fetchUser()
        }
    }

    private func fetchUser() {
        Task {
            do {
                if let user = try await userService.fetchUserById(id: userId) {
                    if let photoUrl = user.photoUrl {
                        self.userPhotoUrl = URL(string: photoUrl)
                    }
                }
            } catch {
                print("Error fetching user: \(error)")
            }
            self.isLoading = false
        }
    }
}

struct NotificationAnchorKey: PreferenceKey {
    typealias Value = [UUID: Anchor<CGRect>]
    static var defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationItemView(notification: NotificationModel(id: UUID(), userId: UUID(), title: "Hello", description: "some description...", createdAt: Date(), isNotified: false, author: nil), userService: UserSupabaseService(), tappedItem: .constant(nil), selectedItemPosition: .constant(.zero))
//        NotificationsView()
//            .environmentObject(NotificationsViewModel(mainViewModel: MainViewModel()))
//            .environmentObject(HomeViewModel(mainViewModel: MainViewModel()))
    }
}
