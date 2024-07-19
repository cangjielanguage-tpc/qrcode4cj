// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.Result
import QRCode4cj.common.ResultPoint
import QRCode4cj.client.result.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = AddressBookParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AddressBookParsedResultTestCase {
    @TestCase
    public func testAddressBookDocomo(): Unit {
        doTest(
            "MECARD:N:Sean Owen;;",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
        doTest(
            "MECARD:NOTE:ZXing Team;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;;",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(),
            Array<String>(["srowen@example.org"]),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(["google.com"]),
            "",
            "ZXing Team"
        );
    }

    @TestCase
    public func testAddressBookAU(): Unit {
        doTest(
            "MEMORY:foo\r\nNAME1:Sean\r\nTEL1:+12125551212\r\n",
            "",
            Array<String>(["Sean"]),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(["+12125551212"]),
            Array<String>(),
            "",
            Array<String>(),
            "",
            "foo"
        );
    }

    @TestCase
    public func testVCard(): Unit {
        doTest(
            "BEGIN:VCARD\r\nADR;HOME:123 Main St\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(["123 Main St"]),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testVCardFullN(): Unit {
        doTest(
            "BEGIN:VCARD\r\nVERSION:2.1\r\nN:Owen;Sean;T;Mr.;Esq.\r\nEND:VCARD",
            "",
            Array<String>(["Mr. Sean T Owen Esq."]),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testVCardFullN2(): Unit {
        doTest(
            "BEGIN:VCARD\r\nVERSION:2.1\r\nN:Owen;Sean;;;\r\nEND:VCARD",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testVCardFullN3(): Unit {
        doTest(
            "BEGIN:VCARD\r\nVERSION:2.1\r\nN:;Sean;;;\r\nEND:VCARD",
            "",
            Array<String>(["Sean"]),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testVCardCaseInsensitive(): Unit {
        doTest(
            "begin:vcard\r\nadr;HOME:123 Main St\r\nVersion:2.1\r\nn:Owen;Sean\r\nEND:VCARD",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(["123 Main St"]),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testEscapedVCard(): Unit {
        doTest(
            "BEGIN:VCARD\r\nADR;HOME:123\\;\\\\ Main\\, St\\nHome\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(["123;\\ Main, St\nHome"]),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testBizcard(): Unit {
        doTest(
            "BIZCARD:N:Sean;X:Owen;C:Google;A:123 Main St;M:+12125551212;E:srowen@example.org;",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(["123 Main St"]),
            Array<String>(["srowen@example.org"]),
            Array<String>(["+12125551212"]),
            Array<String>(),
            "Google",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testSeveralAddresses(): Unit {
        doTest(
            "MECARD:N:Foo Bar;ORG:Company;TEL:5555555555;EMAIL:foo.bar@xyz.com;ADR:City, 10001;" +
                "ADR:City, 10001;NOTE:This is the memo.;;",
            "",
            Array<String>(["Foo Bar"]),
            "",
            Array<String>(["City, 10001", "City, 10001"]),
            Array<String>(["foo.bar@xyz.com"]),
            Array<String>(["5555555555"]),
            Array<String>(),
            "Company",
            Array<String>(),
            "",
            "This is the memo."
        );
    }

    @TestCase
    public func testQuotedPrintable(): Unit {
        doTest(
            "BEGIN:VCARD\r\nADR;HOME;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:;;" +
                "=38=38=20=4C=79=6E=62=72=6F=6F=6B=0D=0A=43=\r\n" + "=4F=20=36=39=39=\r\n" + "=39=39;;;\r\nEND:VCARD",
            "",
            Array<String>(),
            "",
            Array<String>(["88 Lynbrook\r\nCO 69999"]),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testVCardEscape(): Unit {
        doTest(
            "BEGIN:VCARD\r\nNOTE:foo\\nbar\r\nEND:VCARD",
            "",
            Array<String>(),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            "foo\nbar"
        );
        doTest(
            "BEGIN:VCARD\r\nNOTE:foo\\;bar\r\nEND:VCARD",
            "",
            Array<String>(),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            "foo;bar"
        );
        doTest(
            "BEGIN:VCARD\r\nNOTE:foo\\\\bar\r\nEND:VCARD",
            "",
            Array<String>(),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            "foo\\bar"
        );
        doTest(
            "BEGIN:VCARD\r\nNOTE:foo\\,bar\r\nEND:VCARD",
            "",
            Array<String>(),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            "foo,bar"
        );
    }

    @TestCase
    public func testVCardValueURI(): Unit {
        doTest(
            "BEGIN:VCARD\r\nTEL;VALUE=uri:tel:+1-555-555-1212\r\nEND:VCARD",
            "",
            Array<String>(),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(["+1-555-555-1212"]),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );

        doTest(
            "BEGIN:VCARD\r\nN;VALUE=text:Owen;Sean\r\nEND:VCARD",
            "",
            Array<String>(["Sean Owen"]),
            "",
            Array<String>(),
            Array<String>(),
            Array<String>(),
            Array<String>(),
            "",
            Array<String>(),
            "",
            ""
        );
    }

    private static func doTest(
        contents: String,
        title: String,
        names: Array<String>,
        pronunciation: String,
        addresses: Array<String>,
        emails: Array<String>,
        phoneNumbers: Array<String>,
        phoneTypes: Array<String>,
        org: String,
        urls: Array<String>,
        birthday: String,
        note: String
    ) {
        var fakeResult: Result = Result(contents, Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE);
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.ADDRESSBOOK.toString(), result.getType().toString())
        if (result is AddressBookParsedResult) {
            var addressResult: AddressBookParsedResult = (result as AddressBookParsedResult).getOrThrow()
            @Assert(title, addressResult.getTitle())
            @Assert(names, addressResult.getNames())
            @Assert(pronunciation, addressResult.getPronunciation())
            @Assert(addresses, addressResult.getAddresses())
            @Assert(emails, addressResult.getEmails())
            @Assert(phoneNumbers, addressResult.getPhoneNumbers())
            @Assert(phoneTypes, addressResult.getPhoneTypes())
            @Assert(org, addressResult.getOrg())
            @Assert(urls, addressResult.getURLs())
            @Assert(birthday, addressResult.getBirthday())
            @Assert(note, addressResult.getNote())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
