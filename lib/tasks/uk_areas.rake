# encoding: utf-8

namespace :uk_areas do

  desc "Load area polygons"
  task :parse => :environment do
    hash = get_hash()

    hash['features'].each do |f|
      koatuu = f['properties']['koatuu']
      next if koatuu.blank?

      puts koatuu

      town = Town.find_by koatuu: koatuu

      geometry_type = f['geometry']['type']
      coordinates = []

      divider = 20

      case geometry_type
        when 'MultiPolygon'
          f['geometry']['coordinates'].each_with_index do |m, l|
            coordinates << []
            m[0].each_with_index do |c, i|
              coordinates[l] << [c[1], c[0]] if i % divider == 0
            end
          end
        when 'Polygon'
          f['geometry']['coordinates'][0].each_with_index do |c, i|
            coordinates << [c[1], c[0]] if i % divider == 0
          end
      end

      puts "#{f['geometry']['coordinates'][0].count} #{coordinates.count}"

      town.update(geometry_type: geometry_type, coordinates: [ coordinates ])
    end
  end

  def get_hash

    file = File.read('db/uk_map_areas.geojson')
    data_hash = JSON.parse(file)
    data_hash
  end
end