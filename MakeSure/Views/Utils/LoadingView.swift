//
//  LoadingView.swift
//  MakeSure
//
//  Created by andreydem on 5/3/23.
//

import Foundation
import SwiftUI

public struct RotatingShapesLoader: View {
    @Binding private var isAnimating: Bool
    public let color: Color
    public let content: AnyView
    private let count = 8

    public init<Content: View>(animate: Binding<Bool>, size: CGFloat = 8, color: Color = .white, content: () -> Content) {
        self._isAnimating = animate
        self.color = color
        self.content = AnyView(content().frame(width: size, height: size))
    }

    public init(animate: Binding<Bool>, color: Color = .white, size: CGFloat = 8) {
        self.init(animate: animate, color: color) {
            Circle().frame(width: size, height: size)
        }
    }

    private func animatingScale(forIndex index: Int) -> CGFloat { CGFloat(index+1)/CGFloat(count) }

    public var body: some View {
        GeometryReader { geometry in
            ForEach(0..<Int(count)) { index in
                item(forIndex: index, in: geometry.size)
                    .foregroundColor(color)
                    .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
                    .animation(
                        Animation
                            .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                            .repeatCount(isAnimating ? .max : 1, autoreverses: false)
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .aspectRatio(contentMode: .fit)
    }

    private func item(forIndex index: Int, in geometrySize: CGSize) -> some View {
        content
            .scaleEffect(isAnimating ? animatingScale(forIndex: index) : 0)
            .offset(y: geometrySize.width/10 - geometrySize.height/2)
    }
}

public struct RowOfShapesLoader: View {
    @Binding private var isAnimating: Bool
    public let color: Color
    public let count: UInt
    public let spacing: CGFloat
    public let content: AnyView
    public let scaleRange: ClosedRange<Double>
    public let opacityRange: ClosedRange<Double>
    public let itemSize: CGSize

    public init<Content: View>(animate: Binding<Bool>,
                               color: Color = .white,
                               count: UInt = 3,
                               spacing: CGFloat = 8,
                               scaleRange: ClosedRange<Double> = (0.75...1),
                               opacityRange: ClosedRange<Double> = (0.25...1),
                               itemSize: CGSize = CGSize(width: 10, height: 10),
                               content: () -> Content) {
        self._isAnimating = animate
        self.color = color
        self.count = count
        self.content = AnyView(content())
        self.spacing = spacing
        self.scaleRange = scaleRange
        self.opacityRange = opacityRange
        self.itemSize = itemSize
    }

    public init(animate: Binding<Bool>,
                color: Color = .white,
                count: UInt = 5,
                spacing: CGFloat = 8,
                scaleRange: ClosedRange<Double> = (0.75...1),
                opacityRange: ClosedRange<Double> = (0.25...1),
                itemSize: CGSize = CGSize(width: 10, height: 10)) {
        self.init(animate: animate, color: color, count: count, spacing: spacing,
                  scaleRange: scaleRange,
                  opacityRange: opacityRange,
                  itemSize: itemSize) {
            Circle()
        }
    }

    private func animatingScale(forIndex index: Int) -> CGFloat { CGFloat(index+1)/CGFloat(count) }

    public var body: some View {
        GeometryReader { geometry in
            ForEach(0..<Int(count)) { index in
                item(forIndex: index, in: geometry.size)
                    .foregroundColor(color)
            }
            .aspectRatio(contentMode: .fit)
        }
    }

    private func size(count: UInt, geometry: CGSize) -> CGFloat {
        (geometry.width/CGFloat(count)) - (spacing-2)
    }

    private var scale: CGFloat { CGFloat(isAnimating ? scaleRange.lowerBound : scaleRange.upperBound) }
    private var opacity: Double { isAnimating ? opacityRange.lowerBound : opacityRange.upperBound }

    private func item(forIndex index: Int, in geometrySize: CGSize) -> some View {
        content
            .frame(width: itemSize.width, height: itemSize.height)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(
                Animation
                    .default
                    .repeatCount(isAnimating ? .max : 1, autoreverses: true)
                    .delay(Double(index) / Double(count) / 2)
            )
            .offset(x: CGFloat(index) * (itemSize.width + spacing))
    }
}

