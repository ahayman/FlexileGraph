Pod::Spec.new do |s|
    s.name = 'FlexileGraph'
    s.version = '0.0.1'
    s.homepage = 'https://github.com/ahayman/FlexileGraph'
    s.summary = 'A Simple and fast graphing framework'
    s.description = <<-DESC
    A simple and (hopefully) fast graphing framework. At the moment, this is not intended for use in anything that remotely resembles production. It's my first attempt at a graphing framework.
    DESC
    s.author = {
        'Aaron Hayman' => 'aaron@flexile.co'
    }
    s.license = 'MIT'
    s.source = {
        :git => 'https://github.com/ahayman/FlexileGraph.git',
        :tag => s.version.to_s
    }
    s.source_files = 'FlexileGraph/*.{h,m}'
    s.platform = :ios, '5.1'
    s.requires_arc = true
end
