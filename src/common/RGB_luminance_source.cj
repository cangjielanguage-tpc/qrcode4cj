/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

public open class RGBLuminanceSource <: LuminanceSource {
    private var luminances: Array<UInt8>
    private var dataWidth: Int64
    private var dataHeight: Int64
    private var left: Int64
    private var top: Int64

    public init(width: Int64, height: Int64, pixels: Array<Int64>) {
        super(width, height)

        dataWidth = width
        dataHeight = height
        left = 0
        top = 0

        // In order to measure pure decoding speed, we convert the entire image to a greyscale array
        // up front, which is the same as the Y channel of the YUVLuminanceSource in the real app.
        //
        // Total number of pixels suffices, can ignore shape
        let size: Int64 = width * height
        luminances = Array<UInt8>(size, item: 0)
        for (offset in 0..size) {
            var pixel: Int64 = pixels[offset]
            let r: Int64 = (pixel >> 16) & 0xff

            // red
            let g2: Int64 = (pixel >> 7) & 0x1fe

            // 2 * green
            let b: Int64 = pixel & 0xff

            // blue
            // Calculate green-favouring average cheaply
            luminances[offset] = UInt8((r + g2 + b) / 4)
        }
    }

    private init(
        pixels: Array<UInt8>,
        dataWidth: Int64,
        dataHeight: Int64,
        left: Int64,
        top: Int64,
        width: Int64,
        height: Int64
    ) {
        super(width, height)
        if (left + width > dataWidth || top + height > dataHeight) {
            throw IllegalArgumentException("Crop rectangle does not fit within image data.")
        }
        this.luminances = pixels
        this.dataWidth = dataWidth
        this.dataHeight = dataHeight
        this.left = left
        this.top = top
    }

    public override func getRow(y: Int64, rowin: Array<UInt8>): Array<UInt8> {
        var row: Array<UInt8> = rowin
        if (y < 0 || y >= getHeight()) {
            throw IllegalArgumentException("Requested row is outside the image: " + y.toString())
        }
        let width: Int64 = getWidth()
        if (row.size == 0 || row.size < width) {
            row = Array<UInt8>(width, item: 0)
        }
        let offset: Int64 = (y + top) * dataWidth + left
        System.arraycopy(luminances, offset, row, 0, width)
        return row
    }

    public override func getMatrix(): Array<UInt8> {
        let width: Int64 = getWidth()
        let height: Int64 = getHeight()

        // If the caller asks for the entire underlying image, save the copy and give them the
        // original data. The docs specifically warn that result.length must be ignored.
        if (width == dataWidth && height == dataHeight) {
            return luminances
        }

        let area: Int64 = width * height
        var matrix: Array<UInt8> = Array<UInt8>(area, item: 0)
        var inputOffset: Int64 = top * dataWidth + left

        // If the width matches the full width of the underlying data, perform a single copy.
        if (width == dataWidth) {
            System.arraycopy(luminances, inputOffset, matrix, 0, area)

            return matrix
        }

        // Otherwise copy one cropped row at a time.
        for (y in 0..height) {
            let outputOffset: Int64 = y * width

            luminances.copyTo(matrix, inputOffset, outputOffset, width)
            inputOffset += dataWidth
        }
        return matrix
    }

    public override func isCropSupported(): Bool {
        return true
    }

    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource {
        return RGBLuminanceSource(
            luminances,
            dataWidth,
            dataHeight,
            this.left + left,
            this.top + top,
            width,
            height
        )
    }
}
