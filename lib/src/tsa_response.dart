import 'package:asn1lib/asn1lib.dart';
import 'package:dio/dio.dart';

import 'tsa_common.dart';

class TSAResponse extends TSACommon {
  late Response response;

  late ASN1Sequence PKIStatusInfo;
  late ASN1Sequence timeStampToken;

  late ASN1ObjectIdentifier contentType;

  late ASN1Sequence content;

  late ASN1Set seqTSTInfo;

  late ASN1Sequence asn1sequenceproto;

  TSAResponse();

  TSAResponse.fromHTTPResponse({required this.response}) {
    ASN1Parser parser = ASN1Parser(response.data, relaxedParsing: true);
    asn1sequence = parser.nextObject() as ASN1Sequence;

    // Poc fix
    asn1sequenceproto = asn1sequence;
    asn1sequenceproto = fix(asn1sequenceproto) as ASN1Sequence;
    String result = explore(asn1sequenceproto, 0);
    print(result);

    // parse niv 1
    /*
    asn1sequence.elements
    status          [0] = ASN1Sequence (Seq[ASN1Integer(0) ])

                    PKIStatusInfo ::= SEQUENCE {
                    status        PKIStatus,
                    statusString  PKIFreeText     OPTIONAL,
                    failInfo      PKIFailureInfo  OPTIONAL  }

    timeStampToken  [1] = ASN1Sequence (Seq[ObjectIdentifier(1.2.840.113549.1.7.2) ASN1Object(tag=a0 valueByteLength=5988) startpos=4 bytes=[0xa0, 0x82, 0x17, 0x64, 0x3…)

                    OPTIONAL

                    TimeStampToken ::= ContentInfo
                      -- contentType is id-signedData ([CMS])
                      -- content is SignedData ([CMS])


    */

    PKIStatusInfo = asn1sequence.elements[0] as ASN1Sequence;
    timeStampToken = asn1sequence.elements[1] as ASN1Sequence;

    // parse niv 2 de seq 1
    /* 
      [0] = ASN1ObjectIdentifier (ObjectIdentifier(1.2.840.113549.1.7.2)) SignedData
      [1] = ASN1Object (ASN1Object(tag=a0 valueByteLength=5988) startpos=4 bytes=[0xa0, 0x82, 0x17, 0x64, 0x30, 0x82, 0x17, 0x60, 0x2, 0x1, 0x3, 0x31, 0…)
    */
    contentType = timeStampToken.elements[0] as ASN1ObjectIdentifier;
    ASN1Object temp = timeStampToken.elements[1];
    content = fixASN1Object(temp) as ASN1Sequence;

    // parse niv 3
    /*
     "content" contient 5 elements si certReq = true
     elements =
      List (5 items)
                      [0] = ASN1Integer (ASN1Integer(3))
      sha512          [1] = ASN1Set (Set[Seq[ObjectIdentifier(2.16.840.1.101.3.4.2.3) ASN1Object(tag=5 valueByteLength=0) startpos=2 bytes=[0x5, 0x0] ] ])
      id-ct-TSTInfo   [2] = ASN1Sequence (Seq[ObjectIdentifier(1.2.840.113549.1.9.16.1.4) ASN1Object(tag=a0 valueByteLength=146) startpos=3 bytes=[0xa0, 0x81, 0x92, 0x4, …)
      Certificate     [3] = ASN1Object (ASN1Object(tag=a0 valueByteLength=4873) startpos=4 bytes=[0xa0, 0x82, 0x13, 0x9, 0x30, 0x82, 0x6, 0xc2, 0x30, 0x82, 0x4, 0xaa, 0…)
      TSTInfo         [4] = ASN1Set (Set[Seq[ASN1Integer(1) Seq[Seq[Set[Seq[ObjectIdentifier(2.5.4.6) PrintableString(US) ] ] Set[Seq[ObjectIdentifier(2.5.4.10) Prin…)
     
     content contient 4 elements si certReq = false
     elements =
      List (4 items)
                      [0] = ASN1Integer (ASN1Integer(3))
      sha512          [1] = ASN1Set (Set[Seq[ObjectIdentifier(2.16.840.1.101.3.4.2.3) ASN1Object(tag=5 valueByteLength=0) startpos=2 bytes=[0x5, 0x0] ] ])
      id-ct-TSTInfo   [2] = ASN1Sequence (Seq[ObjectIdentifier(1.2.840.113549.1.9.16.1.4) ASN1Object(tag=a0 valueByteLength=146) startpos=3 bytes=[0xa0, 0x81, 0x92, 0x4, …)
      TSTInfo         [3] = ASN1Set (Set[Seq[ASN1Integer(1) Seq[Seq[Set[Seq[ObjectIdentifier(2.5.4.6) PrintableString(US) ] ] Set[Seq[ObjectIdentifier(2.5.4.10) Prin…)
    */

    if (content.elements.length == 3) {
      seqTSTInfo = fixASN1Object(content.elements[3]) as ASN1Set;
    }
    if (content.elements.length == 4) {
      seqTSTInfo = fixASN1Object(content.elements[3]) as ASN1Set;
    }

    result = explore(seqTSTInfo, 0);
    print(result);
  }
}
