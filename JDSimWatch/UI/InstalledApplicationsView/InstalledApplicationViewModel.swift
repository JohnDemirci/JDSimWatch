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
    var installedApplications: [AppInfo] = []

	func fetchInstalledApplications(_ simulatorID: String) {
		let shell = EnvironmentValues().shell

		let result = shell.execute(.installedApps(simulatorID))

		switch result {
		case .success(let output):
            guard let output else { return }
            self.installedApplications = parseAppInfo(from: output)
		case .failure(let error):
			dump(error.localizedDescription)
		}
	}
}

extension InstalledApplicationsViewModel {
    struct AppInfo: Hashable {
        var applicationType: String?
        var bundle: String?
        var displayName: String?
        var bundleIdentifier: String?
        var bundleName: String?
        var bundleVersion: String?
        var dataContainer: String?
        var path: String?
    }


    func parseAppInfo(from input: String) -> [AppInfo] {
        let newArray = input.components(separatedBy: "\n        ")
        var appInfos: [AppInfo] = []

        for var index in 0..<newArray.count {
            let xxx = newArray[index]
            if xxx.localizedStandardContains("ApplicationType") {
                var appInfo = AppInfo()

                appInfo.bundleIdentifier = newArray[index - 1]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ";", with: "")
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "{", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "}", with: "")
                    .replacingOccurrences(of: "\t", with: "")
                    .replacingOccurrences(of: "=", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                    .replacingOccurrences(of: ")", with: "")

                let str = newArray[index]

                let seperatedArr = str.split(separator: "=")
                let applicationType = seperatedArr.last?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ";", with: "")
                    .replacingOccurrences(of: "\"", with: "")

                appInfo.applicationType = applicationType

                for innerIndex in index + 1..<newArray.count {
                    if newArray[innerIndex].localizedStandardContains("ApplicationType") ||
                       innerIndex == newArray.count - 1
                    {
                        index = innerIndex - 1
                        appInfos.append(appInfo)
                        break
                    } else {
                        let work = newArray[innerIndex]
                        let split = work.split(separator: "=")

                        let initialBundle = split.first?.trimmingCharacters(in: .whitespaces)

                        if initialBundle == "Bundle" {
                            let bundle = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")

                            appInfo.bundle = bundle
                        } else if work.localizedStandardContains("CFBundleDisplayName") {
                            let displayName = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")

                            appInfo.displayName = displayName
                        } else if work.localizedStandardContains("CFBundleName") {
                            let bundleName = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")

                            appInfo.bundleName = bundleName
                        } else if work.localizedStandardContains("CFBundleIdentifier") {
                            let bundleIdentifier = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")

                            appInfo.bundleIdentifier = bundleIdentifier
                        } else if work.localizedStandardContains("CFBundleVersion") {
                            let bundleVersion = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")

                            appInfo.bundleVersion = bundleVersion
                        } else if work.localizedStandardContains("DataContainer") {
                            let dataContainer = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")
                                .replacingOccurrences(of: "file://", with: "")

                            dump(dataContainer)

                            appInfo.dataContainer = dataContainer
                        } else if work.localizedStandardContains("Path") {
                            let path = split.last?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ";", with: "")
                                .replacingOccurrences(of: "\"", with: "")

                            appInfo.path = path
                        }
                    }
                }
            } else {
                continue
            }
        }

        return appInfos
	}
}
