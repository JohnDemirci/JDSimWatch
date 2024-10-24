//
//  InstalledApplicationViewModel.swift
//  JDSimWatch
//
//  Created by John Demirci on 9/9/24.
//

import Foundation
import SwiftUI

@Observable
final class InstalledApplicationsViewModel {
	var installedApplications: [String: AppInfo] = [:]

	func fetchInstalledApplications(_ simulatorID: String) {
		let shell = EnvironmentValues().shell

		let result = shell.execute(command: .installedApps(simulatorID))

		switch result {
		case .success(let output):
			self.installedApplications = parseAppInfo(from: output)
		case .failure(let error):
			dump(error.localizedDescription)
		}
	}
}

extension InstalledApplicationsViewModel {
	struct AppInfo: Codable {
		let applicationType: String
		let bundle: String?
		let bundleContainer: String?
		let cfBundleDisplayName: String?
		let cfBundleExecutable: String?
		let cfBundleIdentifier: String
		let cfBundleName: String?
		let cfBundleVersion: String?
		let dataContainer: String?
		let groupContainers: [String: String]?
		let path: String?
		let sbAppTags: [String]?
	}

	func parseAppInfo(from input: String) -> [String: AppInfo] {
		var appInfoDict: [String: AppInfo] = [:]
		let lines = input.components(separatedBy: .newlines)
		var currentApp: String?
		var currentAppInfo: [String: Any] = [:]
		var inGroupContainers = false
		var groupContainers: [String: String] = [:]

		for line in lines {
			let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

			if trimmedLine.hasSuffix(" = {") {
				if let app = trimmedLine.components(separatedBy: " = ").first?.trimmingCharacters(in: .whitespaces) {
					currentApp = app.replacingOccurrences(of: "\"", with: "")
					currentAppInfo = [:]
					groupContainers = [:]
					inGroupContainers = false
				}
			} else if trimmedLine == "};" {
				if let app = currentApp {
					let appInfo = AppInfo(
						applicationType: currentAppInfo["ApplicationType"] as? String ?? "",
						bundle: currentAppInfo["Bundle"] as? String,
						bundleContainer: currentAppInfo["BundleContainer"] as? String,
						cfBundleDisplayName: currentAppInfo["CFBundleDisplayName"] as? String,
						cfBundleExecutable: currentAppInfo["CFBundleExecutable"] as? String,
						cfBundleIdentifier: currentAppInfo["CFBundleIdentifier"] as? String ?? "",
						cfBundleName: currentAppInfo["CFBundleName"] as? String,
						cfBundleVersion: currentAppInfo["CFBundleVersion"] as? String,
						dataContainer: currentAppInfo["DataContainer"] as? String,
						groupContainers: groupContainers,
						path: currentAppInfo["Path"] as? String,
						sbAppTags: currentAppInfo["SBAppTags"] as? [String]
					)
					appInfoDict[app] = appInfo
				}
				currentApp = nil
				currentAppInfo = [:]
				inGroupContainers = false
			} else if trimmedLine == "GroupContainers = {" {
				inGroupContainers = true
			} else if inGroupContainers && trimmedLine == "};" {
				inGroupContainers = false
			} else if inGroupContainers {
				let components = trimmedLine.components(separatedBy: " = ")
				if components.count == 2 {
					let key = components[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
					let value = components[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ";", with: "")
					groupContainers[key] = value
				}
			} else if let app = currentApp {
				let components = trimmedLine.components(separatedBy: " = ")
				if components.count == 2 {
					let key = components[0].trimmingCharacters(in: .whitespaces)
					var value = components[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ";", with: "")
					if value.hasPrefix("(") && value.hasSuffix(")") {
						value = value.dropFirst().dropLast().description
						currentAppInfo[key] = value.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
					} else {
						currentAppInfo[key] = value
					}
				}
			}
		}

		return appInfoDict
	}
}
