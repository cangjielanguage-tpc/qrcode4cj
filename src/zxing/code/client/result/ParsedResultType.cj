/*
 * Copyright 2010 ZXing authors
 *
 * Licensed under the Apache License, Version 20 (the "License");
 * you may not use this file except in compliance with the License
 * You may obtain a copy of the License at
 *
 * http://wwwapacheorg/licenses/LICENSE-20
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package zxing.code.client.result

/**
 * Represents the type of data encoded by a barcode -- from plain text, to a
 * URI, to an e-mail address, etc
 *
 * @author Sean Owen
 */
public enum ParsedResultType <: ToString {
    | ADDRESSBOOK
    | EMAIL_ADDRESS
    | PRODUCT
    | URI
    | TEXT
    | GEO
    | TEL
    | SMS
    | CALENDAR
    | WIFI
    | ISBN
    | VIN

    public func toString(): String {
        return match (this) {
            case ADDRESSBOOK => "ADDRESSBOOK"
            case EMAIL_ADDRESS => "EMAIL_ADDRESS"
            case PRODUCT => "PRODUCT"
            case URI => "URI"
            case TEXT => "TEXT"
            case GEO => "GEO"
            case TEL => "TEL"
            case SMS => "SMS"
            case CALENDAR => "CALENDAR"
            case WIFI => "WIFI"
            case ISBN => "ISBN"
            case VIN => "VIN"
        }
    }
}
