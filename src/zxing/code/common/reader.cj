/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.common

public interface Reader {
    /**
     * Locates and decodes a barcode in some format within an image.
     *
     * @param image image of barcode to decode
     * @return String which the barcode encodes
     * @throws NotFoundException if no potential barcode is found
     * @throws ChecksumException if a potential barcode is found but does not pass its checksum
     * @throws FormatException if a potential barcode is found but format is invalid
     */
    func decode(image: BinaryBitmap): Result

    /**
     * Locates and decodes a barcode in some format within an image. This method also accepts
     * hints, each possibly associated to some data, which may help the implementation decode.
     *
     * @param image image of barcode to decode
     * @param hints passed as a {@link Map} from {@link DecodeHintType}
     * to arbitrary data. The
     * meaning of the data depends upon the hint type. The implementation may or may not do
     * anything with these hints.
     * @return String which the barcode encodes
     * @throws NotFoundException if no potential barcode is found
     * @throws ChecksumException if a potential barcode is found but does not pass its checksum
     * @throws FormatException if a potential barcode is found but format is invalid
     */
    func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result

    /**
     * Resets any internal state the implementation has after a decode, to prepare it
     * for reuse.
     */
    func reset(): Unit
}
