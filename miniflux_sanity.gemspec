Gem::Specification.new do |s|
    s.name                        = 'miniflux_sanity'
    s.version                     = '0.2.1'
    s.required_ruby_version       = Gem::Requirement.new(">= 2.7.1")
    s.date                        = '2020-09-23'
    s.summary                     = "Mark items older than specified time as read in Miniflux."
    s.description                 = "Command line utility to mark items older than specified time as read in Miniflux."
    s.authors                     = ["hirusi"]
    s.email                       = 'hello@rusingh.com'
    s.license                     = 'AGPL-3.0'
    
    s.homepage                    = 'https://github.com/hirusi/miniflux-sanity'
    s.metadata["homepage_uri"]    = s.homepage
    s.metadata["source_code_uri"] = s.homepage

    # Specify which files should be added to the gem when it is released.
    # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
    s.files                       = Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
    s.bindir                      = "bin"
    s.executables                 = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
    s.require_paths               = ["lib"]
  end