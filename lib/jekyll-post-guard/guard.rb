require 'nokogiri'

module Jekyll
	module LOCK
		def lock(text)
            plugin_dir = File.join(Jekyll.configuration({})['plugins_dir'],"jekyll-post-guard")
            styling_html_content_text = File.read( File.join(plugin_dir,"style.html" ))
            header_html_content_text = File.read( File.join(plugin_dir,"header.html" ))
            lock_html = File.read( File.join(plugin_dir,"lock.html" ))
            text = header_html_content_text + styling_html_content_text + text
			doc = Nokogiri::HTML(text)
            counter = 0
			doc.inner_html = doc.inner_html.gsub(/(<!--lock_start-->)(.*?)(<!--lock_end-->)/m) do |match|
                counter = counter + 1
                to_be_locked = Nokogiri::HTML($2)
                
                lock_html_copy = lock_html
                lock_html_sub = lock_html_copy.gsub("unlockBox", "unlockBox"+counter.to_s)
                
                lock_html_sub = lock_html_sub.sub("{ document.getElementById('redBox').style.display = 'block';}","{ document.getElementById('locked-#{counter}').style.display = 'block'; document.getElementById('lock-#{counter}').style.display = 'none';}")
                
                #function unlockBox() { document.getElementById('redBox').style.display = 'block';}

            
                lock_added = <<-HTML
                <div id="lock-#{counter}" class="lock_warning">
                #{lock_html_sub}
                </div>
                <div id="locked-#{counter}" class="locked_off">
                #{to_be_locked}
                </div>
                HTML
            end
            return doc.to_html
        end
    end
end




# Register the filter
Liquid::Template.register_filter(Jekyll::LOCK)

