require 'spec_helper'

describe "initial test" do
  it "should know what truth is" do
    expect(true).to be true
  end
end

describe "authorization" do
  before :each do
    allow(Kms).to receive(:decrypt).and_return('decryptedvalue')
  end

  it "should return an authorization string" do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request).and_return(Net::HTTPResponse)
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{ "access_token": "accesstokenforimportantthings" }')

    new_sierra_request = SierraRequest.new({})
    new_sierra_request.base_request_url = ENV['SIERRA_URL']
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to_not be_nil
  end

  it "should gracefully fail" do
    new_sierra_request = SierraRequest.new({})

    # Assert that timeout/500 response results in nil bearer
    stub_request(:post, "#{ENV['SIERRA_URL']}/token")
      .to_timeout
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil

    # Assert that 404 response results in nil bearer
    stub_request(:post, "#{ENV['SIERRA_URL']}/token")
      .to_return(body: '', status: 404)
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil

    # Assert that 500 response results in nil bearer
    stub_request(:post, "#{ENV['SIERRA_URL']}/token")
      .to_return(body: '', status: 500)
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil

    # Assert that any other http error results in nil bearer
    stub_request(:post, "#{ENV['SIERRA_URL']}/token")
      .to_raise(StandardError)
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil
  end
end

describe SierraRequest do
  suppressed_sierra_req = nil
  unsuppressed_sierra_req = nil
  
  before :each do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request).and_return(Net::HTTPResponse)

    allow(Kms).to receive(:decrypt).and_return('decryptedvalue')

    suppressed_sierra_req = SierraRequest.new({"data" => {}})
    suppressed_sierra_req.delivery_location     = "NC"
    suppressed_sierra_req.base_request_url      = ENV['SIERRA_URL']

    suppressed_sierra_req.assign_bearer

    unsuppressed_sierra_req                     = SierraRequest.new({"data" => {}})
    unsuppressed_sierra_req.delivery_location   = "COOPER"
    unsuppressed_sierra_req.base_request_url    = ENV['SIERRA_URL']

    unsuppressed_sierra_req.assign_bearer
  end

  it "should check for suppression" do
    expect(suppressed_sierra_req.respond_to?(:suppressed?)).to eq(true)
  end

  it "should return true if code matches suppressed codes" do
    expect(suppressed_sierra_req.suppressed?).to eq(true)
  end

  it "should return false if code does not match suppressed codes" do
    expect(unsuppressed_sierra_req.suppressed?).to eq(false)
  end

  describe '#process_nypl_item' do
    it "should gracefully fail if given no data" do 
      # Anticipate process_nypl_item will attempt to fetch hold data by [non-existant] trackingId:
      allow(Net::HTTPResponse).to receive(:code).and_return('200')
      allow(Net::HTTPResponse).to receive(:body)
        .and_return('{}')

      sierra_res = SierraRequest.process_nypl_item({})
      expect(sierra_res["code"]).to eq("404")
    end

    it "should return 404 if passed garbage data or not enough data and is not suppressed" do
      # Anticipate process_nypl_item will attempt to fetch hold data by [non-existant] trackingId:
      allow(Net::HTTPResponse).to receive(:code).and_return('404')
      allow(Net::HTTPResponse).to receive(:body)
        .and_return('{}')

      sierra_res = SierraRequest.process_nypl_item({ "deliveryLocation" => "COOPER" })
      expect(sierra_res["code"]).to eq("404")
      expect(unsuppressed_sierra_req.post_request.code).to eq("404") # because it's missing key ingredients
    end

    it "should return code from sierra request" do
      # We anticipate that this will build a SierraRequest object with:
      #  @json_body={"patron"=>"23338675309", "record"=>"42", "pickupLocation"=>"myf"}
      #  @delivery_location=nil
      #  @base_request_url="https://example.com"
      #  @patron_id="23338675309"
      #  @record_number="42"
      #  @pickup_location="myf"
      # Which will be posted to Sierra api as:
      #  "{\"recordType\":\"i\",\"recordNumber\":42,\"pickupLocation\":\"myf\"}"
      # We anticipate the Sierra API responding to the nonsensical record number '42' with http status 500
      allow(Net::HTTPResponse).to receive(:code).and_return('500')
      allow(Net::HTTPResponse).to receive(:body)
        .and_return('{}')

      sierra_res = SierraRequest.process_nypl_item({"deliveryLocation" => "NV"}, {"data" => {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}})
      expect(sierra_res["code"]).to eq("500") # Given the fake nature of the data, it shouldn't work. But at least it should get to the point of knowing that.
    end

    ['BD', 'NC', 'OI', 'OL'].each do |location|
      it "should automatically return 204 if suppressed deliveryLocation '#{location}'" do
        # Build a fake hold-request instance (so that process_nypl_item doesn't
        # attempt to fetch it itself via [nonexistant] trackingId)::
        hold_request_data = {
          "data" => {
            "patron" => "1234",
            "record" => "5678",
            "deliveryLocation" => location
          }
        }
        # Normally first param (json_data) would include trackingId, but it's not
        # needed if we're passing in hold_request instance in second param:
        sierra_res = SierraRequest.process_nypl_item({}, hold_request_data)
        # Note no http mocking required because code immediately returns success
        # based on suppressed delivery location code:
        expect(sierra_res["code"]).to eq("204")
      end
    end
  end

  describe '#build_new_sierra_request' do
    it "should build a valid sierra request if given appropriate data" do
      hold_request_data = {"patron" => "23338675309", "record" => "42", "deliveryLocation" => "NV"}

      new_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)
      expect(new_sierra_request).to_not be(nil)
      expect(new_sierra_request.patron_id).to eq(hold_request_data["patron"])
      expect(new_sierra_request.record_number).to eq(hold_request_data["record"])
      expect(new_sierra_request.pickup_location).to eq(Location.get_pickup_for("NV"))
    end

    it "should build a sierra request with the provided pickup location if it is provided" do
      hold_request_data = {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}
      new_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)

      expect(new_sierra_request).to_not be(nil)
      expect(new_sierra_request.patron_id).to eq(hold_request_data["patron"])
      expect(new_sierra_request.record_number).to eq(hold_request_data["record"])
      expect(new_sierra_request.delivery_location).to eq(hold_request_data["deliveryLocation"])
      expect(new_sierra_request.pickup_location).to eq("myf")
    end

    it "should not be fooled by blank values in the pickup location" do 
      hold_request_data = {"patron" => "23338675309", "record" => "42", "pickupLocation" => "", "deliveryLocation" => "NV"}
      new_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)

      expect(new_sierra_request).to_not be(nil)
      expect(new_sierra_request.patron_id).to eq(hold_request_data["patron"])
      expect(new_sierra_request.record_number).to eq(hold_request_data["record"])
      expect(new_sierra_request.delivery_location).to eq(hold_request_data["deliveryLocation"])
      expect(new_sierra_request.pickup_location).to eq(Location.get_pickup_for("NV"))
    end
  end
end

describe SierraRequest do
  describe '#process_partner_item' do

    before(:each) do
      stub_request(:post, ENV['RECAP_HOLD_REQUEST_AUTH_URL']).to_return(status: 200, body: '{ "access_token": "fake-access-token" }')

      stub_request(:post, "#{ENV['SIERRA_URL']}/token").to_return(status: 200, body: '{ "access_token": "fake-access-token" }')

      stub_request(:post, "#{ENV['SIERRA_URL']}/bibs")
        .to_return({
          body: {
            link: "https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/bibs/1234567"
          }.to_json,
          status: 200,
          headers: { 'Content-type' => 'application/json;charset=UTF-8' }
        })

      stub_request(:post, "#{ENV['SIERRA_URL']}/items")
        .to_return({
          body: {
            link: "https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/items/56789"
          }.to_json,
          status: 200,
          headers: { 'Content-type' => 'application/json;charset=UTF-8' }
        })

      # Stub a hold-request, which we expect the component to fetch using "trackingId"
      stub_request(:get, "#{ENV['HOLD_REQUESTS_URL']}/hold-requests/hold-request-id-1234")
        .to_return({
          body: {
            'data' => {
              'pickupLocation' => 'mal',
              'patron' => 'patron1234'
            }
          }.to_json,
          status: 200,
          headers: { 'Content-type' => 'application/json;charset=UTF-8' }
        })

      # Stub the hold-request POST to Sierra
      stub_request(:post, "#{ENV['SIERRA_URL']}/patrons/patron1234/holds/requests")
        .to_return(body: '', status: 204)
    end

    it 'returns 404 if no hold-request or trackingId given' do
      result = SierraRequest.process_partner_item({})
      expect(result['code']).to eq('404')
    end

    it 'places hold request on virtual record' do
      result = SierraRequest.process_partner_item(
        {
          'deliveryLocation' => 'NH',
          'trackingId' => 'hold-request-id-1234',
          'itemBarcode' => 12345678,
          'description' => {
            'author' => 'Author',
            'title' => 'Title',
            'callNumber' => 'Call number'
          }
        }
      )

      expect(result).to be_a(Hash)
      expect(result['code']).to eq('204')
    end

    it 'creates harvard item with title provided by scsb' do
      result = SierraRequest.process_partner_item(
        JSON.parse(File.read('./spec/fixtures/recap-hold-request-hl.json'))
      )

      expect(WebMock).to have_requested(:post, "#{ENV['SIERRA_URL']}/bibs").
        with(body: {
            "titles": ["[Standard NYPL restrictions apply] \" ... IZ PENZY V MOSKVU I OBRATNO ...\" : SOVREMENNAIA FILOSOFSKAIA PUBLITSISTIKA = \" ... FROM PENZA TO MOSCOW AND BACK ...\" [RECAP]"],
            "authors": ["Mi͡asnikov, A. G. author. (Andreĭ Gennadʹevich),   "],
            "varFields": [{"fieldTag":"y","marcTag":"910","subfields":[{"tag":"a","content":"RLOTF"}]}]
          },
          headers: {'Content-Type' => 'application/json'}
        )

      expect(result).to be_a(Hash)
      expect(result['code']).to eq('204')
    end

    it 'creates harvard HD item with title modified to include "[HD]" prefix' do
      result = SierraRequest.process_partner_item(
        JSON.parse(File.read('./spec/fixtures/recap-hold-request-hl-hd.json'))
      )

      expect(WebMock).to have_requested(:post, "#{ENV['SIERRA_URL']}/bibs").
        with(body: {
            "titles": ["[HD] [Standard NYPL restrictions apply] \" ... AUF DASS VON DIR DIE NACH-WELT NIMMER SCHWEIGT\" : DIE HERZOGIN ANNA AMALIA BIBLIOTHEK IN WEIMAR NACH DEM BRAND / HERZOGI [HD]"],
            "authors": ["   "],
            "varFields": [{"fieldTag":"y","marcTag":"910","subfields":[{"tag":"a","content":"RLOTF"}]}]
          },
          headers: {'Content-Type' => 'application/json'}
        )

      expect(result).to be_a(Hash)
      expect(result['code']).to eq('204')
    end
  end
end

# Tests using webmock to cover http errors:
describe SierraRequest do
  before :each do
    allow(Kms).to receive(:decrypt).and_return('decryptedvalue')
  end

  it "should gracefully fail if requests to sierra times out" do
    stub_request(:post, "#{ENV['SIERRA_URL']}/token")
      .to_return(status: 200, body: '{ "access_token": "mock-access-token" }')

    # Establish the hold request we'll handle:
    hold_request_data = {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}
    bad_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)
    bad_sierra_request.assign_bearer

    # Server timeout (which webmock interprets as returning a 500)
    stub_request(:post, "#{ENV['SIERRA_URL']}/patrons/23338675309/holds/requests")
      .to_timeout
    expect(bad_sierra_request.post_request.code).to eq("500")

    # Server timeout where server closes connection with a 408:
    stub_request(:post, "#{ENV['SIERRA_URL']}/patrons/23338675309/holds/requests")
      .to_return(body: '', status: 408)
    expect(bad_sierra_request.post_request.code).to eq("408")

    # Server response with 404:
    stub_request(:post, "#{ENV['SIERRA_URL']}/patrons/23338675309/holds/requests")
      .to_return(body: '', status: 404)
    expect(bad_sierra_request.post_request.code).to eq("404")

    # Internet completely broken scenario:
    stub_request(:post, "#{ENV['SIERRA_URL']}/patrons/23338675309/holds/requests")
      .to_raise(StandardError)
    expect(bad_sierra_request.post_request.code).to eq("500")
  end
end
