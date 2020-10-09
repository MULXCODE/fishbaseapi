require_relative 'base'

module SpModels
  def self.models
    constants.select { |c| const_get(c).is_a?(Class) }
  end

  class Species < Base
    self.primary_key = 'SpecCode'
  end
end


module Models
  def self.models
    constants.select { |c| const_get(c).is_a?(Class) }
  end

  def self.list_fields(db)
    #TODO we should pass regexp to DB instead of returning all columns every time
    query = "SELECT table_name, column_name FROM information_schema.`columns` WHERE table_schema = '#{db}';"
    ActiveRecord::Base.connection.execute(query).map { |row| { table_name: row.first, column_name: row.last } }
  end

  class Classes < Base; end
  class Comnames < Base; end
  class Country < Base; end
  class Countrysub < Base; end
  class Countrysubref < Base; end
  class Countref < Base; end
  class Ecology < Base; end
  class Ecosystemref < Base; end
  class Fecundity < Base; end
  class Fooditems < Base; end
  class Intrcase < Base; end
  class Larvae < Base; end
  class Listfields < Base; end
  class Matrix < Base; end
  class Maturity < Base; end
  class Morphdat < Base; end
  class Morphmet < Base; end
  class Myersdata < Base; end
  class Myersrecruitmentdatabase < Base; end
  class Maturity < Base; end
  class Orders < Base; end
  class Oxygen < Base; end
  class Popchar < Base; end
  class Popgrowth < Base; end
  class Poplf < Base; end
  class Popll < Base; end
  class Popqb < Base; end
  class Poplw < Base; end
  class Predats < Base; end
  class Ration < Base; end
  class Refrens < Base; end
  class Reproduc < Base; end
  class Spawning < Base; end
  class Speed < Base; end
  class Stocks < Base; end
  class Swimming < Base; end
  class Synonyms < Base; end

  class Disref < Base
    self.primary_key = 'DisCode'
  end

  class Faoareas < Base
    self.primary_key = 'AreaCode'
  end

  class Faoarref < Base
    self.primary_key = 'AreaCode'
  end

  class Genera < Base
    self.primary_key = 'GenCode'
  end

  # class Species < Base
  #   self.primary_key = 'SpecCode'
  # end

  class Eggs < Base
    self.primary_key = 'Speccode'
  end

  class Eggdev < Base
    self.primary_key = 'SpecCode'
  end

  class Estimate < Base
    self.primary_key = 'SpecCode'
  end

  class Families < Base
    self.primary_key = 'FamCode'
  end

  class Taxa < Base
    self.table_name = 'species'
    self.primary_key = 'SpecCode'

    def self.endpoint(params)
      params.delete_if { |k, v| v.nil? || v.empty? }

      if !$route.match('sealifebase').nil?
        str = 'species.Genus = genera.GEN_NAME'
      else
        str = 'species.GenCode = genera.GenCode'
      end

      %i(limit offset).each do |p|
        unless params[p].nil?
          begin
            params[p] = Integer(params[p])
          rescue ArgumentError
            raise Exception.new("#{p.to_s} is not an integer")
          end
        end
      end
      raise Exception.new('limit too large (max 5000)') unless (params[:limit] || 0) <= 5000

      fields = %w(species.SpecCode species.Genus species.Species species.SpeciesRefNo species.Author
                  species.FBname species.SubFamily species.FamCode
                  species.Remark families.Family families.Order families.Class)
      if $route.match('sealifebase').nil?
        fields << 'species.GenCode'
        fields << 'species.SubGenCode'
      end
      if params[:id]
        select(fields.join(', '))
            .joins('INNER JOIN families on species.FamCode = families.FamCode')
            .joins('INNER JOIN genera on ' + str)
            .where(primary_key => params[:id])
            .limit(params[:limit] || 10)
            .offset(params[:offset])
      else
        params2 = params.dup
        params.delete(:Species)
        params.delete(:Genus)
        select(fields.join(', '))
            .joins('INNER JOIN families on species.FamCode = families.FamCode')
            .joins('INNER JOIN genera on ' + str)
            .where("species.Species LIKE :sp", sp: "%#{params2[:Species]}%")
            .where("species.Genus LIKE :ge", ge: "%#{params2[:Genus]}%")
            .limit(params[:limit] || 10)
            .offset(params[:offset])
      end
    end
  end

  # class Images < Base
  #   self.table_name = 'species'
  # end

  class Ecosystem < Base
    self.table_name = 'ecosystem'

    def self.endpoint(params)
      params.delete_if { |k, v| v.nil? || v.empty? }

      %i(limit offset).each do |p|
        unless params[p].nil?
          begin
            params[p] = Integer(params[p])
          rescue ArgumentError
            raise Exception.new("#{p.to_s} is not an integer")
          end
        end
      end
      raise Exception.new('limit too large (max 5000)') unless (params[:limit] || 0) <= 5000

      fieldstoget = %w(ecosystem.autoctr ecosystem.E_CODE ecosystem.EcosystemRefno ecosystem.Speccode
        ecosystem.Stockcode ecosystem.Status ecosystem.Abundance ecosystem.LifeStage
        ecosystem.Remarks ecosystem.Entered ecosystem.Dateentered ecosystem.Modified
        ecosystem.Datemodified ecosystem.Expert ecosystem.Datechecked ecosystem.WebURL
        ecosystem.TS ecosystemref.E_CODE ecosystemref.EcosystemName ecosystemref.EcosystemType
        ecosystemref.Location ecosystemref.Salinity ecosystemref.RiverLength ecosystemref.Area
        ecosystemref.SizeRef ecosystemref.DrainageArea ecosystemref.NorthernLat ecosystemref.NrangeNS
        ecosystemref.SouthernLat ecosystemref.SrangeNS ecosystemref.WesternLat ecosystemref.WrangeEW
        ecosystemref.EasternLat ecosystemref.ErangeEW ecosystemref.Climate ecosystemref.AverageDepth
        ecosystemref.MaxDepth ecosystemref.DepthRef ecosystemref.TempSurface ecosystemref.TempSurfaceMap
        ecosystemref.TempDepth ecosystemref.Description ecosystemref.EcosystemURL1
        ecosystemref.EcosystemURL2 ecosystemref.EcosystemURL3 ecosystemref.Entered ecosystemref.DateEntered
        ecosystemref.Modified ecosystemref.DateModified ecosystemref.Expert ecosystemref.DateChecked)

      fields = columns.map(&:name)

      select(fieldstoget.join(', '))
          .joins('INNER JOIN ecosystemref on ecosystem.E_CODE = ecosystemref.E_CODE')
          .where(params.select { |param| fields.any? { |s| s.to_s.casecmp(param.to_s)==0 } })
          .limit(params[:limit] || 10)
          .offset(params[:offset])
    end
  end

  class Diet < Base
    self.table_name = 'diet'

    def self.endpoint(params)
      params.delete_if { |k, v| v.nil? || v.empty? }

      %i(limit offset).each do |p|
        unless params[p].nil?
          begin
            params[p] = Integer(params[p])
          rescue ArgumentError
            raise Exception.new("#{p.to_s} is not an integer")
          end
        end
      end
      raise Exception.new('limit too large (max 5000)') unless (params[:limit] || 0) <= 5000

      fieldstoget = %w(diet_items.DietCode diet_items.FoodI diet_items.FoodII diet_items.FoodIII diet_items.Stage
        diet_items.DietPercent diet_items.ItemName diet_items.Comment diet_items.DietSpeccode
        diet_items.AlphaCode diet_items.PreyTroph
        diet_items.PreySeTroph diet_items.PreyRemark
        diet.DietCode diet.StockCode diet.Speccode
        diet.DietRefNo diet.SampleStage diet.SampleSize diet.YearStart diet.YearEnd
        diet.January diet.February diet.March diet.April diet.May
        diet.June diet.July diet.August diet.September diet.October
        diet.November diet.December diet.C_Code diet.Locality diet.E_Code
        diet.Method diet.MethodType diet.Remark diet.OtherItems diet.PercentEmpty
        diet.Troph diet.seTroph diet.SizeMin diet.SizeMax diet.SizeType
        diet.FishLength diet.Entered diet.DateEntered diet.Modified
        diet.DateModified diet.Expert diet.DateChecked )

      fields = columns.map(&:name)

      select(fieldstoget.join(', '))
          .joins('INNER JOIN diet_items on diet.DietCode = diet_items.DietCode')
          .where(params.select { |param| fields.any? { |s| s.to_s.casecmp(param.to_s)==0 } })
          .limit(params[:limit] || 10)
          .offset(params[:offset])
    end
  end
end
