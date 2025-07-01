require 'nokogiri'
require 'base64'

module Jekyll
	module LOCK
		def lock(text)
            plugin_dir = File.join(Jekyll.configuration({})['plugins_dir'],"jekyll-post-guard")
            
            styling_html_content_text = File.read( File.join(plugin_dir,"style.html" ))
            header_html_content_text = File.read( File.join(plugin_dir,"header.html" ))
            
            
            text = header_html_content_text + styling_html_content_text + text
			doc = Nokogiri::HTML(text)
            counter = 0
			doc.inner_html = doc.inner_html.gsub(/(<!--lock_start-->)(.*?)(<!--lock_end-->)/m) do |match|
                counter = counter + 1
                html_text = $2
                #<!--lock:{data:directory}-->
                arguments = html_text.each_line.detect { |line| !line.strip.empty? }
                
                lock_html_copy = ""
                activity_html = ""
                if arguments.include?("<!--lock:") # should always be included - check?
                    json_text = arguments[/<!--lock:(\{.*?\})-->/, 1]
                    parsed_data = JSON.parse(json_text) if json_text
                    #print parsed_data
                    custom_lock_dir = File.join(Jekyll.configuration({})['lock_dir'],parsed_data["data"])
                    
                    intro_file_html = File.read( File.join(custom_lock_dir , "intro/lock.html" ))
                    lock_assets_dir = File.join(custom_lock_dir,"intro")
                    # move the lock_assets to assets
                    lock_html_copy = intro_file_html.gsub("<img src=\"","<img src=\"/"+lock_assets_dir+"/")
                    
                    activity_html = File.read( File.join(custom_lock_dir , "activity/activity.html" ))
                end
                
                # counters, in case you have multiple locks
                lock_html_sub = lock_html_copy.gsub("unlockBox", "unlockBox"+counter.to_s)
                                
                
                
                obfuscated_html = Base64.strict_encode64(html_text)
                
                lock_html_sub = lock_html_sub.sub("{/*replace*/}","{\
                          document.getElementById('activity-#{counter}').style.display = 'block';\
                          document.getElementById('lock-#{counter}').style.display = 'none';\
                    }")
                    
                activity_html_sub = activity_html.sub("{/*replace*/}","{\
                          document.getElementById('locked-#{counter}').style.display = 'block';\
                          document.getElementById('activity-#{counter}').style.display = 'none';\
                          el = document.getElementById('locked-#{counter}');\
                          el.innerHTML = atob(\"#{obfuscated_html}\");\
                    }")
                activity_html_sub = activity_html_sub.gsub("unlock_content_button","disabled_button-#{counter}")
                        
                lock_added = <<-HTML
                <div id="lock-#{counter}" class="lock_warning">
                #{lock_html_sub}
                </div>
                <div id="activity-#{counter}" class="lock_activity">
                #{activity_html_sub}
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

