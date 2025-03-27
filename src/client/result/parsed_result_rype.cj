/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

/**
 * Represents the type of data encoded by a barcode -- from plain text, to a
 * URI, to an e-mail address, etc
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
