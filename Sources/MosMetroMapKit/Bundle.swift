//
//  File.swift
//  
//
//  Created by Кузин Павел on 20.08.2021.
//

import class Foundation.Bundle

private class BundleFinder {}

public extension Bundle {
    
    static var mm_Map : Bundle = {
 
        let bundleName = "MosMetroMapKit_MosMetroMapKit"
        let candidates = [
            Bundle.main.bundleURL,
            Bundle.main.resourceURL,
            Bundle(for: BundleFinder.self).resourceURL,
            Bundle(for: BundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
        ]
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("🚧🚧🚧🚧🚧 Unable to find \(bundleName) bundle")
    }()
}
