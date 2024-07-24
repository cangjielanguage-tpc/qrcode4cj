/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

public class BinaryBitmap {
    private let binarizer: Binarizer
    private var matrix: BitMatrix = BitMatrix()

    public init(binarizer: Binarizer) {
        if (binarizer.flag == false) {
            throw IllegalArgumentException("Binarizer must be non-null.")
        }
        this.binarizer = binarizer
    }

    /**
     * @return The width of the bitmap.
     */
    public func getWidth(): Int64 {
        return binarizer.getWidth()
    }

    /**
     * @return The height of the bitmap.
     */
    public func getHeight(): Int64 {
        return binarizer.getHeight()
    }

    /**
     * Converts one row of luminance data to 1 bit data. May actually do the conversion, or return
     * cached data. Callers should assume this method is expensive and call it as seldom as possible.
     * This method is intended for decoding 1D barcodes and may choose to apply sharpening.
     *
     * @param y The row to fetch, which must be in [0, bitmap height)
     * @param row An optional preallocated array. If null or too small, it will be ignored.
     * If used, the Binarizer will call BitArray.clear(). Always use the returned object.
     * @return The array of bits for this row (true means black).
     * @throws Qrcoder4cjNotFoundException if row can't be binarized
     */
    @OverflowThrowing
    public func getBlackRow(y: Int64, row: BitArray): BitArray {
        return binarizer.getBlackRow(y, row)
    }

    /**
     * Converts a 2D array of luminance data to 1 bit. As above, assume this method is expensive
     * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
     * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
     * fetched using getBlackRow(), so don't mix and match between them.
     *
     * @return The 2D array of bits for the image (true means black).
     * @throws Qrcoder4cjNotFoundException if image can't be binarized to make a matrix
     */
    @OverflowThrowing
    public func getBlackMatrix(): BitMatrix {
        // The matrix is created on demand the first time it is requested, then cached. There are two
        // reasons for this:
        // 1. This work will never be done if the caller only installs 1D Reader objects, or if a
        //    1D Reader finds a barcode before the 2D Readers run.
        // 2. This work will only be done once even if the caller installs multiple 2D Readers.
        if (matrix.flag == false) {
            matrix = binarizer.getBlackMatrix()
        }

        return matrix
    }

    /**
     * @return Whether this bitmap can be cropped.
     */
    public func isCropSupported(): Bool {
        return binarizer.getLuminanceSource().isCropSupported()
    }

    /**
     * Returns a new object with cropped image data. Implementations may keep a reference to the
     * original data rather than a copy. Only callable if isCropSupported() is true.
     *
     * @param left The left coordinate, which must be in [0,getWidth())
     * @param top The top coordinate, which must be in [0,getHeight())
     * @param width The width of the rectangle to crop.
     * @param height The height of the rectangle to crop.
     * @return A cropped version of this object.
     */
    public func crop(left: Int64, top: Int64, width: Int64, height: Int64): BinaryBitmap {
        var newSource: LuminanceSource = binarizer.getLuminanceSource().crop(left, top, width, height)
        return BinaryBitmap(binarizer.createBinarizer(newSource))
    }

    /**
     * @return Whether this bitmap supports counter-clockwise rotation.
     */
    public func isRotateSupported(): Bool {
        return binarizer.getLuminanceSource().isRotateSupported()
    }

    /**
     * Returns a new object with rotated image data by 90 degrees counterclockwise.
     * Only callable if {@link #isRotateSupported()} is true.
     *
     * @return A rotated version of this object.
     */
    public func rotateCounterClockwise(): BinaryBitmap {
        var newSource: LuminanceSource = binarizer.getLuminanceSource().rotateCounterClockwise()
        return BinaryBitmap(binarizer.createBinarizer(newSource))
    }

    /**
     * Returns a new object with rotated image data by 45 degrees counterclockwise.
     * Only callable if {@link #isRotateSupported()} is true.
     *
     * @return A rotated version of this object.
     */
    public func rotateCounterClockwise45(): BinaryBitmap {
        var newSource: LuminanceSource = binarizer.getLuminanceSource().rotateCounterClockwise45()
        return BinaryBitmap(binarizer.createBinarizer(newSource))
    }

    public func toString(): String {
        try {
            return getBlackMatrix().toString()
        } catch (e: NoneValueException) {
            return ""
        }
    }
}
