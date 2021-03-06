module GuideboxWrapper
	class Tv
		attr_reader :id, :title, :alternative_titles, :status, :first_aired, :network, :channels, :runtime, :genres, :tags, :cast, :overview, :air_day_of_week, :air_time, :rating, :imdb_id, :tvdb, :themoviedb, :freebase, :tv_com, :metacritic, :wikipedia_id, :tvrage, :fanart, :poster, :banner, :url, :artwork, :social
		attr_accessor :seasons, :season_total, :related, :posters, :banners, :thumbnails, :backgrounds

		def initialize(show_info)
			excluded_keys = ["common_sense_media", "type", "artwork_208x117", "artwork_304x171", "artwork_448x252", "artwork_608x342"]
			show_info.each do |key, value|
				unless excluded_keys.include?(key)
					instance_variable_set("@#{key}", value)
				end
			end
			@facebook_link = show_info["social"]["facebook"]["link"]
			@artwork = { "artwork_208x117" => show_info["artwork_208x117"], "artwork_304x171" => show_info["artwork_304x171"], "artwork_448x252" => show_info["artwork_448x252"], "artwork_608x342" => show_info["artwork_608x342"] }
		end

		def images=(api_key)
			if @posters == nil
				wrapper = set_base_url(api_key)
				url = wrapper.base_url + "/show/" + @id.to_s + "/images/all"
      			images = wrapper.client.query(url)["results"]
      			@posters = images["posters"]
		    	@backgrounds = images["backgrounds"]
		    	@banners = images["banners"]
		    	@thumbnails = images["thumbnails"]
			end
		end

		def seasons=(api_key)
			if @seasons == nil
				wrapper = set_base_url(api_key)
				url = wrapper.base_url + "/show/" + @id.to_s + "/seasons"
      			results = wrapper.client.query(url)
      			@seasons = results["results"]
      			@season_total = results["total_results"]
			end
		end

		def sources=(api_key)
			unless @sources != nil
				@sources = get_data(api_key, "sources")
			end
		end

		def related=(api_key)
			unless @related != nil
      			@related = get_data(api_key, "related")
			end
		end

		def web_sources
			@sources == nil ? "You need to call sources=(api_key) first" : @sources["web"]
		end

		def ios_sources
			@sources == nil ? "You need to call sources=(api_key) first" : @sources["ios"]
		end

		def android_sources
			@sources == nil ? "You need to call sources=(api_key) first" : @sources["android"]
		end

		def free_sources
			if @sources != nil
				add_sources("free")
			else
				"You need to call sources=(api_key) first"
			end
		end

		def subscription_sources
			if @sources != nil
				add_sources("subscription")
			else
				"You need to call sources=(api_key) first"
			end
		end

		def purchase_sources
			if @sources != nil
				add_sources("purchase")
			else
				"You need to call sources=(api_key) first"
			end
		end

		def small_artwork
			@artwork["artwork_208x117"]
		end

		def medium_artwork
			@artwork["artwork_304x171"]
		end

		def large_artwork
			@artwork["artwork_448x252"]
		end

		def xlarge_artwork
			@artwork["artwork_608x342"]
		end

		private 

		def add_sources(type)
			x = []
			web_sources["episodes"]["all_sources"].each { |source| x << (source.merge({ "type" => "web" })) if source["type"] == type }
			ios_sources["episodes"]["all_sources"].each { |source| x << (source.merge({ "type" => "ios" })) if source["type"] == type }
			android_sources["episodes"]["all_sources"].each { |source| x << (source.merge({ "type" => "android" })) if source["type"] == type }
			x
		end

		def set_base_url(api_key)
			wrapper = GuideboxWrapper::GuideboxTv.new(api_key, "all")
			wrapper
		end

		def get_data(api_key, type)
			wrapper = set_base_url(api_key)
			case type
			when "sources"
				url = wrapper.base_url + "/show/" + @id.to_s + "/available_content"
			when "related"
				url = wrapper.base_url + "/show/" + @id.to_s + "/related"
			end
      		wrapper.client.query(url)["results"]
		end
	end
end