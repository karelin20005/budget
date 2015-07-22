class KeyIndicate::Town
  include Mongoid::Document

  field :title, type: String
  field :explanation, :type => Hash

  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy
  has_and_belongs_to_many :key_indicate_town, :class_name => 'KeyIndicate::Town'

  def generate_explanation
    self.explanation = self.load_from_csv 'db/key_indicators.uk.csv'
  end

  def get_indicators
    indicators = {}
    self.key_indicate_indicator_files.each{|file|
      file.key_indicate_indicators.each{|indicator|
        key = indicator['key_indicator']
        year = indicator['year']
        indicators[year] = {} if indicators[year].nil?
        indicators[year][key] = {}
        indicators[year][key]['name'] = self.explanation[key]['indicator']
        indicators[year][key]['name'] += ", " + self.explanation[key]['unit'] unless self.explanation[key]['unit'].nil?
        indicators[year][key]['icon'] = self.explanation[key]['icon']
        indicators[year][key]['color'] = self.explanation[key]['color']
        indicators[year][key]['amount'] = indicator['amount']
        indicators[year][key]['description'] = indicator['description']
      }
    }
    indicators
  end

  def update_explanation explanation
    self.explanation.each{|key, value|
      value.each{|k,v|
        self.explanation[key][k] = explanation[key][k] unless explanation[key][k].nil?
      }
    }
    self.save
  end

  protected

  def load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";", :quote_char => '|'}) do |row|
      items[row[0]] = { indicator: row['indicator'], unit: row['unit'], icon: row['icon'], color: row['color'] }
    end
    items
  end
end