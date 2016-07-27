require "mixlib/install"

CHANNELS = [ :stable, :unstable, :current ]

urls = [ ]

# slow but steady
# PRODUCT_MATRIX.products.each do |product|
#   puts "for #{product}"
#   CHANNELS.each do |channel|
#     puts "  for #{channel}"
#     opts = Mixlib::Install::Options.new(product_name: product, product_version: :latest, channel: channel)
#     be = Mixlib::Install::Backend::Artifactory.new(opts)
#     versions = be.available_versions
#     versions.each do |version|
#       puts "    for #{version}"
#       ver_opts = Mixlib::Install::Options.new(product_name: product, product_version: version, channel: channel)
#       urls << Mixlib::Install::Backend::Artifactory.new(ver_opts).info.first.url
#     end
#   end
# end

def map_properties(properties)
  return {} if properties.nil?
  properties.each_with_object({}) do |prop, h|
    h[prop["key"]] = prop["value"]
  end
end

ENV["MIXLIB_INSTALL_UNIFIED_BACKEND"] = "true"
ENV["ARTIFACTORY_ENDPOINT"] = "https://packages-acceptance.chef.io"

results = []
CHANNELS.each do |channel|
  opts = Mixlib::Install::Options.new(product_name: "chef", product_version: :latest, channel: channel)
  be = Mixlib::Install::Backend::Artifactory.new(opts)

  # TODO: It's possible to gather all omnibus artifacts with a repo match on omnibus-*-local
  # but when create_artifact is called it sets the channel to options.channel regardless of repo
  results = be.artifactory_query(<<-QUERY
items.find(
{"repo": "omnibus-#{channel}-local" },
{"name": {"$nmatch": "*.metadata.json" }}
).include("repo", "path", "name", "property")
QUERY
  )

  # Merge artifactory properties to a flat Hash
  results.collect! do |result|
    {
      "filename" => result["name"],
      # "channel" => result["repo"].match(/omnibus-(.*)-local/)[1]
    }.merge(
      map_properties(result["properties"])
    )
  end

  # Convert results to build records
  artifacts = results.map { |a| be.create_artifact(a) }

  urls << artifacts.collect do |a|
    a.url.gsub(/https:\/\/packages-acceptance.chef.io/, "")
  end
end

File.open("../downloads.csv", "w") do |file|
  file.puts urls
end
