package zxing.code.multi

from std import collection.*

/**
 * Implementation of this interface attempt to read several barcodes from one image.
 *
 * @see com.google.zxing.Reader
 * @author Sean Owen
 */
public interface MultipleBarcodeReader {
    func decodeMultiple(image: BinaryBitmap): Array<Result>

    func decodeMultiple(
        image: BinaryBitmap,
        hints: HashMap<DecodeHintType, Any>
    ): Array<Result>
}
