/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

/**
 * Represents a parsed result that encodes a product by an identifier of some kind.
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
