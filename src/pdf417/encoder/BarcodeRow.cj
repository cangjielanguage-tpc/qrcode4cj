/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.encoder

import std.time.*

open class BarcodeRow {
    private let row: Array<UInt8>

    //A tacker for position in the bar
    private var currentLocation: Int64

    /**
     * Creates a Barcode row of the width
     */
    init(width: Int64) {
        this.row = Array<UInt8>(width, repeat: 0)
        currentLocation = 0
    }

    /**
     * Sets a specific location in the bar
     *
     * @param x The location in the bar
     * @param value Black if true, white if false
     */
    func set(x: Int64, value: UInt8) {
        row[x] = value
    }

    /**
     * Sets a specific location in the bar
     *
     * @param x The location in the bar
     * @param black Black if true, white if false
     */
    private func set(x: Int64, black: Bool) {
        if (black) {
            row[x] = 1
        } else {
            row[x] = 0
        }
    }

    /**
     * @param black A boolean which is true if the bar black false if it is white
     * @param width How many spots wide the bar is.
     */
    func addBar(black: Bool, width: Int64) {
        for (ii in 0..width) {
            set(currentLocation, black)
            currentLocation = currentLocation + 1
        }
    }

    /**
     * This function scales the row
     *
     * @param scale How much you want the image to be scaled, must be greater than or equal to 1.
     * @return the scaled row
     */
    func getScaledRow(scale: Int64): Array<UInt8> {
        var output: Array<UInt8> = Array<UInt8>(row.size * scale, repeat: 0)
        for (i in 0..output.size) {
            output[i] = row[i / scale]
        }
        return output
    }
}
