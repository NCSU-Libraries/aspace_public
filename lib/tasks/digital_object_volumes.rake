namespace :digital_object_volumes do

  desc "create digital_object_volume"
  task :create, [:digital_object_id, :position, :filesystem_browse_url] => :environment do |t, args|
    options = {
      digital_object_id: args[:digital_object_id].to_i,
      position: args[:position].to_i,
      filesystem_browse_url: args[:filesystem_browse_url]
    }
    puts options.inspect
    d = DigitalObjectVolume.find_or_create_by(options)
    puts d.inspect
  end

end
