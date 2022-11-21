//
//  Home.swift
//  014_GooeyCell
//
//  Created by nikita on 21.11.2022.
//

import SwiftUI

struct Home: View {
	
	@State var promotions: [Promotion] = [
		.init(name: "Trip Advisor", title: "Your saved search to Vienna", subtitle: placeholderText, logo: "doc.richtext"),
		.init(name: "Figma", title: "Figma @mentions are here", subtitle: placeholderText, logo: "doc.richtext"),
		.init(name: "Product Hunt Daily", title: "Must-have Chrome extensions", subtitle: placeholderText, logo: "doc.richtext"),
		.init(name: "Invision", title: "First interview with designer I admire", subtitle: placeholderText, logo: "doc.richtext"),
		.init(name: "Pinterest", title: "You've got 18 new ideas waiting for you", subtitle: placeholderText, logo: "doc.richtext")
	]
	
    var body: some View {
		ScrollView(.vertical, showsIndicators: false) { 
			VStack(spacing: 12) {
				HeaderView()
					.padding(15)
				
				ForEach(promotions) { promotion in
					GooeyCell(promotion: promotion) {
						let _ = withAnimation(.easeInOut(duration: 0.3)) {
							promotions.remove(at: indexOf(promotion: promotion))
						}
					}
				}
			}
			.padding(.vertical, 15)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background {
			Color("BG")
				.ignoresSafeArea()
		}
    }
	
	func indexOf(promotion: Promotion) -> Int {
		if let index = promotions.firstIndex(where: {
			$0.id == promotion.id
		}) {
			return index
		} 
		
		return 0 
	}
	
	@ViewBuilder
	func HeaderView() -> some View {
		HStack {
			Text("Promotions")
				.font(.system(size: 38))
				.fontWeight(.medium)
				.foregroundColor(Color("Green"))
				.frame(maxWidth: .infinity, alignment: .leading)
			
			Button { 
				
			} label: { 
				Image(systemName: "magnifyingglass")
					.font(.title2)
					.foregroundColor(Color("Green"))
			}

		}	
	}
	
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GooeyCell: View {
	
	var promotion: Promotion
	var icon: String = "xmark"
	var onDelete: ()->Void
	
	@State var offsetX: CGFloat = 0
	@State var cardOffset: CGFloat = 0
	@State var finishAnimation: Bool = false
	
	var body: some View {
		let cardWidth = screenSize().width - 35
		let progress = (-offsetX * 0.8) / screenSize().width
		
		ZStack(alignment: .trailing) {
			CanvasView()
			
			HStack {
				VStack(alignment: .leading, spacing: 12) { 
					HStack {
						Image(systemName: promotion.logo)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 22, height: 22)
						
						Text(promotion.name)
							.font(.callout)
							.fontWeight(.semibold)
					}
					
					Text(promotion.title)
						.foregroundColor(.black.opacity(0.8))
					
					Text(promotion.subtitle)
						.font(.caption)
						.foregroundColor(.gray)
				}
				.lineLimit(1)
				.padding(.vertical, 8)
				
				Text("29 OCT")
					.font(.callout)
					.fontWeight(.semibold)
					.foregroundColor(Color("Green").opacity(0.7))
			}
			.padding(.horizontal, 15)
			.padding(.vertical, 10)
			.background {
				RoundedRectangle(cornerRadius: 10, style: .continuous)
					.fill(.white.opacity(0.7))
			}
			.opacity(1.0 - progress)
			.blur(radius: progress * 5.0)
			.padding(.horizontal, 15)
			.contentShape(Rectangle())
			.offset(x: cardOffset)
			.gesture(
				DragGesture()
					.onChanged({ value in
						var translation = value.translation.width
						translation = (translation > 0 ? 0 : translation)
						translation = (-translation < cardWidth ? translation : -cardWidth)
						
						offsetX = translation
						cardOffset = offsetX
					})
					.onEnded({ value in
						if -value.translation.width > (screenSize().width * 0.6) {
							UIImpactFeedbackGenerator(style: .medium)
								.impactOccurred()
							finishAnimation = true
							
							withAnimation(.easeInOut(duration: 0.3)) {
								cardOffset = -screenSize().width
							}
							
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
								onDelete()
							}
						} else {
							withAnimation(.easeOut(duration: 0.3)) {
								offsetX = .zero
								cardOffset = .zero
							}	
						}
					})
			)
		}
	}
	
	@ViewBuilder
	func CanvasView() -> some View {
		let width = (screenSize().width * 0.8)
		let circleOffset = (offsetX / width)
		
		Canvas { ctx, size in 
			ctx.addFilter(.alphaThreshold(min: 0.5, color: Color("Green")))
			ctx.addFilter(.blur(radius: 5))
			
			ctx.drawLayer { layer in
				if let resolvedView = ctx.resolveSymbol(id: 1) {
					layer.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
				}
			}
		} symbols: {
			GooeyView()
				.tag(1)
		}
		.overlay(alignment: .trailing) { 
			Image(systemName: icon)
				.fontWeight(.semibold)
				.foregroundColor(.white)
				.frame(width: 42, height: 42)
				.offset(x: 42)
				.offset(x: (-circleOffset < 1.0 ? circleOffset : -1.0) * 42)
				.offset(x: offsetX * 0.2)
				.offset(x: 8)
				.offset(x: finishAnimation ? -200 : 0)
				.opacity(finishAnimation ? 0 : 1)
				.animation(.interactiveSpring(response: 0.6, dampingFraction: 1, blendDuration: 1), value: finishAnimation)
		}
	}
	
	@ViewBuilder
	func GooeyView() -> some View {
		let width = (screenSize().width * 0.8)
		let scale = finishAnimation ? -0.0001 : offsetX / width
		let circleOffset = (offsetX / width)
		
		Image("Shape")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(height: 100)
			.scaleEffect(x: -scale, anchor: .trailing)
			.animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: finishAnimation)
			.overlay(alignment: .trailing, content: { 
				Circle()
					.frame(width: 42, height: 42)	
					.offset(x: 42)
					.scaleEffect(finishAnimation ? 0.001 : 1, anchor: .leading)
					.offset(x: (-circleOffset < 1.0 ? circleOffset : -1.0) * 42)
					.offset(x: offsetX * 0.2)
					.offset(x: finishAnimation ? -200 : 0)
					.animation(.interactiveSpring(response: 0.6, dampingFraction: 1, blendDuration: 1), value: finishAnimation)
			})
			.frame(maxWidth: .infinity, alignment: .trailing)
			.offset(x: 8)
				
	}
	
}

extension View {
	
	func screenSize() -> CGSize {
		guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
			return .zero
		} 
		
		return window.screen.bounds.size
	}
	
}
