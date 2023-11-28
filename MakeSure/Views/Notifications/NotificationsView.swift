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
                                            .padding(.top, 12)
                            ) {
                                ForEach(notifications) { notification in
                                    NotificationItemView(notification: notification, userService: userService, tappedItem: $viewModel.selectedNotification) {
                                        Task {
                                            await viewModel.deleteNotification()
                                        }
//                                        withAnimation {
//                                            
//                                        }
                                    }
                                }
                            }
                        }
                    }
                }
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
        .background(viewModel.selectedNotification != nil ? .black.opacity(0.6) : .clear)
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

}

struct NotificationItemView: View {
    var notification: NotificationModel
    var userService: UserSupabaseService
    @Binding var tappedItem: NotificationModel?
    var onDelete: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                notification.getIcon(userService: userService)
                    .overlay {
                        if let item = tappedItem, item.id != notification.id {
                            Color.black.opacity(0.6)
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                        }
                    }
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
                .overlay {
                    if let item = tappedItem, item.id != notification.id {
                        Color.black.opacity(0.6)
                            .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
                            .cornerRadius(4, corners: [.bottomLeft])
                    }
                }
                .onTapGesture {
                    if let item = tappedItem, item.id != notification.id {
                        withAnimation {
                            tappedItem = nil
                        }
                    }
                }
                .onLongPressGesture {
                    withAnimation {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            
            if let tappedItem, notification.id == tappedItem.id {
                HStack {
                    Button(action: onDelete, label: {
                        Text("delete_button".localized)
                            .font(.montserratBoldFont(size: 16))
                            .foregroundStyle(.red)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(.white)
                            .cornerRadius(14)
                            .shadow(color: .white, radius: 4)
                    })
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
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



struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationItemView(notification: NotificationModel(id: UUID(), userId: UUID(), title: "Hello", description: "some description...", createdAt: Date(), isNotified: false, author: nil), userService: UserSupabaseService(), tappedItem: .constant(nil), onDelete: {})
//        NotificationsView()
//            .environmentObject(NotificationsViewModel(mainViewModel: MainViewModel()))
//            .environmentObject(HomeViewModel(mainViewModel: MainViewModel()))
    }
}
