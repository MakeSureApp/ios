//
//  PositiveTestVisitDoctorView.swift
//  MakeSure
//
//  Created by Macbook Pro on 18.09.2023.
//

import SwiftUI

struct PositiveTestVisitDoctorView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("visit_doctor_message".localized)
                .font(.rubicBoldFont(size: 32))
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}

struct PositiveTestVisitDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveTestVisitDoctorView()
    }
}
