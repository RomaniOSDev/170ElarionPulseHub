#!/usr/bin/env swift
import AppKit
import Foundation

let allAssetNames = [
    "ShipSkinDefault", "ShipSkinBlaze", "ShipSkinNeon",
    "ShipSkinPulse", "ShipSkinRoyal", "ShipSkinAurora"
]

let projectRoot = URL(fileURLWithPath: CommandLine.arguments[1])
let onlyName = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil
let assetNames = onlyName.map { [$0] } ?? allAssetNames
let assetsRoot = projectRoot
    .appendingPathComponent("170ElarionPulseHub/Assets.xcassets")

func isBackground(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) -> Bool {
    guard a > 12 else { return true }
    let luminance = Int(r) + Int(g) + Int(b)
    if luminance < 45 { return true }
    // Sheet navy / near-black backdrop
    if r < 55 && g < 55 && b < 90 { return true }
    if r < 35 && g < 45 && b < 80 { return true }
    return false
}

func processImage(at url: URL) throws {
    guard let source = NSImage(contentsOf: url),
          let cgImage = source.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw NSError(domain: "ship", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot load \(url.path)"])
    }

    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { throw NSError(domain: "ship", code: 2) }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    var minX = width, minY = height, maxX = 0, maxY = 0

    for y in 0..<height {
        for x in 0..<width {
            let i = y * bytesPerRow + x * bytesPerPixel
            let r = pixels[i], g = pixels[i + 1], b = pixels[i + 2], a = pixels[i + 3]
            if isBackground(r, g, b, a) {
                pixels[i + 3] = 0
            } else {
                pixels[i + 3] = 255
                // Un-premultiply-ish for cleaner edges
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }
    }

    guard minX < maxX, minY < maxY else { throw NSError(domain: "ship", code: 3) }

    let pad = 8
    minX = max(0, minX - pad)
    minY = max(0, minY - pad)
    maxX = min(width - 1, maxX + pad)
    maxY = min(height - 1, maxY + pad)
    let cropW = maxX - minX + 1
    let cropH = maxY - minY + 1

    guard let croppedContext = CGContext(
        data: nil,
        width: cropW,
        height: cropH,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerPixel * cropW,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "ship", code: 4)
    }

    croppedContext.draw(
        context.makeImage()!,
        in: CGRect(x: -minX, y: -minY, width: width, height: height)
    )

    guard let finalImage = croppedContext.makeImage() else {
        throw NSError(domain: "ship", code: 5)
    }

    let rep = NSBitmapImageRep(cgImage: finalImage)
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "ship", code: 6)
    }
    try png.write(to: url)
    print("OK \(url.lastPathComponent) -> \(cropW)x\(cropH)")
}

for name in assetNames {
    let path = assetsRoot
        .appendingPathComponent("\(name).imageset")
        .appendingPathComponent("\(name)@2x.png")
    try processImage(at: path)
}
