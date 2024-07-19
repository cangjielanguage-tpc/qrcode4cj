// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.common.Qrcoder4cjChecksumException
import QRCode4cj.common.Qrcoder4cjFormatException
import QRCode4cj.common.Qrcoder4cjNotFoundException
import QRCode4cj.common.Qrcoder4cjReaderException
import QRCode4cj.common.Qrcoder4cjWriterException
import QRCode4cj.common.Qrcoder4cjNotFoundException
import QRCode4cj.common.reedsolomon.Qrcoder4cjReedSolomonException

main(): Int64 {
    let tester = Tester()
    tester.Tester01()
    tester.Tester02()
    tester.Tester03()
    tester.Tester04()
    tester.Tester05()
    tester.Tester06()
    0
}

@Test
public class Tester {
    @TestCase
    func Tester01(): Unit {
        try {
            throw Qrcoder4cjChecksumException.getChecksumInstance()
        } catch(e: Qrcoder4cjChecksumException) {
            println(e.toString())
            @Assert(e.toString() == "Qrcoder4cjChecksumException: ")
        }
    }

    func Tester02(): Unit {
        try {
            throw Qrcoder4cjFormatException("test2")
        } catch(e: Qrcoder4cjFormatException) {
            println(e.toString())
            @Assert(e.toString() == "Qrcoder4cjFormatException: test2")
        }
    }

    func Tester03(): Unit {
        try {
            throw Qrcoder4cjNotFoundException("test3")
        } catch(e: Qrcoder4cjNotFoundException) {
            println(e.toString())
            @Assert(e.toString() == "Qrcoder4cjNotFoundException: test3")
        }
    }

    func Tester04(): Unit {
        try {
            throw Qrcoder4cjReaderException("test4")
        } catch(e: Qrcoder4cjReaderException) {
            println(e.toString())
            @Assert(e.toString() == "Qrcoder4cjReaderException: test4")
        }
    }

    func Tester05(): Unit {
        try {
            throw Qrcoder4cjWriterException("test5")
        } catch(e: Qrcoder4cjWriterException) {
            println(e.toString())
            @Assert(e.toString() == "Qrcoder4cjWriterException: test5")
        }
    }

    func Tester06(): Unit {
        try {
            throw Qrcoder4cjReedSolomonException("test6")
        } catch(e: Qrcoder4cjReedSolomonException) {
            println(e.toString())
            @Assert(e.toString() == "Qrcoder4cjReedSolomonException: test6")
        }
    }
}