class Expense < BudgetFile
  include Mongoid::Document

  field :bubbletree, :type => Hash
  field :sunburst, :type => Hash

  def load_file
    require 'dbf'

    dbf = DBF::Table.new(self.file)
    rows = []
    dbf.reject { |rec| rec.summ.nil? }.each do |rec|
      rows << {kvk: rec.kvk, krk: rec.krk, ktfk: rec.ktfk.to_s, kekv: rec.kekv, amount: rec.summ}
    end

    self.bubbletree = parse_bubbletree rows
    self.sunburst = parse_sunburst rows
  end

  protected
    def parse_bubbletree rows
      items = { :amount => 0 }

      rows.each do |r|
        if r[:amount] > 0
          va = r[:ktfk].slice(0, 1)
          vb = r[:ktfk].slice(0, 2)
          vc = r[:ktfk].slice(0, 5)

          items[va] = { :amount => 0 } if items[va].nil?

          items[va][vb] = { :amount => 0 } if items[va][vb].nil?

          items[va][vb][vc] = { :amount => 0 } if items[va][vb][vc].nil?

          # items[va][vb][vc][vd] = { :amount => 0 } if items[va][vb][vc][vd].nil?


          items[:amount] += r[:amount]
          items[va][:amount] += r[:amount]
          items[va][vb][:amount] += r[:amount]
          items[va][vb][vc][:amount] += r[:amount]
          # items[va][vb][vc][vd][:amount] += r[:amount]
        end
      end

      self.build_bubbletree_item(items, "Всього доходів", "green")
    end

    def parse_sunburst rows
      {
          "name" => "Доходи",
          "children" => [
              {
                  "name" => "Кошик 1",
                  "description" => "Видатки, що враховуються при визначенні обсягу міжбюджетних трансфертів",
                  "children" => self.get_burst_for(rows, %w(240900 250404 10116))
              },
              {
                  "name" => "Кошик 2", "description" => "Видатки, що не враховуються при визначенні обсягу міжбюджетних трансфертів",
                  # "children" => self.get_burst_for(rows, %w(11010600 11020100 11020200 11020300 11020400 11020500 11020600 11020700 11020900 11021000 11021100 11021300 11021400 11021500 11021600 11021900 11022100 11023200 12020100 12020200 12020300 12020400 12020500 12020600 12020700 12020800 12030100 12030200 12030300 12030400 12030500 12030600 12030700 12030800 12030900 12031000 12031100 12031200 13010100 13010200 13010300 13020100 13020200 13020300 13020400 13020500 13020600 13030100 13030200 13030400 13030500 13030600 13030700 13030800 13030900 13050100 13050200 13050300 13050400 13050500 13070100 13070200 13070300 16010100 16010200 16010400 16010500 16010600 16010700 16010800 16010900 16011000 16011100 16011200 16011300 16011500 16011600 16011700 16011800 16011900 16012100 17010100 17010200 17010300 17010400 17010500 17010700 17010800 17010900 17060000 18010100 18010200 18020100 18020200 18030100 18030200 18040100 18040200 18040300 18040500 18040600 18040700 18040800 18040900 18041000 18041300 18041400 18041500 18041600 18041700 18041800 18050100 18050200 18050300 18050400 19010100 19010200 19010300 19010400 19010500 19010600 19040100 19040200 19050100 19050200 19050300 19060100 19060200 19070000 19090400 21010100 21010300 21010500 21010800 21020000 21030000 21040000 21050000 21080100 21080200 21080500 21080600 21080700 21080800 21080900 21081100 21081200 21081300 21081400 21082000 21090000 21110000 22010000 22010200 22010400 22010500 22010600 22010700 22010900 22011000 22011100 22011200 22011400 22011500 22011700 22011800 22011900 22012000 22012100 22012200 22012300 22012400 22012500 22020000 22030000 22050000 22060000 22070000 22080100 22080200 22080300 22080400 22130000 22150100 22150200 22160000 22160100 24030000 24060300 24060500 24060600 24060700 24060800 24061500 24061600 24061900 24062000 24062100 24062200 24062400 24110300 24110400 24110500 24110600 24110700 24110800 24110900 24170000 25010100 25010200 25010300 25010400 25020100 25020200 25020300 31010100 31010200 31020000 31030000 33010100 33010200 33010300 33010400 33020000 34000000 50110000 ))
              },
              {
                  "name" => "Інше",
                  "description" => "Видатки за рахунок субвенцій з державного бюджету",
                  # "children" => self.get_burst_for(rows, %w(14020100 14020200 14020300 14020400 14020600 14020700 14021600 14022100 41020300 41020900 41021000 41030200 41030300 41030400 41030600 41030800 41030900 41031000 41031900 41032900 41033800 41033900 41034400 41034800 41035000 41035800 41036600 41037700  11022200 11023100 11023300 11023400 11023500 11023600 11023700 11023900 11024000 11024100 11024600 14010100 14010200 14010300 14010400 14010500 14010600 14010700 14010900 14011100 14020800 14020900 14021000 14021100 14021200 14021700 14021800 14030100 14030200 14030300 14030400 14030600 14030700 14030800 14030900 14031000 14031100 14031600 14031700 14031800 14050000 15010100 15010200 15010300 15010400 15010500 15010600 15010700 15020100 15020200 15020300 15040000 17070000 19040300 21010600 21010700 21010900 21081000 22080500 22090600 22110000 22120000 22150000 22200000 24010100 24010200 24010300 24010400 24020000 24040000 24061800 24063100 24063500 24110100 24110200 24130100 24130200 24130300 24140000 24140100 24140200 24140300 24140500 24140600 24160100 24160200 24160300 31010000 32010000 32010100 32010200 32010300 32010400 32020000 41010100 41010200 41010300 41010400 41010500 41010600 41010700 41010800 41010900 41020100 41020400 41020600 41020800 41021100 41021200 41021300 41021400 41021500 41021600 41021700 41021800 41021900 41022000 41030700 41031200 41031300 41031400 41031500 41031600 41031700 41031800 41032000 41032100 41032200 41032300 41032400 41032500 41032600 41032700 41032800 41033000 41033100 41033200 41033300 41033400 41033500 41033600 41033700 41034000 41034100 41034200 41034300 41034500 41034600 41034700 41034900 41035100 41035200 41035300 41035400 41035500 41035600 41036300 41036500 41037000 41037600 41037800 41037900 41038000 41038100 41038200 41038300 41038400 41038500 41038600 41038700 41038800 41038900 41039000 41039100 41039200 41039300 41039400 41039500 41039600 41039800 42020000 42030000 42030100 42030200 ))
              },
          ]
      }
    end

    def build_bubbletree_item(items, label, color)
      tree = {
          "amount" => items[:amount],
          "label" => label,
          "color" => color
      }

      children = items.keys.reject{|k| k == :amount}
      unless children.empty?
        tree["children"] = []
        children.each { |key|
          tree["children"] << self.build_bubbletree_item(items[key], key, "orange")
        }
      end

      tree
    end

    def get_burst_for(rows, nodes)
      children = []
      small = { "count" => 0, "amount" => 0 }
      nodes.each do |node|
        rows.reject {|r| r[:ktfk] != node}.each do |r|
          if r[:amount] > 200000000
            children << { "name" => r[:ktfk], "size" => r[:amount]}
          else
            small["count"] += 1
            small["amount"] += r[:amount]
          end
        end
      end

      if small["amount"] > 0
        children << { "name" => "АГРЕГОВАНО: #{small['count']} показників", "size" => small['amount']}
      end

      children
    end

end
