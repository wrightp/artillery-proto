require "mixlib/install"

CHANNELS = [ :stable, :unstable, :current ]

ENV["ARTIFACTORY_ENDPOINT"] = "https://packages-acceptance.chef.io"

data = [ ]

PRODUCT_MATRIX.products.each do |product|
  puts "for #{product}"
  CHANNELS.each do |channel|
    puts "  for #{channel}"
    data << [product, channel]
  end
end

File.open("../poller.csv", "w") do |file|
  data.each do |d|
    file.write "#{d.join(",")}\n"
  end
end
