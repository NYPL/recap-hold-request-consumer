#NCIP, nonexistent patron, valid record
#Received {"level":"INFO","message":"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<NCIPMessage version=\"http://www.niso.org/schemas/ncip/v2_0/ncip_v2_0.xsd\" xmlns=\"http://www.niso.org/2008/ncip\">\n    <AcceptItemResponse>\n        <Problem>\n            <ProblemType>9004</ProblemType>\n            <ProblemDetail>Unknown User</ProblemDetail>\n        </Problem>\n    </AcceptItemResponse>\n</NCIPMessage>\n","levelCode":6,"errorCodename":null,"timestamp":"2018-08-20 16:43:16 -0400"}

HOLD_REQUEST_DATA = '{"data":
{"id":901,
  "jobId":"38955977365ac3c77",
  "createdDate":"2017-07-25T00:00:00-04:00",
  "updatedDate":"2017-07-25T00:00:00-04:00",
  "success":true,
  "processed":true,
  "patron":"9999999",
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
  "patronBarcode":"99999999999999",
  "itemBarcode":"33333809012633",
  "createdDate":"2018-08-20T11:00:37-04:00",
  "updatedDate":null,"owningInstitutionId":"NYPL",
  "description":{"title":"Fire, Chicago, 1871","author":"Duey, Kathleen","callNumber":"|a618.244|cR"}}'
