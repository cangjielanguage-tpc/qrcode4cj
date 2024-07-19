/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

import std.collection.*

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
    private var plantCode: Rune = '0'
    private var sequentialNumber: String = String()
    private var flag: Bool = false
    public init() {
        super(ParsedResultType.VIN)
    }
    public init(
        vin_: String,
        worldManufacturerID_: String,
        vehicleDescriptorSection_: String,
        vehicleIdentifierSection_: String,
        countryCode_: String,
        vehicleAttributes_: String,
        modelYear_: Int64,
        plantCode_: Rune,
        sequentialNumber_: String
    ) {
        super(ParsedResultType.VIN)
        this.vin = vin_
        this.worldManufacturerID = worldManufacturerID_
        this.vehicleDescriptorSection = vehicleDescriptorSection_
        this.vehicleIdentifierSection = vehicleIdentifierSection_
        this.countryCode = countryCode_
        this.vehicleAttributes = vehicleAttributes_
        this.modelYear = modelYear_
        this.plantCode = plantCode_
        this.sequentialNumber = sequentialNumber_
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

    public func getPlantCode(): Rune {
        return plantCode
    }

    public func getSequentialNumber(): String {
        return sequentialNumber
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Rune> = ArrayList<Rune>()
        result.appendAll(worldManufacturerID.toRuneArray())
        result.append(r' ')
        result.appendAll(vehicleDescriptorSection.toRuneArray())
        result.append(r' ')
        result.appendAll(vehicleIdentifierSection.toRuneArray())
        result.append(r'\n')
        if (countryCode != "") {
            result.appendAll(countryCode.toRuneArray())
            result.append(r' ')
        }
        result.appendAll(modelYear.toString().toRuneArray())
        result.append(r' ')
        result.append(plantCode)
        result.append(r' ')
        result.appendAll(sequentialNumber.toRuneArray())
        result.append(r'\n')
        return String(result)
    }
}
