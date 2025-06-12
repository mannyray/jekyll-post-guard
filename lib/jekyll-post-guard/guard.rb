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
                #to_be_locked = Nokogiri::HTML(html_text)
                
                lock_html_copy = lock_html
                lock_html_sub = lock_html_copy.gsub("unlockBox", "unlockBox"+counter.to_s)
                
                
                obfuscated_html = Base64.strict_encode64(html_text)
                
                lock_html_sub = lock_html_sub.sub("{/*replace*/}","{\
                          document.getElementById('locked-#{counter}').style.display = 'block';\
                          document.getElementById('lock-#{counter}').style.display = 'none';\
                          el = document.getElementById('locked-#{counter}');\
                          console.log(atob(\"#{obfuscated_html}\"));\
                          el.innerHTML = atob(\"#{obfuscated_html}\");\
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

