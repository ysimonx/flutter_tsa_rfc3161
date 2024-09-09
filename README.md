# Flutter TSA (Time Stamping Authority)  client rfc3161


tested on macos and android configurations with digicert and certigna tsa
(fails with flutter web if TSA host does not provide CORS header)


```
import 'package:dio/dio.dart';
import 'package:tsa_rfc3161/tsa_rfc3161.dart';

// ...


     TSARequest tsq = TSARequest.fromFile(
          filepath: file.path,
          algorithm: TSAHashAlgo.sha512,
          nonce: nonceValue,
          certReq: true);
          
      // for a string use 
      // TSARequest tsq = TSARequest.fromString(s: "yannick", algorithm: TSAHashAlgo.sha512);
      
      Response response = await tsq.run(hostname: "http://timestamp.digicert.com");

      if (response.statusCode == 200) {
        TSAResponse tsr = TSAResponse.fromHTTPResponse(response: response);
      }
    
```


Note 1 

*tsq.asn1sequence.encodedBytes* is similar to
the content of file.digicert.tsq generated by openssl
          
```
openssl ts -query -data file.txt -no_nonce -sha512 -cert -out file.digicert.tsq
```
Note 2

the content of *response.data* is similar to 
the content of file.digicert.tsr generated by digicert's http server
```
curl -H 'Content-Type: application/timestamp-query' --data-binary '@file.digicert.tsq'  http://timestamp.digicert.com > file.digicert.tsr
```

Note 3 

authentication is available

```
 Response response = await tsq.run(
          hostname: "https://timestamp.dhimyotis.com/api/v1/",
          credentials: "$user:$password");
```

Note 4
```
TSAResponse tsr = TSAResponse.fromHTTPResponse(response: response);
        tsr.write("test.tsr");
```

you have now a test.tsr you can look with a openssl cli command
```
        $ openssl ts -reply -in test.tsr -text provides
        
        Version: 1
        Policy OID: 2.16.840.1.114412.7.1
        Hash Algorithm: sha512
        Message data:
            0000 - 89 bd 94 b7 92 4b 2f 16-d8 c5 c0 0f 11 02 12 b1   .....K/.........
            0010 - bb b1 5a bb 72 7d be 06-33 bf 7d d0 9f 6f d6 07   ..Z.r}..3.}..o..
            0020 - 02 4d a3 df d6 7b cf c7-89 e2 2f 2d d9 fa 9b c3   .M...{..../-....
            0030 - 39 9a d4 34 11 e1 11 d8-c6 7b a7 a0 b4 96 42 2d   9..4.....{....B-
        Serial number: 0x4194EF54150D2496B2C3F1A78D82C41B
        Time stamp: Sep  7 08:37:47 2024 GMT
        Accuracy: unspecified
        Ordering: no
        Nonce: 0x0191CBA1D914
        TSA: unspecified
        Extensions:
```

Note 5 : 

The TSAResponse class is provided as an attempt. ASN.1 data are very difficult to parse.
Nowadays, you can parse the http response and present your data like this

```
    ASN1Sequence
        ASN1Sequence
            ASN1Integer : 0 : 0 0
        ASN1Sequence
            ASN1ObjectIdentifier : 1.2.840.113549.1.7.2 - signedData
            ASN1Sequence
                ASN1Integer : 3 : 3 3
                ASN1Set
                    ASN1Sequence
                        ASN1ObjectIdentifier : 2.16.840.1.101.3.4.2.1 - sha256
                        ASN1Null
                ASN1Sequence
                    ASN1ObjectIdentifier : 1.2.840.113549.1.9.16.1.4 - id-ct-TSTInfo
                    ASN1Sequence
                        ASN1Integer : 1 : 1 1
                        ASN1ObjectIdentifier : 2.16.840.1.114412.7.1 - time-stamping
                        ASN1Sequence
                            ASN1Sequence
                                ASN1ObjectIdentifier : 2.16.840.1.101.3.4.2.1 - sha256
                                ASN1Null
                            ASN1OctetString  : length 34
                        ASN1Integer : 9223372036854775807 : 42122612516098821491458708936347609874 1fb08523d5e87416cfa98c9e2c37eb12
                        ASN1GeneralizedTime : 2024-09-09 14:29:30.000Z
                        ASN1Integer : 1725892169717 : 1725892169717 191d7308ff5
                ASN1Sequence
                    ASN1Sequence
                        ASN1Sequence
                            ASN1Object : length 5 ''
                            ASN1Integer : 9223372036854775807 : 7002784885422699301467740558332354838 544aff3949d0839a6bfdb3f5fe56116
                            ASN1Sequence
                                ASN1ObjectIdentifier : 1.2.840.113549.1.1.11 - sha256WithRSAEncryption
                                ASN1Null
                            ASN1Sequence
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.6 - countryName
                                        ASN1PrintableString : US
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.10 - organizationName
                                        ASN1PrintableString : DigiCert, Inc.
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.3 - commonName
                                        ASN1PrintableString : DigiCert Trusted G4 RSA4096 SHA256 TimeStamping CA
                            ASN1Sequence
                                ASN1UtcTime : 2023-07-14 00:00:00.000Z
                                ASN1UtcTime : 2034-10-13 23:59:59.000Z
                            ASN1Sequence
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.6 - countryName
                                        ASN1PrintableString : US
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.10 - organizationName
                                        ASN1PrintableString : DigiCert, Inc.
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.3 - commonName
                                        ASN1PrintableString : DigiCert Timestamp 2023
                            ASN1Sequence
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 1.2.840.113549.1.1.1 - rsaEncryption
                                    ASN1Null
                                ASN1BitString : [48, 130, 2, 10, 2, 130, 2, 1, 0, 163, 83, 69, 135, 29, 131, 142, 91, 172, 62, 84, 179, 35, 224, 207, 159, 215, 229, 210, 231, 93, 161, 14, 9, 220, 47, 72, 163, 151, 122, 59, 42, 156, 103, 220, 98, 21, 88, 193, 169, 147, 17, 167, 205, 170, 178, 106, 221, 16, 41, 138, 30, 98, 99, 105, 211, 88, 156, 53, 113, 191, 58, 151, 235, 148, 80, 143, 28, 32, 234, 199, 154, 59, 47, 150, 102, 227, 105, 231, 105, 254, 91, 195, 214, 43, 32, 28, 193, 151, 148, 180, 165, 80, 129, 242, 207, 203, 7, 166, 48, 104, 202, 131, 66, 218, 252, 127, 9, 36, 148, 164, 130, 26, 218, 106, 186, 216, 59, 202, 93, 222, 25, 24, 133, 251, 69, 234, 13, 97, 108, 157, 254, 113, 94, 196, 6, 154, 60, 240, 197, 46, 121, 15, 27, 102, 82, 227, 200, 214, 62, 95, 218, 67, 211, 132, 245, 208, 199, 246, 72, 45, 94, 69, 117, 150, 117, 254, 221, 16, 161, 27, 131, 193, 184, 230, 82, 149, 181, 71, 215, 120, 41, 57, 107, 224, 120, 89, 151, 227, 68, 43, 74, 213, 149, 206, 239, 8, 23, 234, 130, 100, 77, 255, 35, 227, 202, 134, 238, 180, 164, 33, 100, 112, 235, 213, 229, 160, 218, 99, 179, 46, 233, 5, 238, 170, 246, 36, 245, 29, 188, 155, 28, 178, 183, 95, 223, 240, 238, 118, 125, 49, 153, 101, 71, 85, 157, 74, 36, 47, 172, 43, 151, 190, 159, 228, 253, 123, 115, 62, 50, 238, 82, 52, 251, 212, 187, 235, 212, 160, 44, 52, 155, 227, 222, 110, 100, 25, 7, 55, 1, 145, 15, 28, 181, 81, 205, 170, 76, 102, 131, 136, 104, 98, 187, 188, 65, 27, 120, 25, 109, 228, 217, 15, 224, 88, 65, 251, 216, 177, 44, 225, 81, 175, 180, 173, 21, 6, 20, 234, 98, 8, 19, 211, 105, 30, 124, 100, 77, 157, 15, 223, 206, 209, 94, 140, 170, 171, 80, 21, 201, 179, 202, 188, 215, 196, 59, 104, 68, 163, 165, 59, 66, 253, 115, 125, 238, 221, 10, 255, 121, 52, 16, 126, 166, 92, 10, 88, 76, 0, 62, 133, 105, 117, 199, 131, 100, 214, 117, 205, 143, 18, 118, 86, 165, 36, 250, 215, 196, 107, 33, 186, 232, 31, 52, 152, 47, 58, 234, 107, 1, 176, 247, 251, 42, 134, 236, 123, 82, 56, 169, 152, 9, 161, 113, 178, 108, 113, 175, 62, 184, 111, 150, 213, 225, 16, 19, 254, 97, 71, 10, 140, 254, 240, 182, 199, 213, 199, 222, 108, 36, 240, 191, 66, 130, 202, 160, 113, 61, 156, 146, 147, 4, 180, 105, 112, 39, 13, 79, 183, 181, 54, 209, 201, 95, 8, 164, 112, 163, 236, 10, 241, 17, 46, 100, 224, 203, 34, 43, 202, 241, 40, 19, 33, 73, 81, 126, 6, 102, 211, 59, 190, 250, 235, 145, 56, 216, 81, 7, 202, 148, 183, 226, 80, 161, 243, 58, 211, 138, 131, 203, 64, 123, 2, 3, 1, 0, 1]
                            ASN1Sequence
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.15 - keyUsage
                                    ASN1Boolean : true
                                    ASN1OctetString  : length 6
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.19 - basicConstraints
                                    ASN1Boolean : true
                                    ASN1OctetString  : length 4
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.37 - extKeyUsage
                                    ASN1Boolean : true
                                    ASN1OctetString  : length 14
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.32 - certificatePolicies
                                    ASN1OctetString  : length 27
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.35 - authorityKeyIdentifier
                                    ASN1OctetString  : length 26
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.14 - subjectKeyIdentifier
                                    ASN1OctetString  : length 24
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.31 - cRLDistributionPoints
                                    ASN1OctetString  : length 85
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 1.3.6.1.5.5.7.1.1 - authorityInfoAccess
                                    ASN1OctetString  : length 134
                        ASN1Sequence
                            ASN1ObjectIdentifier : 1.2.840.113549.1.1.11 - sha256WithRSAEncryption
                            ASN1Null
                        ASN1BitString : [129, 26, 214, 222, 160, 169, 181, 152, 23, 188, 112, 141, 79, 138, 60, 104, 156, 216, 37, 255, 203, 44, 228, 205, 234, 93, 34, 146, 236, 140, 34, 2, 169, 184, 207, 128, 168, 217, 231, 227, 197, 237, 38, 130, 138, 113, 47, 24, 221, 78, 182, 222, 108, 215, 225, 96, 156, 43, 237, 237, 61, 72, 142, 184, 107, 186, 124, 93, 189, 194, 97, 55, 104, 73, 119, 163, 235, 144, 170, 18, 215, 39, 133, 243, 142, 30, 146, 218, 194, 64, 56, 159, 93, 200, 160, 46, 37, 120, 37, 157, 42, 5, 122, 132, 41, 152, 182, 87, 121, 143, 219, 38, 86, 43, 176, 243, 167, 189, 55, 12, 216, 152, 118, 79, 86, 185, 82, 194, 182, 157, 56, 169, 129, 231, 109, 65, 92, 140, 105, 209, 185, 43, 196, 198, 123, 207, 156, 250, 120, 226, 147, 26, 118, 162, 105, 117, 211, 80, 228, 68, 18, 190, 32, 13, 158, 169, 68, 208, 248, 229, 73, 119, 8, 90, 33, 197, 180, 207, 152, 149, 26, 84, 186, 185, 188, 193, 105, 25, 186, 207, 22, 242, 131, 55, 52, 110, 176, 65, 38, 221, 222, 90, 151, 79, 51, 141, 212, 141, 119, 125, 117, 69, 161, 165, 88, 38, 106, 3, 69, 222, 217, 80, 181, 80, 140, 175, 86, 189, 76, 197, 225, 70, 197, 40, 211, 173, 231, 67, 0, 112, 222, 204, 152, 158, 25, 137, 3, 234, 212, 145, 55, 239, 77, 82, 243, 201, 96, 33, 196, 86, 71, 237, 218, 17, 75, 140, 50, 195, 136, 230, 88, 226, 182, 219, 62, 249, 95, 176, 66, 214, 143, 227, 23, 145, 209, 170, 192, 85, 227, 134, 191, 172, 39, 44, 65, 208, 154, 51, 74, 168, 54, 212, 185, 114, 150, 126, 151, 121, 56, 72, 95, 202, 194, 220, 61, 50, 223, 117, 214, 54, 103, 90, 137, 248, 246, 167, 199, 229, 79, 53, 60, 0, 189, 190, 156, 42, 108, 121, 1, 220, 218, 68, 230, 58, 222, 56, 59, 7, 94, 57, 88, 244, 124, 115, 49, 85, 160, 128, 17, 203, 20, 12, 126, 174, 188, 254, 164, 235, 121, 101, 170, 104, 214, 34, 202, 59, 235, 154, 130, 53, 87, 40, 22, 203, 105, 242, 50, 154, 178, 210, 216, 58, 184, 177, 70, 134, 107, 186, 23, 253, 196, 119, 108, 21, 108, 174, 171, 175, 115, 58, 232, 73, 70, 183, 213, 127, 204, 182, 56, 192, 216, 236, 28, 245, 182, 161, 184, 67, 44, 223, 78, 76, 125, 30, 104, 112, 192, 119, 10, 212, 2, 224, 92, 96, 187, 40, 255, 56, 229, 82, 90, 214, 172, 23, 34, 35, 78, 244, 236, 211, 23, 251, 80, 107, 255, 7, 119, 31, 113, 151, 68, 65, 201, 184, 70, 211, 108, 50, 124, 88, 47, 103, 71, 101, 229, 27, 115, 182, 153, 249, 107, 44, 6, 70, 239, 65, 30, 240, 240, 95, 224, 219, 217, 173, 144, 128, 68, 175, 128, 16, 65, 138]
                    ASN1Sequence
                        ASN1Sequence
                            ASN1Object : length 5 ''
                            ASN1Integer : 9223372036854775807 : 9586110043380832440035821245782711899 73637b724547cd847acfd28662a5e5b
                            ASN1Sequence
                                ASN1ObjectIdentifier : 1.2.840.113549.1.1.11 - sha256WithRSAEncryption
                                ASN1Null
                            ASN1Sequence
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.6 - countryName
                                        ASN1PrintableString : US
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.10 - organizationName
                                        ASN1PrintableString : DigiCert Inc
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.11 - organizationalUnitName
                                        ASN1PrintableString : www.digicert.com
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.3 - commonName
                                        ASN1PrintableString : DigiCert Trusted Root G4
                            ASN1Sequence
                                ASN1UtcTime : 2022-03-23 00:00:00.000Z
                                ASN1UtcTime : 2037-03-22 23:59:59.000Z
                            ASN1Sequence
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.6 - countryName
                                        ASN1PrintableString : US
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.10 - organizationName
                                        ASN1PrintableString : DigiCert, Inc.
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.3 - commonName
                                        ASN1PrintableString : DigiCert Trusted G4 RSA4096 SHA256 TimeStamping CA
                            ASN1Sequence
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 1.2.840.113549.1.1.1 - rsaEncryption
                                    ASN1Null
                                ASN1BitString : [48, 130, 2, 10, 2, 130, 2, 1, 0, 198, 134, 53, 6, 73, 179, 193, 61, 114, 73, 81, 85, 199, 37, 3, 196, 242, 145, 55, 169, 151, 81, 161, 214, 210, 131, 209, 158, 76, 162, 109, 160, 176, 204, 131, 249, 90, 246, 17, 161, 68, 21, 66, 95, 164, 136, 243, 104, 250, 125, 243, 156, 137, 11, 127, 157, 31, 158, 15, 51, 31, 80, 19, 11, 38, 115, 150, 109, 248, 87, 168, 2, 125, 253, 67, 180, 132, 218, 17, 241, 115, 177, 179, 238, 43, 128, 132, 138, 34, 24, 223, 235, 218, 61, 196, 23, 127, 171, 25, 43, 62, 66, 220, 103, 142, 234, 81, 61, 240, 214, 86, 212, 231, 40, 45, 235, 211, 177, 181, 117, 231, 31, 6, 101, 141, 148, 41, 211, 217, 236, 105, 223, 217, 144, 135, 70, 0, 123, 219, 68, 65, 137, 220, 124, 106, 87, 122, 240, 55, 121, 159, 93, 172, 203, 232, 132, 100, 180, 82, 242, 118, 71, 247, 97, 131, 25, 221, 95, 180, 84, 11, 33, 104, 110, 55, 33, 187, 64, 172, 95, 178, 222, 74, 125, 206, 245, 57, 18, 103, 239, 14, 165, 99, 108, 228, 166, 197, 29, 205, 54, 13, 92, 213, 230, 27, 168, 193, 100, 116, 64, 167, 192, 114, 197, 186, 78, 31, 177, 181, 88, 77, 121, 254, 215, 143, 115, 147, 172, 44, 57, 226, 165, 72, 214, 240, 176, 49, 19, 169, 87, 41, 150, 39, 46, 245, 135, 166, 143, 78, 118, 21, 85, 38, 112, 152, 38, 127, 160, 26, 71, 32, 67, 227, 67, 99, 128, 123, 117, 110, 39, 37, 144, 152, 58, 56, 17, 179, 246, 246, 158, 230, 59, 91, 236, 129, 222, 34, 20, 217, 130, 42, 199, 146, 191, 160, 222, 227, 62, 162, 115, 250, 231, 31, 90, 108, 148, 242, 82, 149, 17, 43, 88, 116, 64, 40, 171, 115, 67, 206, 223, 74, 161, 28, 107, 56, 197, 41, 243, 202, 170, 150, 115, 66, 104, 159, 182, 70, 179, 157, 58, 163, 213, 3, 224, 191, 240, 162, 60, 202, 66, 220, 24, 72, 127, 20, 52, 207, 210, 76, 171, 239, 155, 61, 254, 14, 184, 100, 42, 250, 117, 40, 36, 65, 237, 66, 191, 5, 156, 102, 73, 82, 80, 244, 81, 243, 54, 73, 77, 139, 32, 210, 44, 87, 53, 121, 43, 168, 243, 69, 96, 188, 35, 141, 88, 247, 220, 97, 222, 147, 254, 57, 192, 249, 178, 48, 165, 76, 215, 233, 152, 74, 88, 62, 211, 3, 136, 254, 179, 143, 211, 94, 75, 118, 18, 81, 147, 201, 140, 12, 59, 91, 138, 34, 168, 193, 38, 8, 249, 20, 16, 18, 3, 125, 95, 35, 187, 100, 227, 99, 224, 166, 225, 62, 246, 194, 116, 178, 63, 30, 9, 118, 236, 171, 93, 70, 117, 226, 96, 163, 88, 9, 1, 40, 0, 14, 132, 84, 238, 206, 233, 93, 200, 94, 48, 18, 189, 70, 158, 181, 211, 118, 185, 210, 14, 107, 153, 12, 210, 51, 180, 205, 177, 2, 3, 1, 0, 1]
                            ASN1Sequence
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.19 - basicConstraints
                                    ASN1Boolean : true
                                    ASN1OctetString  : length 10
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.14 - subjectKeyIdentifier
                                    ASN1OctetString  : length 24
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.35 - authorityKeyIdentifier
                                    ASN1OctetString  : length 26
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.15 - keyUsage
                                    ASN1Boolean : true
                                    ASN1OctetString  : length 6
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.37 - extKeyUsage
                                    ASN1OctetString  : length 14
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 1.3.6.1.5.5.7.1.1 - authorityInfoAccess
                                    ASN1OctetString  : length 109
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.31 - cRLDistributionPoints
                                    ASN1OctetString  : length 62
                                ASN1Sequence
                                    ASN1ObjectIdentifier : 2.5.29.32 - certificatePolicies
                                    ASN1OctetString  : length 27
                        ASN1Sequence
                            ASN1ObjectIdentifier : 1.2.840.113549.1.1.11 - sha256WithRSAEncryption
                            ASN1Null
                        ASN1BitString : [125, 89, 142, 192, 147, 182, 111, 152, 169, 68, 34, 1, 126, 102, 214, 216, 33, 66, 225, 176, 24, 46, 16, 77, 19, 207, 48, 83, 206, 191, 24, 251, 199, 80, 93, 226, 75, 41, 251, 112, 138, 13, 170, 41, 105, 252, 105, 193, 207, 29, 7, 233, 62, 96, 200, 216, 11, 229, 92, 91, 215, 109, 135, 250, 132, 32, 37, 52, 49, 103, 205, 182, 18, 150, 111, 196, 80, 76, 98, 29, 12, 8, 130, 168, 22, 189, 169, 86, 207, 21, 115, 141, 1, 34, 37, 206, 149, 105, 63, 71, 119, 251, 114, 116, 20, 215, 255, 171, 79, 138, 44, 122, 171, 133, 205, 67, 95, 237, 96, 182, 170, 79, 145, 102, 158, 44, 158, 224, 138, 172, 229, 253, 140, 188, 100, 38, 135, 108, 146, 189, 157, 124, 208, 112, 10, 124, 239, 168, 188, 117, 79, 186, 90, 247, 169, 16, 178, 93, 233, 255, 40, 84, 137, 240, 213, 138, 113, 118, 101, 218, 204, 240, 114, 163, 35, 250, 192, 39, 130, 68, 174, 153, 39, 27, 171, 36, 30, 38, 193, 183, 222, 42, 235, 246, 158, 177, 121, 153, 129, 163, 86, 134, 171, 10, 69, 201, 223, 196, 141, 160, 231, 152, 251, 251, 166, 157, 114, 175, 196, 199, 193, 193, 106, 113, 217, 198, 19, 128, 9, 196, 182, 159, 205, 135, 135, 36, 187, 79, 163, 73, 185, 119, 102, 145, 241, 114, 156, 233, 75, 2, 82, 167, 55, 126, 147, 83, 172, 59, 29, 8, 73, 15, 148, 205, 57, 122, 221, 255, 37, 99, 153, 39, 44, 61, 63, 107, 167, 241, 102, 195, 65, 205, 79, 182, 64, 155, 33, 33, 64, 208, 183, 19, 36, 205, 220, 29, 120, 58, 228, 158, 173, 229, 52, 113, 146, 215, 38, 107, 228, 56, 115, 171, 166, 1, 79, 189, 63, 59, 120, 173, 76, 173, 251, 196, 149, 123, 237, 10, 95, 51, 57, 135, 65, 120, 122, 56, 233, 156, 225, 221, 35, 253, 29, 40, 211, 199, 249, 232, 241, 152, 95, 251, 43, 216, 126, 242, 70, 157, 117, 44, 30, 39, 44, 38, 219, 111, 21, 123, 30, 25, 139, 54, 184, 147, 212, 230, 242, 23, 153, 89, 202, 112, 240, 55, 191, 152, 0, 223, 32, 22, 79, 39, 251, 96, 103, 22, 161, 102, 186, 221, 85, 192, 58, 41, 134, 176, 152, 160, 43, 237, 149, 65, 183, 58, 213, 21, 152, 49, 180, 98, 9, 15, 10, 189, 129, 217, 19, 254, 191, 164, 209, 243, 87, 217, 188, 4, 250, 130, 222, 50, 223, 4, 137, 240, 0, 205, 93, 194, 249, 208, 35, 127, 0, 11, 228, 118, 2, 38, 217, 240, 101, 118, 66, 166, 41, 135, 9, 71, 43, 230, 127, 26, 164, 133, 15, 252, 152, 150, 246, 85, 84, 43, 31, 128, 250, 192, 242, 14, 43, 229, 214, 251, 169, 47, 68, 21, 74, 231, 19, 14, 29, 219, 55, 56, 26, 161, 43, 246, 237, 214, 124, 252]
                ASN1Set
                    ASN1Sequence
                        ASN1Integer : 1 : 1 1
                        ASN1Sequence
                            ASN1Sequence
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.6 - countryName
                                        ASN1PrintableString : US
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.10 - organizationName
                                        ASN1PrintableString : DigiCert, Inc.
                                ASN1Set
                                    ASN1Sequence
                                        ASN1ObjectIdentifier : 2.5.4.3 - commonName
                                        ASN1PrintableString : DigiCert Trusted G4 RSA4096 SHA256 TimeStamping CA
                            ASN1Integer : 9223372036854775807 : 7002784885422699301467740558332354838 544aff3949d0839a6bfdb3f5fe56116
                        ASN1Sequence
                            ASN1ObjectIdentifier : 2.16.840.1.101.3.4.2.1 - sha256
                            ASN1Null
                        ASN1Sequence
                            ASN1Sequence
                                ASN1ObjectIdentifier : 1.2.840.113549.1.9.3 - contentType
                                ASN1Set
                                    ASN1ObjectIdentifier : 1.2.840.113549.1.9.16.1.4 - id-ct-TSTInfo
                            ASN1Sequence
                                ASN1ObjectIdentifier : 1.2.840.113549.1.9.5 - signing-time
                                ASN1Set
                                    ASN1UtcTime : 2024-09-09 14:29:30.000Z
                            ASN1Sequence
                                ASN1ObjectIdentifier : 1.2.840.113549.1.9.16.2.12 - signing-certificate
                                ASN1Set
                                    ASN1Sequence
                                        ASN1Sequence
                                            ASN1Sequence
                                                ASN1OctetString  : length 22
                            ASN1Sequence
                                ASN1ObjectIdentifier : 1.2.840.113549.1.9.4 - id-messageDigest
                                ASN1Set
                                    ASN1OctetString  : length 34
                        ASN1Sequence
                            ASN1ObjectIdentifier : 1.2.840.113549.1.1.1 - rsaEncryption
                            ASN1Null
                        ASN1OctetString  : length 516
```
