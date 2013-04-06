task :default => :package

desc "Build iPod-last.fm bridge package"
task :package do
    project = "ipod_lastfm_bridge"
    files = FileList['Rakefile', 'README', '*.rb'].map{|fn| "#{project}/#{fn}"}
    version = Time.new.gmtime.strftime("%Y-%m-%d")

    fn_tar = "../website/packages/#{project}-#{version}.tar.gz"
    Dir.chdir("..") {
        sh "tar", "-z", "-c", "-f", "#{project}/#{fn_tar}", *files
    }
end

desc "Clean generated files"
task :clean do
    # Nothing to clean
end

desc "Run all tests (none at the moment, sorry)"
task :test do
    # No automatic test implemented yet
end
