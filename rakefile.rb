begin
    require("./gubg.build/shared.rb")
rescue LoadError
    puts("This seems to be a fresh clone: I will update all required submodules for you.")
    sh "git submodule update --init"
    retry
end

task :default do
    sh "rake -T"
end

namespace :cook do
    exe = nil
    task :init do
        require("gubg/build/Executable")
        exe = Build::Executable.new("cook")
        exe.add_sources(FileList.new("src/**/*.cpp"))
        exe.add_include_path("src")
        %w[std io].each{|e|exe.add_include_path("gubg.#{e}/src")}
        case :debug
        when :debug
            exe.add_option('g')
        else
            exe.add_define('NDEBUG')
        end
    end
    task :clean do
        rm_rf(".cache")
    end
    task :build => :init do
        exe.build
    end
    task :run => :init do
        exe.run
    end
end
desc "Builds cook"
task :build => "cook:build"
desc "Tests cook"
task :test => ["cook:clean", "cook:build", "cook:run"]

desc "Updates all submodules the their respective heads"
task :uth do
    %w[build std io chaiscript].each do |part|
        Dir.chdir("gubg.#{part}") do
            sh "git checkout master"
            sh "git pull --rebase"
        end
    end
end