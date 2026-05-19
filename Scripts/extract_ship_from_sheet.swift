#!/usr/bin/env swift
import AppKit
import Foundation

struct SheetSlice {
    let name: String
    let x: Int
    let width: Int
}

let projectRoot = URL(fileURLWithPath: CommandLine.arguments[1])
let sheetURL = projectRoot
    .appendingPathComponent("170ElarionPulseHub/Resources/ShipArt/spaceship_skins_sheet.png")
let assetsRoot = projectRoot.appendingPathComponent("170ElarionPulseHub/Assets.xcassets")

// Manual X ranges on 1536×1024 sheet (ships are unevenly spaced).
let slices: [SheetSlice] = [
    SheetSlice(name: "ShipSkinDefault", x: 0, width: 188),
    SheetSlice(name: "ShipSkinBlaze", x: 248, width: 248),
    SheetSlice(name: "ShipSkinNeon", x: 512, width: 248),
    SheetSlice(name: "ShipSkinPulse", x: 768, width: 248),
    SheetSlice(name: "ShipSkinRoyal", x: 1024, width: 248),
    SheetSlice(name: "ShipSkinAurora", x: 1280, width: 256)
]

let only = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil

guard let sheet = NSImage(contentsOf: sheetURL),
      let cgSheet = sheet.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fputs("Cannot load sheet\n", stderr)
    exit(1)
}

for slice in slices where only == nil || slice.name == only {
    let rect = CGRect(x: slice.x, y: 0, width: slice.width, height: cgSheet.height)
    guard let cropped = cgSheet.cropping(to: rect) else {
        fputs("Crop failed \(slice.name)\n", stderr)
        continue
    }
    let outURL = assetsRoot
        .appendingPathComponent("\(slice.name).imageset")
        .appendingPathComponent("\(slice.name)@2x.png")
    let rep = NSBitmapImageRep(cgImage: cropped)
    guard let png = rep.representation(using: .png, properties: [:]) else { continue }
    try png.write(to: outURL)
    print("OK \(slice.name) \(cropped.width)x\(cropped.height) x=\(slice.x)")
}
