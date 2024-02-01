/*
 * Copyright 2007 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
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

package zxing.code.common

/**
 * <p>Encapsulates the result of decoding a barcode within an image.</p>
 *
 * @author Sean Owen
 */
public class Result {
    private var text: String = String();
    private var rawBytes: Array<UInt8> = Array<UInt8>();
    private var numBits: Int64 = 0;
    private var resultPoints: Array<ResultPoint> = Array<ResultPoint>();
    private var format: BarcodeFormat = UPC_EAN_EXTENSION
    private var resultMetadata: HashMap<ResultMetadataType, Any> = HashMap<ResultMetadataType, Any>();
    private var timestamp: Int64 = 0;
    public var flag: Bool = false
    public init() {}
    public init(
        text: String,
        rawBytes: Array<UInt8>,
        resultPoints: Array<ResultPoint>,
        format: BarcodeFormat
    ) {
        if (rawBytes.isEmpty()) {
            this.numBits = 0
        } else {
            this.numBits = 8 * rawBytes.size
        }
        this.text = text
        this.rawBytes = rawBytes
        this.numBits = numBits
        this.resultPoints = resultPoints
        this.format = format
        this.resultMetadata = HashMap<ResultMetadataType, Any>()
        this.timestamp = System.currentTimeMillis()
        this.flag = true
    }

    public init(
        text: String,
        rawBytes: Array<UInt8>,
        resultPoints: Array<ResultPoint>,
        format: BarcodeFormat,
        timestamp: Int64
    ) {
        var numBitsIn: Int64
        if (rawBytes.isEmpty()) {
            numBitsIn = 0
        } else {
            numBitsIn = 8 * rawBytes.size
        }
        this.text = text
        this.rawBytes = rawBytes
        this.numBits = numBits
        this.resultPoints = resultPoints
        this.format = format
        this.resultMetadata = HashMap<ResultMetadataType, Any>()
        this.timestamp = timestamp
        this.flag = true
    }

    public init(
        text: String,
        rawBytes: Array<UInt8>,
        numBits: Int64,
        resultPoints: Array<ResultPoint>,
        format: BarcodeFormat,
        timestamp: Int64
    ) {
        this.text = text
        this.rawBytes = rawBytes
        this.numBits = numBits
        this.resultPoints = resultPoints
        this.format = format
        this.resultMetadata = HashMap<ResultMetadataType, Any>()
        this.timestamp = timestamp
        this.flag = true
    }

    /**
     * @return raw text encoded by the barcode
     */
    public func getText(): String {
        return text
    }

    /**
     * @return raw bytes encoded by the barcode, if applicable, otherwise {@code null}
     */
    public func getRawBytes(): Array<UInt8> {
        return rawBytes
    }

    /**
     * @return how many bits of {@link #getRawBytes()} are valid; typically 8 times its length
     * @since 3.3.0
     */
    public func getNumBits(): Int64 {
        return numBits
    }

    /**
     * @return points related to the barcode in the image. These are typically points
     * identifying finder patterns or the corners of the barcode. The exact meaning is
     * specific to the type of barcode that was decoded.
     */
    public func getResultPoints(): Array<ResultPoint> {
        return resultPoints
    }

    /**
     * @return {@link BarcodeFormat} representing the format of the barcode that was decoded
     */
    public func getBarcodeFormat(): BarcodeFormat {
        return format
    }

    /**
     * @return {@link Map} mapping {@link ResultMetadataType} keys to values. May be
     * {@code null}. This contains optional metadata about what was detected about the barcode,
     * like orientation.
     */
    public func getResultMetadata(): HashMap<ResultMetadataType, Any> {
        return resultMetadata
    }

    public func putMetadata(rmtype: ResultMetadataType, value: Any) {
        if (resultMetadata.size == 0) {
            resultMetadata = HashMap<ResultMetadataType, Any>()
        }
        resultMetadata.put(rmtype, value);
    }

    public func putAllMetadata(metadata: HashMap<ResultMetadataType, Any>) {
        if (metadata.size != 0) {
            if (resultMetadata.size == 0) {
                resultMetadata = metadata
            } else {
                resultMetadata.putAll(metadata);
            }
        }
    }

    public func addResultPoints(newPoints: Array<ResultPoint>) {
        var oldPoints: Array<ResultPoint> = resultPoints
        if (oldPoints.size != 0) {
            resultPoints = newPoints
        } else if (newPoints.size > 0) {
            var allPoints: Array<ResultPoint> = Array<ResultPoint>(
                oldPoints.size + newPoints.size,
                item: ResultPoint()
            );

            System.arraycopy(oldPoints, 0, allPoints, 0, oldPoints.size)
            System.arraycopy(newPoints, 0, allPoints, oldPoints.size, newPoints.size)

            resultPoints = allPoints
        }
    }

    public func getTimestamp(): Int64 {
        return timestamp
    }

    public func toString(): String {
        return text
    }
}
