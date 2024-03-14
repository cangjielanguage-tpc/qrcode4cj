/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.client.result

/**
 * Represents a parsed result that encodes a Vehicle Identification Number (VIN).
 */
public open class VINParsedResult <: ParsedResult {
    private var vin: String = String()
    private var worldManufacturerID: String = String()
    private var vehicleDescriptorSection: String = String()
    private var vehicleIdentifierSection: String = String()
    private var countryCode: String = String()
    private var vehicleAttributes: String = String()
    private var modelYear: Int64 = 0
    private var plantCode: Char = '0'
    private var sequentialNumber: String = String()
    private var flag: Bool = false
    public init() {
        super(ParsedResultType.VIN)
    }
    public init(
        vin: String,
        worldManufacturerID: String,
        vehicleDescriptorSection: String,
        vehicleIdentifierSection: String,
        countryCode: String,
        vehicleAttributes: String,
        modelYear: Int64,
        plantCode: Char,
        sequentialNumber: String
    ) {
        super(ParsedResultType.VIN);
        this.vin = vin
        this.worldManufacturerID = worldManufacturerID
        this.vehicleDescriptorSection = vehicleDescriptorSection
        this.vehicleIdentifierSection = vehicleIdentifierSection
        this.countryCode = countryCode
        this.vehicleAttributes = vehicleAttributes
        this.modelYear = modelYear
        this.plantCode = plantCode
        this.sequentialNumber = sequentialNumber
        this.flag = true
    }

    public func getVIN(): String {
        return vin
    }

    public func getWorldManufacturerID(): String {
        return worldManufacturerID
    }

    public func getVehicleDescriptorSection(): String {
        return vehicleDescriptorSection
    }

    public func getVehicleIdentifierSection(): String {
        return vehicleIdentifierSection
    }

    public func getCountryCode(): String {
        return countryCode
    }

    public func getVehicleAttributes(): String {
        return vehicleAttributes
    }

    public func getModelYear(): Int64 {
        return modelYear
    }

    public func getPlantCode(): Char {
        return plantCode
    }

    public func getSequentialNumber(): String {
        return sequentialNumber
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        result.appendAll(worldManufacturerID.toRuneArray())
        result.append(' ');
        result.appendAll(vehicleDescriptorSection.toRuneArray())
        result.append(' ');
        result.appendAll(vehicleIdentifierSection.toRuneArray())
        result.append('\n');
        if (countryCode != "") {
            result.appendAll(countryCode.toRuneArray())
            result.append(' ');
        }
        result.appendAll(modelYear.toString().toRuneArray())
        result.append(' ');
        result.append(plantCode)
        result.append(' ');
        result.appendAll(sequentialNumber.toRuneArray())
        result.append('\n');
        return String(result);
    }
}
