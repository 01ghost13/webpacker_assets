require 'json'
require 'yaml'
require 'webpacker'

module WebpackerAssets
  class GemPathResolver
    def initialize(env, webpacker_file)
      @gems = parse_webpacker(env, webpacker_file)
    end

    def to_json
      JSON.dump(gems: resolve_gems(@gems))
    end

    private
      def resolve_gem_path(gem)
        return if gem.blank?
        gem_path = Gem.loaded_specs[gem]&.full_gem_path
        if gem_path.present?
          gem_path
        else
          abort("Gem '#{gem}' not found, please check webpacker config")
        end
      end

      def resolve_gems(config)
        config.reduce([]) do |result, (gem_name, paths_to_assets)|
          gem_full_path = resolve_gem_path(gem_name)
          next if gem_full_path.blank?

          paths_to_assets.each do |path_to_assets|
            last_folder_name = File.basename(path_to_assets)
            entry_key_name = "#{gem_name}/#{last_folder_name}"

            full_asset_path = File.expand_path(path_to_assets, gem_full_path)

            unless Dir.exist?(full_asset_path)
              abort("Dir #{full_asset_path} not found")
            end

            result.push({ gem_name: entry_key_name, gem_path: full_asset_path })
          end
          result
        end
      end

      def parse_webpacker(env, webpacker_file)
        config = YAML.load(webpacker_file)

        config.dig(env, 'resolved_gems')
      end
  end
end

