require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'celerb' do
  self.developer 'Dusan Maliarik', 'dusan.maliarik@gmail.com'
  self.rubyforge_name = self.name # TODO this is default value
  self.extra_deps     = [
    ['amqp',   '= 0.6.7'],
    ['msgpack','= 0.4.3']
  ]

end

