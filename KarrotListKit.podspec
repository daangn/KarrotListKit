Pod::Spec.new do |spec|
  spec.name         = 'KarrotListKit'
  spec.version      = ENV['LIB_VERSION'] || '0.1.0'
  spec.summary      = 'High-performance list rendering library for iOS.'
  spec.homepage     = 'https://github.com/daangn/KarrotListKit'
  spec.license      = { type: 'Apache 2', file: 'LICENSE' }
  spec.authors = 'Karrot'
  spec.source = { git: 'https://github.com/daangn/KarrotListKit.git', tag: spec.version.to_s }

  spec.source_files = 'Sources/**/*.{swift,h,m}'

  spec.dependency 'DifferenceKit', '~> 1.0'
  spec.dependency 'Then', '~> 3.0'
end
