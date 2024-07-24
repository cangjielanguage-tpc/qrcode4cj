/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.client.result

import std.collection.*

/**
 * Represents a parsed result that encodes extended product information as encoded
 * by the RSS format, like weight, price, dates, etc.
 */
public open class ExpandedProductParsedResult <: ParsedResult {
    public static let KILOGRAM: String = "KG";
    public static let POUND: String = "LB";

    private var rawText: String = String()
    private var productID: String = String()
    private var sscc: String = String()
    private var lotNumber: String = String()
    private var productionDate: String = String()
    private var packagingDate: String = String()
    private var bestBeforeDate: String = String()
    private var expirationDate: String = String()
    private var weight: String = String()
    private var weightType: String = String()
    private var weightIncrement: String = String()
    private var price: String = String()
    private var priceIncrement: String = String()
    private var priceCurrency: String = String()
    public var flag: Bool = false

    // For AIS that not exist in this object
    private var uncommonAIs: HashMap<String, String> = HashMap<String, String>()
    init() {
        super(ParsedResultType.PRODUCT)
    }
    public init(
        rawText: String,
        productID: String,
        sscc: String,
        lotNumber: String,
        productionDate: String,
        packagingDate: String,
        bestBeforeDate: String,
        expirationDate: String,
        weight: String,
        weightType: String,
        weightIncrement: String,
        price: String,
        priceIncrement: String,
        priceCurrency: String,
        uncommonAIs: HashMap<String, String>
    ) {
        super(ParsedResultType.PRODUCT);
        this.rawText = rawText
        this.productID = productID
        this.sscc = sscc
        this.lotNumber = lotNumber
        this.productionDate = productionDate
        this.packagingDate = packagingDate
        this.bestBeforeDate = bestBeforeDate
        this.expirationDate = expirationDate
        this.weight = weight
        this.weightType = weightType
        this.weightIncrement = weightIncrement
        this.price = price
        this.priceIncrement = priceIncrement
        this.priceCurrency = priceCurrency
        this.uncommonAIs = uncommonAIs
        this.flag = true
    }

    public func equals(o: Object): Bool {
        if (!(o is ExpandedProductParsedResult)) {
            return false;
        }

        var other: ExpandedProductParsedResult = if (o is ExpandedProductParsedResult) {
            return true
        } else {
            return false
        }

        return (productID == other.productID && sscc == other.sscc && lotNumber == other.lotNumber && productionDate ==
            other.productionDate && bestBeforeDate == other.bestBeforeDate && expirationDate == other.expirationDate &&
            weight == other.weight && weightType == other.weightType && weightIncrement == other.weightIncrement &&
            price == other.price && priceIncrement == other.priceIncrement && priceCurrency == other.priceCurrency &&
            uncommonAIs == other.uncommonAIs)
    }

    public func hashCode(): Int64 {
        var hash: Int64 = productID.hashCode();
        hash ^= sscc.hashCode()
        hash ^= lotNumber.hashCode()
        hash ^= productionDate.hashCode()
        hash ^= bestBeforeDate.hashCode()
        hash ^= expirationDate.hashCode()
        hash ^= weight.hashCode()
        hash ^= weightType.hashCode()
        hash ^= weightIncrement.hashCode()
        hash ^= price.hashCode()
        hash ^= priceIncrement.hashCode()
        hash ^= priceCurrency.hashCode()
        hash ^= (uncommonAIs.toString()).hashCode()
        return hash
    }

    public func getRawText(): String {
        return rawText
    }

    public func getProductID(): String {
        return productID
    }

    public func getSscc(): String {
        return sscc
    }

    public func getLotNumber(): String {
        return lotNumber
    }

    public func getProductionDate(): String {
        return productionDate
    }

    public func getPackagingDate(): String {
        return packagingDate
    }

    public func getBestBeforeDate(): String {
        return bestBeforeDate
    }

    public func getExpirationDate(): String {
        return expirationDate
    }

    public func getWeight(): String {
        return weight
    }

    public func getWeightType(): String {
        return weightType
    }

    public func getWeightIncrement(): String {
        return weightIncrement
    }

    public func getPrice(): String {
        return price
    }

    public func getPriceIncrement(): String {
        return priceIncrement
    }

    public func getPriceCurrency(): String {
        return priceCurrency
    }

    public func getUncommonAIs(): HashMap<String, String> {
        return uncommonAIs
    }

    public func getDisplayResult(): String {
        return rawText;
    }
}
