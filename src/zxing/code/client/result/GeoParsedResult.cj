/*
 * Copyright 2008 ZXing authors
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
 * Represents a parsed result that encodes a geographic coordinate, with latitude,
 * longitude and altitude.
 *
 * @author Sean Owen
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
        var result: ArrayList<Char> = ArrayList<Char>();
        result.appendAll("geo:".toRuneArray());
        result.appendAll(latitude.toString().toRuneArray());
        result.append(',');
        result.appendAll(longitude.toString().toRuneArray());
        if (altitude > 0.0) {
            result.append(',');
            result.appendAll(altitude.toString().toRuneArray());
        }
        if (query != "") {
            result.append('?');
            result.appendAll(query.toRuneArray());
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
        var result: ArrayList<Char> = ArrayList<Char>();
        result.appendAll(latitude.toString().toRuneArray());
        result.appendAll(", ".toRuneArray());
        result.appendAll(longitude.toString().toRuneArray());
        if (altitude > 0.0) {
            result.appendAll(", ".toRuneArray());
            result.appendAll(altitude.toString().toRuneArray());
            result.append('m');
        }
        if (query != "") {
            result.appendAll(" (".toRuneArray());
            result.appendAll(query.toRuneArray());
            result.append(')');
        }
        return String(result);
    }
}
