/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common

public open class PlanarYUVLuminanceSource <: LuminanceSource {
    private static let THUMBNAIL_SCALE_FACTOR: Int64 = 2

    private var yuvData: Array<UInt8>
    private var dataWidth: Int64
    private var dataHeight: Int64
    private var left: Int64
    private var top: Int64

    public init(
        yuvData: Array<UInt8>,
        dataWidth: Int64,
        dataHeight: Int64,
        left: Int64,
        top: Int64,
        width: Int64,
        height: Int64,
        reverseHorizontalBool: Bool
    ) {
        super(width, height)

        if (left + width > dataWidth || top + height > dataHeight) {
            throw IllegalArgumentException("Crop rectangle does not fit within image data.")
        }

        this.yuvData = yuvData
        this.dataWidth = dataWidth
        this.dataHeight = dataHeight
        this.left = left
        this.top = top
        if (reverseHorizontalBool) {
            var yuvData: Array<UInt8> = this.yuvData
            var rowStart = top * dataWidth + left
            for (y in 0..height) {
                let middle: Int64 = rowStart + width / 2
                var x2 = rowStart + width - 1
                for (x1 in rowStart..middle) {
                    let temp: UInt8 = yuvData[x1]
                    yuvData[x1] = yuvData[x2]
                    yuvData[x2] = temp
                    x2--
                }
                rowStart += dataWidth
            }
        }
    }

    public override func getRow(y: Int64, rowIn: Array<UInt8>): Array<UInt8> {
        if (y < 0 || y >= getHeight()) {
            throw IllegalArgumentException("Requested row is outside the image: " + y.toString())
        }
        let width: Int64 = getWidth()
        var row: Array<UInt8> = Array<UInt8>(width, item: 0)
        if (row.size == 0 || row.size < width) {
            row = Array<UInt8>(width, item: 0)
        }
        var offset: Int64 = (y + top) * dataWidth + left
        System.arraycopy(yuvData, offset, row, 0, width);

        return row
    }

    public override func getMatrix(): Array<UInt8> {
        let width: Int64 = getWidth()
        let height: Int64 = getHeight()

        // If the caller asks for the entire underlying image, save the copy and give them the
        // original data. The docs specifically warn that result.length must be ignored.
        if (width == dataWidth && height == dataHeight) {
            return yuvData
        }

        let area: Int64 = width * height
        var matrix: Array<UInt8> = Array<UInt8>(area, item: 0)
        var inputOffset: Int64 = top * dataWidth + left

        /* If the width matches the full width of the underlying data, perform a single copy. */
        if (width == dataWidth) {
            System.arraycopy(yuvData, inputOffset, matrix, 0, area)
            return matrix
        }

        /* Otherwise copy one cropped row at a time. */
        for (y in 0..height) {
            let outputOffset: Int64 = y * width
            System.arraycopy(yuvData, inputOffset, matrix, outputOffset, width)
            inputOffset += dataWidth
        }
        return matrix
    }

    public override func isCropSupported(): Bool {
        return true
    }

    public override func crop(
        left_: Int64,
        top_: Int64,
        width_: Int64,
        height_: Int64
    ): LuminanceSource {
        return PlanarYUVLuminanceSource(
            yuvData,
            dataWidth,
            dataHeight,
            this.left + left_,
            this.top + top_,
            width_,
            height_,
            false
        )
    }

    public func renderThumbnail(): Array<Int64> {
        let width: Int64 = getWidth() / THUMBNAIL_SCALE_FACTOR
        let height: Int64 = getHeight() / THUMBNAIL_SCALE_FACTOR
        var pixels: Array<Int64> = Array<Int64>(width * height, item: 0)
        var yuv: Array<UInt8> = yuvData
        var inputOffset: Int64 = top * dataWidth + left

        for (y in 0..height) {
            let outputOffset: Int64 = y * width
            for (x in 0..width) {
                let grey: Int64 = Int64(yuv[inputOffset + x * THUMBNAIL_SCALE_FACTOR]) & 0xff
                pixels[outputOffset + x] = 0xFF000000 | (grey * 0x00010101)
            }
            inputOffset += dataWidth * THUMBNAIL_SCALE_FACTOR
        }
        return pixels
    }

    /**
     * @return width of image from {@link #renderThumbnail()}
     */
    public func getThumbnailWidth(): Int64 {
        return getWidth() / THUMBNAIL_SCALE_FACTOR
    }

    /**
     * @return height of image from {@link #renderThumbnail()}
     */
    public func getThumbnailHeight(): Int64 {
        return getHeight() / THUMBNAIL_SCALE_FACTOR
    }
}
