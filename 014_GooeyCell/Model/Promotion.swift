//
//  Promotion.swift
//  014_GooeyCell
//
//  Created by nikita on 21.11.2022.
//

import Foundation

struct Promotion: Identifiable {
	
	var id: String = UUID().uuidString
	var name: String
	var title: String
	var subtitle: String
	var logo: String
	
}

var placeholderText = "Lorem ipsum sir dolor amet and more text here to fit in two lines"
