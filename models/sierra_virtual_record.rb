require 'nypl_sierra_api_client'

require_relative 'kms'
require_relative 'errors'

class SierraVirtualRecord
  @@_sierra_client = nil

  attr_accessor :item_id, :bib_id

  def initialize(data)
    @data = data
  end

  ##
  # Create bib
  #
  # @return [int] bib id
  def create_bib
    props = {}

    props[:titles] = [@data[:title]] unless (@data[:title] || '').empty?
    props[:authors] = [@data[:author]] unless (@data[:author] || '').empty?
    # Add a 910 $a with 'RLOTF', identifying this bib as OTF (to keep it out of RC)
    props[:varFields] = [
      {
        :fieldTag => 'y',
        :marcTag => '910',
        :subfields => [ { :tag => 'a', :content => 'RLOTF' } ]
      }
    ]

    $logger.debug "Sierra API POST: bibs #{props.to_json}"
    response = self.class.sierra_client.post 'bibs', props

    raise SierraVirtualRecordError, 'Could not create temporary bib' unless response.success? && response.body.is_a?(Hash) && response.body['link']

    @bib_id = response.body['link'].split('/').last.to_i
    @bib_id
  end

  ##
  # Create item (and bib)
  #
  # @return [int] item id
  def create_item
    props = {
      bibIds: [create_bib],
      itemType: 50,
      location: 'os',
      barcodes: [@data[:item_barcode]],
    }
    props[:callNumbers] = [@data[:call_number]] unless (@data[:call_number] || '').empty?

    # Add an internal note identifying the partner item:
    unless @data[:item_nypl_source].nil? or @data[:item_id].nil?
      item_uri = "#{ENV['PLATFORM_API_BASE_URL']}/items/#{@data[:item_nypl_source]}/#{@data[:item_id]}"
      props[:internalNotes] = ["Original item: #{item_uri}"]
    end

    $logger.debug "Sierra API POST: items #{props.to_json}"
    response = self.class.sierra_client.post 'items', props

    raise SierraVirtualRecordError, 'Could not create temporary item' unless response.success? && response.body.is_a?(Hash) && response.body['link']

    @item_id = response.body['link'].split('/').last.to_i
    @item_id
  end

  ##
  # Create virtual record (item & bib)
  #
  # @param [Hash] data The hash of bib & item values
  #
  # @return [SierraVirtualRecord] instance of SierraVirtualRecord
  def self.create(data)
    inst = self.new(data)
    inst.create_item
    inst
  end

  ##
  # Create a SierraApiClient instance
  #
  # @return [SierraApiClient] instance of SierraApiClient
  def self.sierra_client
    if @@_sierra_client.nil?
      $logger.debug "Creating sierra_client"
      @@_sierra_client = SierraApiClient.new({
        base_url: "#{ENV['SIERRA_URL']}/",
        oauth_url: "#{ENV['SIERRA_URL']}/token",
        client_id: Kms.decrypt(ENV['ENCODED_SIERRA_ID']),
        client_secret: Kms.decrypt(ENV['ENCODED_SIERRA_SECRET']),
        log_level: 'error'
      })
    end

    @@_sierra_client
  end
end
