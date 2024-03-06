/*
 * Copyright 2007 ZXing authors
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

package zxing.code.common

/**
 * Thrown when a barcode was successfully detected, but some aspect of
 * the content did not conform to the barcode's format rules. This could have
 * been due to a mis-detection.
 *
 * @author Sean Owen
 */
public open class FormatException <: ReaderException {
    public init() {
        super("FormatException")
    }

    public init(msg: String) {
        super("FormatException: ${msg}")
    }

    public static func getFormatInstance(): FormatException {
        return FormatException()
    }

    public static func getFormatInstance(ex: Exception): FormatException {
        return FormatException(ex.toString())
    }
}
