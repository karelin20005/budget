class BudgetFileRovFz < BudgetFile

  protected

  def readline row
    return unless row['type_rozd'].to_s == '1'
    return unless row['kmb'].to_s == self.taxonomy.kmb

    ktfk = row['fcode'].to_s
    return if (ktfk =~ /000$/) != nil
    return if (ktfk =~ /^900/) != nil

    kekv = row['ecode'].to_s
    return unless kekv.length == 4
    return if is_grouped_kekv kekv

    fond = row['cf'].to_s
    return unless %w(1 2).include? fond

    kvk = row['kvk'].to_s


    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'


    (1..12).map do |i|
      amount = row["m#{i}"].to_i / 100
      fond = row['cf']

      next if amount == 0

      item = {
          'amount' => amount,
          'fond' => fond,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
          'kvk' => kvk,
          'kekv' => kekv,
          '_month' => i.to_s
      }

      item
    end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}
  end

end