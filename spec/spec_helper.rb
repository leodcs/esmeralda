Dir['./lib/config/**/*.rb'].sort.each { |config| require config }
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }
Dir['./spec/shared_contexts/*.rb'].each { |context| require context }
require './lib/scanner'
require './lib/parser'
require './lib/semantic'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec.status'
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
