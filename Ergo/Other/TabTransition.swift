//
//  TabTransition.swift
//  Ergo
//
//  Created by Adon Omeri on 8/11/2026.
//

import SwiftUI

extension UIViewController {
	/// The `UITabBarController` that SwiftUI's `TabView` sits on.
	func hostingTabBarController() -> UITabBarController? {
		tabBarController ?? Self.tabBarController(in: view.window?.rootViewController)
	}

	private static func tabBarController(in controller: UIViewController?) -> UITabBarController? {
		guard let controller else {
			return nil
		}

		if let tabBarController = controller as? UITabBarController {
			return tabBarController
		}

		for child in controller.children {
			if let found = tabBarController(in: child) {
				return found
			}
		}

		return tabBarController(in: controller.presentedViewController)
	}
}

/// Changing tab blurs and fades one tab into the other instead of cutting, and tapping the selected tab again is reported. SwiftUI's `TabView` has no way to animate that, so this gives its tab bar controller an animator, through a delegate that hands everything else to the delegate SwiftUI had already set.
private struct TabTransition: UIViewControllerRepresentable {
	let onReselect: () -> Void

	func makeUIViewController(context _: Context) -> Finder {
		Finder()
	}

	func updateUIViewController(_ finder: Finder, context _: Context) {
		finder.proxy.onReselect = onReselect
		finder.install()
	}

	final class Finder: UIViewController {
		let proxy = TabTransitionDelegate()
		private weak var host: UITabBarController?

		override func viewDidAppear(_ animated: Bool) {
			super.viewDidAppear(animated)
			install()
		}

		/// SwiftUI may set its own delegate again, so this is safe to repeat.
		func install() {
			guard let host = hostingTabBarController(), host.delegate !== proxy else {
				return
			}

			proxy.forwardee = host.delegate
			host.delegate = proxy
			self.host = host
		}

		deinit {
			MainActor.assumeIsolated {
				if host?.delegate === proxy {
					host?.delegate = proxy.forwardee
				}
			}
		}
	}
}

private final nonisolated class TabTransitionDelegate: NSObject, UITabBarControllerDelegate {
	weak var forwardee: any UITabBarControllerDelegate?
	var onReselect: () -> Void = {}

	/// UIKit asks this for every tap on a tab, including the one that's already selected, which SwiftUI's `TabView` never reports.
	func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
		if tab.identifier == tabBarController.selectedTab?.identifier {
			onReselect()
		}

		return forwardee?.tabBarController?(tabBarController, shouldSelectTab: tab) ?? true
	}

	func tabBarController(_: UITabBarController, animationControllerForTransitionFrom _: UIViewController, to _: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
		TabBlurAnimator()
	}

	override func responds(to aSelector: Selector!) -> Bool {
		super.responds(to: aSelector) || forwardee?.responds(to: aSelector) == true
	}

	override func forwardingTarget(for aSelector: Selector!) -> Any? {
		forwardee?.responds(to: aSelector) == true ? forwardee : nil
	}
}

/// Blurs, fades and shrinks the old tab away over the new one. The tab bar isn't in the transition's container, so it stays sharp.
private final class TabBlurAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	private static let duration: TimeInterval = 0.2
	private static let radius: CGFloat = 16
	private static let scale: CGFloat = 0.95

	func transitionDuration(using _: any UIViewControllerContextTransitioning?) -> TimeInterval {
		Self.duration
	}

	func animateTransition(using context: any UIViewControllerContextTransitioning) {
		guard let from = context.view(forKey: .from), let to = context.view(forKey: .to) else {
			context.completeTransition(false)
			return
		}

		if let controller = context.viewController(forKey: .to) {
			to.frame = context.finalFrame(for: controller)
		}

		// UIKit won't take another tab tap until this transition completes, so it completes now. The old tab lives on as a snapshot that fades out over the new one, so the animation still plays while taps go through.
		let outgoing = from.snapshotView(afterScreenUpdates: false)

		context.containerView.addSubview(to)
		to.alpha = 0

		// The blur is SwiftUI's, so the snapshot goes in a hosting view that only lasts as long as the transition
		var leaving: UIHostingController<LeavingTab>?
		if let outgoing {
			let hosted = UIHostingController(rootView: LeavingTab(
				snapshot: outgoing,
				duration: Self.duration,
				radius: unsafe UIAccessibility.isReduceMotionEnabled ? 0 : Self.radius,
				scale: Self.scale
			))
			hosted.view.frame = from.frame
			hosted.view.backgroundColor = .clear
			hosted.view.isUserInteractionEnabled = false
			hosted.safeAreaRegions = []
			context.containerView.addSubview(hosted.view)
			leaving = hosted
		}

		context.completeTransition(true)

		UIView.animate(withDuration: Self.duration, delay: 0, options: .curveEaseInOut) {
			to.alpha = 1
		} completion: { _ in
			leaving?.view.removeFromSuperview()
		}
	}
}

/// The old tab's snapshot, blurring and fading away as soon as it's shown
private struct LeavingTab: View {
	let snapshot: UIView
	let duration: TimeInterval
	let radius: CGFloat
	let scale: CGFloat

	@State private var isLeaving = false

	var body: some View {
		Snapshot(view: snapshot)
			.blur(radius: isLeaving ? radius : 0)
			.scaleEffect(isLeaving ? scale : 1)
			.opacity(isLeaving ? 0 : 1)
			.onAppear {
				withAnimation(.easeInOut(duration: duration)) {
					isLeaving = true
				}
			}
	}

	private struct Snapshot: UIViewRepresentable {
		let view: UIView

		func makeUIView(context _: Context) -> UIView {
			view
		}

		func updateUIView(_: UIView, context _: Context) {}
	}
}

extension View {
	/// `onReselect` runs when the tab that's already selected is tapped.
	func tabTransition(onReselect: @escaping () -> Void) -> some View {
		background { TabTransition(onReselect: onReselect) }
	}
}
