/*
 * Copyright 2011 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.pdf417.encoder

from std import time.*

/**
 * @author Jacob Haynes
 */
open class BarcodeRow {
    private let row: Array<UInt8>

    //A tacker for position in the bar
    private var currentLocation: Int64

    /**
     * Creates a Barcode row of the width
     */
    init(width: Int64) {
        this.row = Array<UInt8>(width, item: 0)
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
        var output: Array<UInt8> = Array<UInt8>(row.size * scale, item: 0)
        for (i in 0..output.size) {
            output[i] = row[i / scale]
        }
        return output
    }
}
