@testset "_sanitize_number_string" begin
    @test Fundamentus._sanitize_number_string("1000") == "1000"
    @test Fundamentus._sanitize_number_string("1.000") == "1000"
    @test Fundamentus._sanitize_number_string("1.000,00") == "1000.00"
    @test Fundamentus._sanitize_number_string("-1.000,00") == "-1000.00"
    @test Fundamentus._sanitize_number_string("0,5%") == "0.5"
end


@testset "sanitize_int" begin
    @test Fundamentus.sanitize_int("1000") == 1000
    @test Fundamentus.sanitize_int("-1.000") == -1000
end


@testset "sanitize_float" begin
    @test Fundamentus.sanitize_float("1000") == 1000.0
    @test Fundamentus.sanitize_float("-1.000") == -1000.0
    @test Fundamentus.sanitize_float("-1.000,00") == -1000.0
    @test Fundamentus.sanitize_float("1%") == 1.0
    @test Fundamentus.sanitize_float("1,0%"; as_percentage=true) == 0.01
    @test Fundamentus.sanitize_float("-5,0%"; as_percentage=true) == -0.05
end


@testset "_sanitize_date_string" begin
    @test Fundamentus._sanitize_date_string("01/09/2025") == "01/09/2025"
    @test Fundamentus._sanitize_date_string("   01/09/2025   ") == "01/09/2025"
    @test Fundamentus._sanitize_date_string("01/09/2025    12:30") == "01/09/2025 12:30"
    @test Fundamentus._sanitize_date_string("01/09/2025\t\t12:30\n") == "01/09/2025 12:30"
    @test Fundamentus._sanitize_date_string("") == ""
    @test Fundamentus._sanitize_date_string("     ") == ""
end


@testset "_parse_date" begin
    @test Fundamentus._parse_date("01/09/2025") == Date(2025, 9, 1)
    @test Fundamentus._parse_date("  15/01/2000  ") == Date(2000, 1, 15)
    @test Fundamentus._parse_date("31/12/1999") == Date(1999, 12, 31)
    @test Fundamentus._parse_date("2025-08-31"; format=DateFormat("yyyy-mm-dd")) == Date(2025, 8, 31)
end


@testset "_parse_date_time" begin
    @test Fundamentus._parse_date_time("01/09/2025 13:45") == DateTime(2025, 9, 1, 13, 45)
    @test Fundamentus._parse_date_time(" 15/01/2000 00:00 ") == DateTime(2000, 1, 15, 0, 0, 0)
    custom_fmt = DateFormat("yyyy-mm-dd HH:MM:SS")
    @test Fundamentus._parse_date_time("2025-08-31 23:59:54"; format=custom_fmt) == DateTime(2025, 8, 31, 23, 59, 54)
end


"""
    _encode_cfemail(email::String; key::UInt8=0x2A) :: String

Função auxiliar apenas para gerar `cfemail` válido a partir de um email.
NÃO faz parte da API final, só para os testes.
"""
function _encode_cfemail(email::String; key::UInt8=0x2A) :: String
    bytes = UInt8[key]
    append!(bytes, [UInt8(c) ⊻ key for c in email])
    return join([string(b, base=16, pad=2) for b in bytes])
end


@testset "decode_cfemail" begin
    email = "test@example.com"
    encoded = _encode_cfemail(email; key=0x55)
    @test Fundamentus.decode_cfemail(encoded) == email

    for email in ["user@domain.com", "a@b.co", "first.second@company.org"]
        encoded = _encode_cfemail(email; key=0x7F)
        @test Fundamentus.decode_cfemail(encoded) == email
    end

    for key in (0x01, 0xAA, 0xFE)
        email = "random@example.net"
        encoded = _encode_cfemail(email; key=key)
        @test Fundamentus.decode_cfemail(encoded) == email
    end

    # empty email
    encoded_empty = _encode_cfemail("", key=0x42)
    @test Fundamentus.decode_cfemail(encoded_empty) == ""

    # Casos inválidos
    @test_throws ArgumentError Fundamentus.decode_cfemail("zzzz")   # not a hex
end
