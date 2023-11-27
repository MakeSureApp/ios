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
    
    var body: some View {
        VStack {
            HStack {
                BackButtonView(color: .black) {
                    withAnimation {
                        homeViewModel.showNotificationsView.toggle()
                    }
                }
                .padding(.leading, 16)
                Spacer()
            }
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
                                            .padding(.top, 12)
                            ) {
                                ForEach(notifications) { notification in
                                    NotificationItemView(notification: notification)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("There are no notifications")
            }
        }
        .background(.white)
        .onAppear {
            Task {
                await viewModel.fetchNotifications()
            }
        }
    }

}

 struct NotificationItemView: View {
    var notification: NotificationModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notification.title)
                .font(.headline)
            Text(notification.description ?? "")
                .font(.subheadline)
            HStack {
                Spacer()
                Text(getTime(notification.createdAt))
                    .font(.caption)
            }
        }
        .padding()
        .background(.gray.opacity(0.7))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    func getTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(NotificationsViewModel(mainViewModel: MainViewModel()))
            .environmentObject(HomeViewModel(mainViewModel: MainViewModel()))
    }
}
