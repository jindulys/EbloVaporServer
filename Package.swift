import PackageDescription

let package = Package(
    name: "EbloVaporServer",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "git@github.com:jindulys/SiYuanKit.git", majorVersion:1),
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2),
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

