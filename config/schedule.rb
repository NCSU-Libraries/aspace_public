# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

# every 1.hours do
#   command "echo 'TEST'"
# end


if @environment == 'production'

  every "0 6-22 * * 1-5" do
    rake "aspace_import:delta"
  end

  every "15 6-22 * * 1-5" do
    rake "aspace_import:purge_deleted"
  end

  every "30 6-22 * * 1-5" do
    rake "search_index:delta"
  end

  every "0 0 * * 6" do
    rake "aspace_import:full"
  end

  every "0 0 * * 7" do
    rake "search_index:full"
  end

  every "0 0 * * 1" do
    rake "aspace_import:truncate_imports_table"
  end

end
