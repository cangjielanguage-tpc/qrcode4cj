/*
 * Copyright 2010 ZXing authors
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

package zxing.code.oned

/**
 * This object renders a UPC-A code as a {@link BitMatrix}.
 *
 * @author qwandor@google.com (Andrew Walbran)
 */
public open class UPCAWriter <: Writer {
    private let subWriter: EAN13Writer = EAN13Writer();

    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>());
    }

    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix {
        if (format != BarcodeFormat.UPC_A) {
            throw IllegalArgumentException("Can only encode UPC-A, but got ${format}");
        }

        // Transform a UPC-A code into the equivalent EAN-13 code and write it that way
        return subWriter.encode("0" + contents, BarcodeFormat.EAN_13, width, height, hints);
    }
}
