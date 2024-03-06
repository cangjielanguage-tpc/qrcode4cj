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

package zxing.code.client.result

/**
 * Represents a parsed result that encodes a product by an identifier of some kind.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public open class ProductParsedResult <: ParsedResult {
    private var productID: String = String()
    private var normalizedProductID: String = String()
    private var flag: Bool = false
    init() {
        super(ParsedResultType.PRODUCT)
    }
    init(productID: String) {
        this(productID, productID);
    }

    init(productID: String, normalizedProductID: String) {
        super(ParsedResultType.PRODUCT);
        this.productID = productID
        this.normalizedProductID = normalizedProductID
        this.flag = true
    }

    public func getProductID(): String {
        return productID
    }

    public func getNormalizedProductID(): String {
        return normalizedProductID
    }

    public override func getDisplayResult(): String {
        return productID
    }
}
