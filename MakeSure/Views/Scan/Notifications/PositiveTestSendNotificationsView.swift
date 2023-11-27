//
//  PositiveTestSendNotificationsView.swift
//  MakeSure
//
//  Created by Macbook Pro on 18.09.2023.
//

import SwiftUI

struct PositiveTestSendNotificationsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("no_anonymous_notifications_message".localized)
                .font(.rubicBoldFont(size: 32))
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct PositiveTestSendNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestSendNotificationsView()
    }
}
