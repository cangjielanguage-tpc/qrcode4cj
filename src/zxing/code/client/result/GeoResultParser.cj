/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.client.result

import zxing.code.common.Result
from std import format.*

/**
 * Parses a "geo:" URI result, which specifies a location on the surface of
 * the Earth as well as an optional altitude above the surface. See
 * <a href="http://tools.ietf.org/html/draft-mayrhofer-geo-uri-00">
 * http://tools.ietf.org/html/draft-mayrhofer-geo-uri-00</a>.
 *
 * @author Sean Owen
 */
public open class GeoResultParser <: ResultParser {
    private static let GEO_URL_PATTERN: Regex = Regex(
        "geo:([\\-0-9.]+),([\\-0-9.]+)(?:,([\\-0-9.]+))?(?:\\?(.*))?",
        RegexOption().ignoreCase()
    );
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        var matcher = GEO_URL_PATTERN.matcher(rawText.toString());
        var m = matcher.fullMatch()
        if (let None <- m) {
            return None
        }
        var query: String = ""
        if (m.getOrThrow().groupNumber() >= 4) {
            query = m.getOrThrow().matchStr(4)
        }
        var latitude: Float64
        var longitude: Float64
        var altitude: Float64
        try {
            latitude = Float64.parse(m.getOrThrow().matchStr(1))
            if (latitude > 90.0 || latitude < -90.0) {
                return None
            }
            longitude = Float64.parse(m.getOrThrow().matchStr(2))
            if (longitude > 180.0 || longitude < -180.0) {
                return None
            }
            var mat3: String = ""
            if (m.getOrThrow().groupNumber() >= 3) {
                mat3 = m.getOrThrow().matchStr(3)
            }
            if (mat3 == "") {
                altitude = 0.0
            } else {
                altitude = Float64.parse(mat3)
                if (altitude < 0.0) {
                    return None
                }
            }
        } catch (ignored: FormatException) {
            return None
        }
        return GeoParsedResult(latitude, longitude, altitude, query);
    }
}
