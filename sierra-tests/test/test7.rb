# same as data 3 except barcode matches.
# Attempted once and received error message:
# {"level":"INFO","message":"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<NCIPMessage version=\"http://www.niso.org/schemas/ncip/v2_0/ncip_v2_0.xsd\" xmlns=\"http://www.niso.org/2008/ncip\">\n    <AcceptItemResponse>\n        <Problem>\n            <ProblemType>9007</ProblemType>\n            <ProblemDetail>User Blocked</ProblemDetail>\n        </Problem>\n    </AcceptItemResponse>\n</NCIPMessage>\n","levelCode":6,"errorCodename":null,"timestamp":"2018-08-20 16:45:49 -0400"}
# NCIP

HOLD_REQUEST_DATA = '{"data":
{"id":901,
  "jobId":"38955977365ac3c77",
  "createdDate":"2017-07-25T00:00:00-04:00",
  "updatedDate":"2017-07-25T00:00:00-04:00",
  "success":true,
  "processed":true,
  "patron":"5459252",
  "nyplSource":"sierra-nypl",
  "requestType":"hold",
  "recordType":"i",
  "record":"10010663",
  "pickupLocation":"",
  "deliveryLocation":"NH",
  "neededBy":"2018-07-25T00:00:00-04:00",
  "numberOfCopies":1,
  "docDeliveryData":null,
  "error":null},
  "count":1,
  "statusCode":200,
  "debugInfo":[]}'

  JSON_DATA = '{"id":2897,
  "trackingId":"5555",
  "patronBarcode":"23333090797943",
  "itemBarcode":"33333809012632",
  "createdDate":"2018-08-20T11:00:37-04:00",
  "updatedDate":null,"owningInstitutionId":"NYPL",
  "description":{"title":"Fire, Chicago, 1871","author":"Duey, Kathleen","callNumber":"|a618.244|cR"}}'
