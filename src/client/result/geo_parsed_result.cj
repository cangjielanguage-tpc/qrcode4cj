/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*

/**
 * Represents a parsed result that encodes a geographic coordinate, with latitude,
 * longitude and altitude.
 */
public open class GeoParsedResult <: ParsedResult {
    private var latitude: Float64 = 0.0
    private var longitude: Float64 = 0.0
    private var altitude: Float64 = 0.0
    private var query: String = String()
    private var flag: Bool = false

    public init() {
        super(ParsedResultType.GEO)
    }
    init(latitude: Float64, longitude: Float64, altitude: Float64, query: String) {
        super(ParsedResultType.GEO);
        this.latitude = latitude
        this.longitude = longitude
        this.altitude = altitude
        this.query = query
        this.flag = true
    }

    public func getGeoURI(): String {
        var result: ArrayList<Rune> = ArrayList<Rune>();
        result.add(all:"geo:".toRuneArray());
        result.add(all:latitude.toString().toRuneArray());
        result.add(r',');
        result.add(all:longitude.toString().toRuneArray());
        if (altitude > 0.0) {
            result.add(r',');
            result.add(all:altitude.toString().toRuneArray());
        }
        if (query != "") {
            result.add(r'?');
            result.add(all:query.toRuneArray());
        }
        return String(result);
    }

    /**
     * @return latitude in degrees
     */
    public func getLatitude(): Float64 {
        return latitude
    }

    /**
     * @return longitude in degrees
     */
    public func getLongitude(): Float64 {
        return longitude
    }

    /**
     * @return altitude in meters. If not specified, in the geo URI, returns 0.0
     */
    public func getAltitude(): Float64 {
        return altitude
    }

    /**
     * @return query string associated with geo URI or null if none exists
     */
    public func getQuery(): String {
        return query
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Rune> = ArrayList<Rune>();
        result.add(all:latitude.toString().toRuneArray());
        result.add(all:", ".toRuneArray());
        result.add(all:longitude.toString().toRuneArray());
        if (altitude > 0.0) {
            result.add(all:", ".toRuneArray());
            result.add(all:altitude.toString().toRuneArray());
            result.add(r'm');
        }
        if (query != "") {
            result.add(all:" (".toRuneArray());
            result.add(all:query.toRuneArray());
            result.add(r')');
        }
        return String(result);
    }
}
