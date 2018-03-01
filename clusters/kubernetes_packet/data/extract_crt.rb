require 'optparse'
require 'yaml'
require 'base64'

options = {
  config_path: File.join(ENV['HOME'], '.kube', 'config'),
  write_dir: File.join(ENV['HOME'], '.kube')
}

OptionParser.new do |opts|
  opts.banner = "Usage: extract_crt.rb [options]"

  opts.on('-s', '--source FILE_PATH', 'Path to the kube config') { |v| options[:config_path] = v }
  opts.on('-d', '--destination DIR', 'Path to directory where save key and certs') { |v| options[:write_dir] = v }

end.parse!

kube_path = options[:write_dir]
file_config = File.read options[:config_path]
config = YAML.load file_config

ca = Base64.decode64 config["clusters"][0]["cluster"]["certificate-authority-data"]
File.open(File.join(kube_path, 'ca.crt'), File::CREAT|File::TRUNC|File::RDWR, 0644) do |f|
  f.write(ca)
end

client_crt = Base64.decode64 config["users"][0]["user"]["client-certificate-data"]
File.open(File.join(kube_path, 'kubecfg.crt'), File::CREAT|File::TRUNC|File::RDWR, 0644) do |f|
  f.write(client_crt)
end

client_key = Base64.decode64 config["users"][0]["user"]["client-key-data"]
File.open(File.join(kube_path, 'kubecfg.key'), File::CREAT|File::TRUNC|File::RDWR, 0644) do |f|
  f.write(client_key)
end
