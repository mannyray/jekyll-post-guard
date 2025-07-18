require 'nokogiri'
require 'base64'

DEFAULT_FADE_TIME = 4

module Jekyll
	module LOCK
		def lock(text)
            plugin_dir = File.join(Jekyll.configuration({})['plugins_dir'],"jekyll-post-guard")
            
            styling_html_content_text = File.read( File.join(plugin_dir,"style.html" ))
            
            text = styling_html_content_text + text
			doc = Nokogiri::HTML(text)
            counter = 0
			doc.inner_html = doc.inner_html.gsub(/(<!--lock_start-->)(.*?)(<!--lock_end-->)/m) do |match|
                counter = counter + 1
                html_text = $2
                #<!--lock:{data:directory}-->
                arguments = html_text.each_line.detect { |line| !line.strip.empty? }
                
                lock_html_copy = ""
                activity_html = ""
                
                fade_time = DEFAULT_FADE_TIME
                if arguments.include?("<!--lock:") # should always be included - check?
                    json_text = arguments[/<!--lock:(\{.*?\})-->/, 1]
                    parsed_data = JSON.parse(json_text) if json_text
                    #print parsed_data
                    custom_lock_dir = File.join(Jekyll.configuration({})['lock_dir'],parsed_data["data"])
                    
                    if parsed_data["fade_time"]
                        fade_time = parsed_data["fade_time"]
                    end
                    
                    intro_file_html = File.read( File.join(custom_lock_dir , "intro/lock.html" ))
                    lock_intro_assets_dir = File.join(custom_lock_dir,"intro")
                    # move the lock_assets to assets
                    lock_html_copy = intro_file_html.gsub(/src="(?!https?:\/\/)/," src=\"/"+lock_intro_assets_dir+"/")
                    lock_html_copy = lock_html_copy.gsub(/href="(?!https?:\/\/)/," href=\"/"+lock_intro_assets_dir+"/")
                    
                    lock_activity_assets_dir = File.join(custom_lock_dir,"activity")
                    activity_html = File.read( File.join(custom_lock_dir , "activity/activity.html" ))
                    activity_html = activity_html.gsub(/src="(?!https?:\/\/)/," src=\"/"+lock_activity_assets_dir+"/")
                    activity_html = activity_html.gsub(/href="(?!https?:\/\/)/," href=\"/"+lock_activity_assets_dir+"/")
                end
                
                # counters, in case you have multiple locks
                lock_html_sub = lock_html_copy.gsub("unlockBox", "unlockBox"+counter.to_s)
                                
                
                obfuscated_html = html_text
                
                lock_html_sub = lock_html_sub.sub("{/*replace*/}","{\
                          document.getElementById('activity-#{counter}').style.display = 'block';\
                          document.getElementById('lock-#{counter}').style.display = 'none';\
                    }")

                activity_html_sub = activity_html.sub("{/*replace*/}","{\
                        const content = document.getElementById('locked-#{counter}');\
                        content.style.display = 'block';\
                        void content.offsetWidth;\
                        content.style.opacity = \"1\";\
                        document.getElementById('activity-#{counter}').style.display = 'none';\
                    }")
                activity_html_sub = activity_html_sub.gsub("unlock_content_button","disabled_button-#{counter}")
                        
                lock_added = <<-HTML
                <div id="locked-#{counter}" class="locked_off" style="transition: opacity #{fade_time}s ease;">
                #{html_text}
                </div>
                <div id="activity-#{counter}" class="lock_activity">
                #{activity_html_sub}
                </div>
                <div id="lock-#{counter}" class="lock_warning">
                #{lock_html_sub}
                </div>
                
                HTML
            end
            return doc.to_html
        end
    end
end

# Register the filter
Liquid::Template.register_filter(Jekyll::LOCK)
