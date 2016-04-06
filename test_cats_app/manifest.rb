require 'byebug'

Dir[Dir.pwd + '/lib/*.rb'].each { |file| require file }
Dir[Dir.pwd + '/test_cats_app/models/*.rb'].each { |file| require file }
Dir[Dir.pwd + '/test_cats_app/controllers/*.rb'].each { |file| require file }
Dir[Dir.pwd + '/test_cats_app/views/*.rb'].each { |file| require file }
