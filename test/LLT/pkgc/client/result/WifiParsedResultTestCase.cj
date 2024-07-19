// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.math.*
import std.time.*
import std.unicode.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.Result
import QRCode4cj.common.ResultPoint
import QRCode4cj.client.result.*

main(): Int64 {
    let tester = WifiParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class WifiParsedResultTestCase {
    @TestCase
    public func testNoPassword(): Unit {
        doTest("WIFI:S:NoPassword;P:;T:;;", "NoPassword", "", "nopass");
        doTest("WIFI:S:No Password;P:;T:;;", "No Password", "", "nopass");
    }

    @TestCase
    public func testWep(): Unit {
        doTest("WIFI:S:TenChars;P:0123456789;T:WEP;;", "TenChars", "0123456789", "WEP");
        doTest("WIFI:S:TenChars;P:abcde56789;T:WEP;;", "TenChars", "abcde56789", "WEP");

        // Non hex should not fail at this level
        doTest("WIFI:S:TenChars;P:hellothere;T:WEP;;", "TenChars", "hellothere", "WEP");

        // Escaped semicolons
        doTest("WIFI:S:Ten\\;\\;Chars;P:0123456789;T:WEP;;", "Ten;;Chars", "0123456789", "WEP");

        // Escaped colons
        doTest("WIFI:S:Ten\\:\\:Chars;P:0123456789;T:WEP;;", "Ten::Chars", "0123456789", "WEP");
    }

    /**
     * Put in checks for the length of the password for wep.
     */
    @TestCase
    public func testWpa(): Unit {
        doTest("WIFI:S:TenChars;P:wow;T:WPA;;", "TenChars", "wow", "WPA");
        doTest("WIFI:S:TenChars;P:space is silent;T:WPA;;", "TenChars", "space is silent", "WPA");
        doTest("WIFI:S:TenChars;P:hellothere;T:WEP;;", "TenChars", "hellothere", "WEP");

        // Escaped semicolons
        doTest("WIFI:S:TenChars;P:hello\\;there;T:WEP;;", "TenChars", "hello;there", "WEP");

        // Escaped colons
        doTest("WIFI:S:TenChars;P:hello\\:there;T:WEP;;", "TenChars", "hello:there", "WEP");
    }

    @TestCase
    public func testEscape(): Unit {
        doTest("WIFI:T:WPA;S:test;P:my_password\\\\;;", "test", "my_password\\", "WPA");
        doTest("WIFI:T:WPA;S:My_WiFi_SSID;P:abc123/;;", "My_WiFi_SSID", "abc123/", "WPA");
        doTest("WIFI:T:WPA;S:\"foo\\;bar\\\\baz\";;", "\"foo;bar\\baz\"", "", "WPA");
        doTest("WIFI:T:WPA;S:test;P:\\\"abcd\\\";;", "test", "\"abcd\"", "WPA");
    }

    /**
     * Given the string contents for the barcode, check that it matches our expectations
     */
    private static func doTest(contents: String, ssid: String, password: String, stype: String) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult)

        // Ensure it is a wifi code
        @Assert(result.getType().toString(), ParsedResultType.WIFI.toString())
        if (result is WifiParsedResult) {
            var wifiResult: WifiParsedResult = (result as WifiParsedResult).getOrThrow()
            @Assert(ssid, wifiResult.getSsid())
            @Assert(password, wifiResult.getPassword())
            @Assert(stype, wifiResult.getNetworkEncryption())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
