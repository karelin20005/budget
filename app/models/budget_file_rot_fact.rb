class BudgetFileRotFact < BudgetFile

  protected

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    kkd = row['KKD'].to_s

    line = {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'fond' => row['KKFN'].to_s,
        'amount' => amount / 100,
    }
    [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_bb', key: kkd.slice(0, 3)}, {t: 'kkd_cc', key: kkd.slice(0, 5)}, {t: 'kkd', key: kkd.slice(0, 8)}].map { |v|
      line[v[:t]] = v[:key]
    }
    line
  end

end
