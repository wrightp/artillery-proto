require "mixlib/install"

CHANNELS = [ :stable, :unstable, :current ]

ENV["ARTIFACTORY_ENDPOINT"] = "https://packages-acceptance.chef.io"

data = [ ]

PRODUCT_MATRIX.products.each do |product|
  puts "for #{product}"
  CHANNELS.each do |channel|
    puts "  for #{channel}"
    opts = Mixlib::Install::Options.new(product_name: product, product_version: :latest, channel: channel)
    be = Mixlib::Install::Backend::Artifactory.new(opts)
    versions = be.available_versions
    versions.each do |version|
      puts "    for #{version}"
      data << [product, channel, version]
    end
  end
end

File.open("../artifact-info.csv", "w") do |file|
  data.each do |d|
    file.write "#{d.join(",")}\n"
  end
end
