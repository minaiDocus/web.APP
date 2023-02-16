module SoftwareMod
  module Export; end
end

#require extended module
  Dir.glob("#{Rails.root}/app/mods/software/models/concerns/*.rb").each { |file| require file }

Dir.glob("#{Rails.root}/app/mods/software/services/*/*.rb").each { |file| require file }

Dir.glob("#{Rails.root}/app/mods/software/services/export/softwares/*.rb").each { |file| require file }