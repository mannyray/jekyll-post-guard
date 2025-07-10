require "pathname"

module LOCK
  class Generator < Jekyll::Generator
    def generate(site)
        config = site.config
        lock_dir = config["lock_dir"]
        
        custom_locks = Pathname.new(lock_dir).children.select { |c| c.directory? }
        
        custom_locks.each{ |lock|
            assets_intro = Pathname.new(File.join(lock_dir,lock,"intro")).find.select { |c| c.file? }
            assets_intro.each{ |path|
                site.static_files << Jekyll::StaticFile.new(site, site.source,path.dirname, path.basename )
            }
            
            assets_activity = Pathname.new(File.join(lock_dir,lock,"activity")).children.select { |c| not c.directory? }
            assets_activity.each{ |path|
                site.static_files << Jekyll::StaticFile.new(site, site.source,path.dirname, path.basename )
            }
        }
    end
  end
end
