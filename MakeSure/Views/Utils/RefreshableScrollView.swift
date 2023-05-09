//
//  RefreshableScrollView.swift
//  MakeSure
//
//  Created by andreydem on 5/8/23.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let onRefresh: () async -> Void
    @Binding var isRefreshing: Bool

    init(onRefresh: @escaping () async -> Void, isRefreshing: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onRefresh = onRefresh
        self._isRefreshing = isRefreshing
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onRefresh: onRefresh, isRefreshing: $isRefreshing)
    }

    func makeUIViewController(context: Context) -> UIScrollViewHostingController<Content> {
        let hostingController = UIScrollViewHostingController(rootView: content, coordinator: context.coordinator)
        context.coordinator.hostingController = hostingController
        return hostingController
    }

    func updateUIViewController(_ uiViewController: UIScrollViewHostingController<Content>, context: Context) {}

    class Coordinator: NSObject, UIScrollViewDelegate {
        let onRefresh: () async -> Void
        var isRefreshing: Binding<Bool>
        weak var hostingController: UIScrollViewHostingController<Content>?

        init(onRefresh: @escaping () async -> Void, isRefreshing: Binding<Bool>) {
            self.onRefresh = onRefresh
            self.isRefreshing = isRefreshing
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let refreshThreshold: CGFloat = -50.0
            if offsetY < refreshThreshold, !isRefreshing.wrappedValue {
                isRefreshing.wrappedValue = true
                Task {
                    await onRefresh()
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isRefreshing.wrappedValue = false
                        }
                    }
                }
            }
        }
    }
}

final class UIScrollViewHostingController<Content: View>: UIHostingController<Content>, UIScrollViewDelegate {
    weak var coordinator: RefreshableScrollView<Content>.Coordinator?

    init(rootView: Content, coordinator: RefreshableScrollView<Content>.Coordinator) {
        self.coordinator = coordinator
        super.init(rootView: rootView)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.delegate = coordinator
        }
    }
}
