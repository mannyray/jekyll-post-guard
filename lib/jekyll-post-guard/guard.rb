require 'nokogiri'
require 'base64'

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
                html_text = $2
                #<!--lock:{data:directory}-->
                arguments = html_text.each_line.detect { |line| !line.strip.empty? }
                
                lock_html_copy = lock_html
                if arguments.include?("<!--lock:")
                    json_text = arguments[/<!--lock:(\{.*?\})-->/, 1]
                    parsed_data = JSON.parse(json_text) if json_text
                    #print parsed_data
                    custom_lock_dir = File.join(Jekyll.configuration({})['lock_dir'],parsed_data["data"])
                    intro_file_html = File.read( File.join(custom_lock_dir , "intro/lock.html" ))
                    
                    lock_assets = Dir.children(File.join(custom_lock_dir,"intro"))
                    # move the lock_assets to assets
                    
                    # should be http://localhost:4000 -> actual site URL and append lock directory
                    
                    lock_html_copy = intro_file_html.gsub("<img src=\"","<img src=\"http://localhost:4000/")
                end
                
                
                lock_html_sub = lock_html_copy.gsub("unlockBox", "unlockBox"+counter.to_s)
                
                # TODO: localhost
                
                
                
                obfuscated_html = Base64.strict_encode64(html_text)
                
                # TODO - in some sort of function
                lock_html_sub = lock_html_sub.sub("{/*replace*/}","{\
                          document.getElementById('locked-#{counter}').style.display = 'block';\
                          document.getElementById('lock-#{counter}').style.display = 'none';\
                          el = document.getElementById('locked-#{counter}');\
                          console.log(atob(\"#{obfuscated_html}\"));\
                          el.innerHTML = atob(\"#{obfuscated_html}\");\
                          console.log(window.location.origin);\
                    }")
                                         
                
                #function unlockBox() { document.getElementById('redBox').style.display = 'block';}

                
                #<script>
                #document.write(atob("PHA+dGhpcyBpcyBhIHRlc3Q8L3A+"));
                #</script>
                
                            
                lock_added = <<-HTML
                <div id="lock-#{counter}" class="lock_warning">
                #{lock_html_sub}
                </div>
                <div id="locked-#{counter}" class="locked_off">
                </div>
                HTML
            end
            return doc.to_html
        end
        
        
    end
end




# Register the filter
Liquid::Template.register_filter(Jekyll::LOCK)

