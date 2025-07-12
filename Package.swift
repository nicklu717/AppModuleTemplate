// swift-tools-version:5.7

enum AppModule {
    case `internal`(Internal)
    case external(External)
    
    enum Internal: CaseIterable {}
    enum External: CaseIterable {}
}

extension AppModule.Internal {
    var name: String {
        switch self {}
    }
    
    var dependencies: [AppModule] {
        switch self {}
    }
    
    var path: String {
        switch self {}
    }
    
    var hasResources: Bool {
        switch self {}
    }
    
    var hasTests: Bool {
        switch self {}
    }
}

extension AppModule.External {
    var name: String {
        switch self {}
    }
    
    var packageInfo: (name: String, url: String, tag: String) {
        switch self {}
    }
}

import PackageDescription

extension AppModule.Internal {
    var product: Product {
        .library(name: name, targets: [name])
    }
    
    var target: Target {
        let dependencies: [Target.Dependency] = dependencies.map { dependency in
            switch dependency {
            case .internal(let internalModule):
                return .byName(name: internalModule.name)
            case .external(let externalModule):
                return externalModule.productDependency
            }
        }
        let resources: [Resource]? = hasResources ? [.process("Resources")] : nil
        
        return .target(name: name, dependencies: dependencies, path: "Sources/\(path)", resources: resources)
    }
    
    var testTarget: Target? {
        if hasTests {
            return .testTarget(name: "\(name)Tests", dependencies: [.byName(name: name)], path: "Tests/\(path)")
        } else {
            return nil
        }
    }
}

extension AppModule.External {
    var packageDependency: Package.Dependency {
        .package(url: packageInfo.url, exact: Version(stringLiteral: packageInfo.tag))
    }
    
    var productDependency: Target.Dependency {
        .product(name: name, package: packageInfo.name)
    }
}

let internalModules = AppModule.Internal.allCases
let externalModules = AppModule.External.allCases
let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v16),
    ],
    products: internalModules.map(\.product),
    dependencies: externalModules.map(\.packageDependency),
    targets: internalModules.map(\.target) + internalModules.compactMap(\.testTarget)
)
