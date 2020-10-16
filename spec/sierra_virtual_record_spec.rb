require 'spec_helper'

describe SierraVirtualRecord do
  describe '#initialize' do
    it 'accepts data' do
      record = SierraVirtualRecord.new({
        foo: 'bar'
      })

      expect(record.instance_variable_get(:@data)).to be_a(Hash)
      expect(record.instance_variable_get(:@data)[:foo]).to eq('bar')
    end
  end

  describe '#create_bib' do
    before(:each) do
      stub_request(:post, "#{ENV['SIERRA_URL']}/token").to_return(status: 200, body: '{ "access_token": "fake-access-token" }')

      stub_request(:post, "#{ENV['SIERRA_URL']}/bibs")
        .to_return({
          body: {
            link: "https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/bibs/1234567"
          }.to_json,
          status: 201,
          headers: { 'Content-type' => 'application/json;charset=UTF-8' }
        })
    end

    it 'attempts to create bib via Sierra API' do
      record = SierraVirtualRecord.new({
        title: 'Bib title',
        author: 'Bib author'
      })

      expect(record.instance_variable_get(:@data)).to be_a(Hash)
      expect(record.instance_variable_get(:@data)[:title]).to eq('Bib title')

      result = record.create_bib
      expect(result).to eq(1234567)
    end

    it 'throws SierraVirtualRecordError if creation failed' do
      record = SierraVirtualRecord.new({
        title: 'Bib title',
        author: 'Bib author'
      })

      stub_request(:post, "#{ENV['SIERRA_URL']}/bibs")
        .to_return({
          body: '',
          status: 500
        })

      expect { record.create_bib }.to raise_error(SierraVirtualRecordError)
    end

    describe '#create_item' do
      before(:each) do
        stub_request(:post, "#{ENV['SIERRA_URL']}/items")
          .to_return({
            body: {
              link: "https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/items/56789"
            }.to_json,
            status: 201,
            headers: { 'Content-type' => 'application/json;charset=UTF-8' }
          })
      end

      it 'attempts to create item via Sierra API' do
        record = SierraVirtualRecord.new({
          title: 'Bib title',
          author: 'Author',
          item_barcode: 12345,
          call_number: 'CALL number'
        })

        result = record.create_item
        expect(result).to eq(56789)
      end

      describe 'error' do
        before(:each) do
          stub_request(:post, "#{ENV['SIERRA_URL']}/items")
            .to_return({
              body: '',
              status: 500
            })
        end

        it 'throws SierraVirtualRecordError if creation failed' do
          record = SierraVirtualRecord.new({})

          expect { record.create_item }.to raise_error(SierraVirtualRecordError)
        end
      end
    end

    describe '#create' do
      before(:each) do
        stub_request(:post, "#{ENV['SIERRA_URL']}/items")
          .to_return({
            body: {
              link: "https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/items/56789"
            }.to_json,
            status: 201,
            headers: { 'Content-type' => 'application/json;charset=UTF-8' }
          })
      end

      it 'creates SierraVirtualRecord instance and posts bib & item data' do

        props = {
          title: 'Bib title',
          author: 'Author',
          item_barcode: 12345,
          call_number: 'CALL number'
        }
        result = SierraVirtualRecord.create props

        expect(result).to be_a(SierraVirtualRecord)
        expect(result.instance_variable_get(:@data)).to be_a(Hash)
        expect(result.instance_variable_get(:@data)[:title]).to eq('Bib title')
        expect(result.item_id).to eq(56789)

        expect(WebMock).to have_requested(:post, "#{ENV['SIERRA_URL']}/items").
          with(
            body: {
              "bibIds": [ 1234567 ],
              "itemType": 50,
              "location": "os",
              "barcodes": [ 12345 ],
              "callNumbers": [ 'CALL number' ]
            },
            headers: {'Content-Type' => 'application/json'}
          )
      end

      it 'creates SierraVirtualRecord instance without call number if call number absent' do

        props = {
          title: 'Bib title',
          author: 'Author',
          item_barcode: 12345
        }
        result = SierraVirtualRecord.create props

        expect(result).to be_a(SierraVirtualRecord)
        expect(result.item_id).to eq(56789)

        expect(WebMock).to have_requested(:post, "#{ENV['SIERRA_URL']}/items").
          with(
            body: {
              "bibIds": [ 1234567 ],
              "itemType": 50,
              "location": "os",
              "barcodes": [ 12345 ]
            },
            headers: {'Content-Type' => 'application/json'}
          )
      end
    end
  end
end
