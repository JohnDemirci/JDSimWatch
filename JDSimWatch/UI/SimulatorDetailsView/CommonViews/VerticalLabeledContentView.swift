//
//  VerticalLabeledContentView.swift
//  JDSimWatch
//
//  Created by John Demirci on 9/8/24.
//

import Foundation
import SwiftUI

struct VerticalLabeledContentView<Content: View, Description: View>: View {
	@ViewBuilder
	private var image: () -> Content

	@ViewBuilder
	private var text: () -> Description

	init(
		image: @escaping () -> Content,
		text: @escaping () -> Description
	) {
		self.image = image
		self.text = text
	}

	var body: some View {
		VStack {
			self.image()
				.frame(width: 55, height: 55)
			self.text()
		}
		.padding()
		.font(.largeTitle)
	}
}

extension VerticalLabeledContentView where Content == Image, Description == Text {
	init(systemImage: String, text: String) {
		self.image = {
			Image(systemName: systemImage)
				.resizable()
		}
		self.text = { Text(text) }
	}
}
