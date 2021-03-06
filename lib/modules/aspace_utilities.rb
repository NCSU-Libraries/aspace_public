module AspaceUtilities

  def self.included receiver
    receiver.extend self
  end

  # Simple utility allow ASpace response data to be passed to methods as either
  # JSON (directly from API response) or Hash (when included as a linked record
  # in another response which has already been parsed)
  # Both formats (JSON and Hash) are returned, and the host method
  # must determine which to use for specific purposes
  # Params:
  # +data+:: API response, either as JSON or parsed as a Ruby hash
  def prepare_data(data)
    case data
    when Hash
      hash = ActiveSupport::HashWithIndifferentAccess.new(data)
      prepared_data = { :hash => hash, :json => JSON.generate(data) }
    when String
      hash = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(data))
      prepared_data = { :json => data, :hash =>  hash }
    end
    prepared_data
  end


  # remove all objects from arrays (and nested arrays) for which 'publish' is false
  # Params:
  # +array+:: Array of ArchivesSpace objects (of any class) as a Ruby hash
  def remove_unpublished(array)
    array.each do |x|
      case x
      when Hash
        if x['publish'] === false
          array.delete(x)
        end
      when Array
        remove_unpublished(x)
      end
    end
    array
  end

end
