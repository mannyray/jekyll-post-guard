require "pathname"

module LOCK
  class Generator < Jekyll::Generator
    def generate(site)
        print "gg"
        config = site.config
        lock_dir = config["lock_dir"]
        
        custom_locks = Pathname.new(lock_dir).children.select { |c| c.directory? }
        
        custom_locks.each{ |lock|
            # TODO - find all assets
            print lock
            
            #image_assets_intro = Pathname.new(File.join(lock_dir,lock,"intro")).children.select { |c| !c.directory }
            #print image_assets_intro
            
            site.static_files << Jekyll::StaticFile.new(site, site.source, '_locks/sudoku/intro', "cozy.jpg" )
            print lock
            print "GGG"
        }
    end
  end
end

#https://alphahydrae.com/2021/01/how-to-generate-and-enrich-pages-in-a-jekyll-blog/
#https://joshuahwang.dev/2021/06/28/image-resizing.html

