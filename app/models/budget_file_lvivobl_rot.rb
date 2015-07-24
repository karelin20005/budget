class BudgetFileLvivoblRot < BudgetFile

  protected

  def readline row

    kkd = row['Код'].to_s.gsub(/\s+/, "").split('.')[0]
    return if kkd.to_i == 0

    return if %w(10000000 11010000 11020000 12000000 13000000 13010000 13020000 13030000 13070000 19010000 19050000 20000000 22080000 30000000 40000000 41020000 41030000 50000000 90010200).include?(kkd)

    # return if kkd.match Regexp.new(".*000$")
    # return if kkd.match Regexp.new("^900.*")

    [
        { :amount => row['Загальний фонд - план'].to_i, :amount_type => :plan, :fond => 1 },
        { :amount => row['Загальний фонд - факт'].to_i, :amount_type => :fact, :fond => 1 },
        { :amount => row['Спеціальний фонд - план'].to_i, :amount_type => :plan, :fond => 7 },
        { :amount => row['Спеціальний фонд - факт'].to_i, :amount_type => :fact, :fond => 7 },
    ].map { |line|
      next if line[:amount] == 0

      item = {
          'amount' => line[:amount],

          '_amount_type' => line[:amount_type],

          'fond' => line[:fond]
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_bb', key: kkd.slice(0, 3)}, {t: 'kkd_cc', key: kkd.slice(0, 5)}, {t: 'kkd', key: kkd.slice(0, 8)}].map { |v|
        item[v[:t]] = v[:key]
      }

      item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

end
