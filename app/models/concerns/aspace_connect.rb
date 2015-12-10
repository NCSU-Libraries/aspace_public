require 'active_support/concern'

module AspaceConnect
  extend ActiveSupport::Concern

  included do
    require 'archivesspace-api-utility/helpers'
    include AspaceUtilities
    include ArchivesSpaceApiUtility
    include ArchivesSpaceApiUtility::Helpers


    # Class method - If record of this class exists with given URI, update it from the API,
    # otherwise create a record of this class from data returned from URI
    # Params:
    # +uri+:: An ArchivesSpace URI associated with a single record
    # +options+:: Options passed from another method to be passed downstream
    def self.create_or_update_from_api(uri, options={})
      record = find_by_uri(uri)
      if record
        record.update_from_api(options)
      else
        record = create_record_from_api(uri, options)
      end
      record
    end


    def self.get_data_from_api(uri, options={})
      resolve_linked_records = options[:resolve_linked_records] || true
      session = options[:session] || ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      response = resolve_linked_records ? session.get(uri, resolve: ['linked_agents','subjects']) : session.get(uri)
      if response.code.to_i == 200
        data = prepare_data(response.body)
        return (options[:format] == :json) ? data[:json] : data[:hash]
      else
        nil
      end
    end


    # Class method - If record of this class exists with URI equal to that included in data,
    # update it from the API, otherwise create a record of this class from data returned from URI
    # Params:
    # +data+:: An ArchivesSpace response (JSON or Ruby)
    # +options+:: Options passed from another method to be passed downstream
    def self.create_or_update_from_data(data, options={})
      d = prepare_data(data)
      # r, json = d[:hash], d[:json]
      r = d[:hash]
      uri = r['uri']
      record = where(uri: uri).first
      if record
        puts "#{uri} exists. Updating from response data"
        record.update_from_data(data,options)
      else
        puts "Creating new record from response data for #{uri}"
        record = create_from_data(data,options)
      end
      record.reload
      record
    end


    # Class method - Create a record of this class from data returned from URI
    # Params:
    # +uri+:: An ArchivesSpace URI associated with a single record
    # +options+:: Options passed from another method to be passed downstream
    def self.create_record_from_api(uri, options={})
      resolve_linked_records = options[:resolve_linked_records] || true
      session = options[:session] || ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      response = resolve_linked_records ? session.get(uri, resolve: ['linked_agents','subjects']) : session.get(uri)
      if response.code.to_i == 200
        create_from_data(response.body,options)
      else
        raise response.body
      end
    end



    # Updates the record from the ArchivesSpace API
    # Params:
    # +options+:: Options passed from another method to be passed downstream (may include an active API session)
    def update_from_api(options={})
      session = options[:session] || ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      response = session.get(self.uri, resolve: ['linked_agents','subjects'])
      if response.code.to_i == 200
        self.update_from_data(response.body,options)
      else
        raise response.body
      end
    end


  end

end
