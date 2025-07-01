require "pathname"

module LOCK
  class Generator < Jekyll::Generator
    def generate(site)
        config = site.config
        lock_dir = config["lock_dir"]
        
        custom_locks = Pathname.new(lock_dir).children.select { |c| c.directory? }
        
        custom_locks.each{ |lock|
            assets_intro = Pathname.new(File.join(lock_dir,lock,"intro")).children.select { |c| not c.directory? }
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

#https://alphahydrae.com/2021/01/how-to-generate-and-enrich-pages-in-a-jekyll-blog/
#https://joshuahwang.dev/2021/06/28/image-resizing.html
#https://mademistakes.com/mastering-jekyll/static-files/#fnref:1

#https://alexwlchan.net/2023/picture-plugin/
#https://jetholt.com/archive/
#http://emcken.dk/programming/2024/05/24/optimize-images-for-jekyll-using-tinypng/

#https://www.bfoliver.com/2020/jekyll-image-loading


#
