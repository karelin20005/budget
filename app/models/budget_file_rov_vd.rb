class BudgetFileRovVd < BudgetFile

  protected

  def readline row
    fond = row['KF'].to_s.split('.')[0]

    ktfk = row['KTFK'].to_s.split('.')[0].gsub(/^0*/, "")
    kekv = row['KEKV'].to_s.split('.')[0]

    return if (ktfk =~ /000$/) != nil
    return if (ktfk =~ /^900$/) != nil
    return unless kekv.length == 4
    return if is_grouped_kekv kekv

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    kvk = row['KVK'].to_s.split('.')[0]
    krk = row['KRK'].to_s.split('.')[0]

    [
        { :amount => row['KVNP'].to_f / 100 },
    ].map do |line|
      next if line[:amount] == 0

      item = {
          'amount' => line[:amount],
          'fond' => fond,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
          'kekv' => kekv,
          'kvk' => kvk,
          'krk' => krk,
      }

      dt = row['DT'].to_date
      item['_year'] = dt.year.to_s
      item['_month'] = dt.month.to_s

      item
    end.reject {|c| c.nil?}
    # end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}
  end

end
