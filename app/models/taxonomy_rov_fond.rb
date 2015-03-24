class TaxonomyRovFond < Taxonomy
  VERSION = 2
  COLUMNS = {
      'fond'=>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov_fond.fund')},
      'source'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov_fond.source')},
      'owner'=>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov_fond.disposer')},
      'ktfk' =>{:level => 4, :title=>I18n.t('activerecord.taxonomy_rov_fond.func_class')},
  }

  def self.get_taxonomy(owner)
    TaxonomyRovFond.where(:owner => owner, :columns_id => VERSION).last || TaxonomyRovFond.create!(
        :owner => owner,
        :columns_id => VERSION,
        :columns => COLUMNS
    )
  end

  def readline row
    amount1 = row[I18n.t('activerecord.taxonomy_rov_fond.gen_fund')].to_i
    amount2 = row[I18n.t('activerecord.taxonomy_rov_fond.spec_fund')].to_i

    [
      { :amount => amount1,
        :fond => I18n.t('activerecord.taxonomy_rov_fond.gen_fund') },
      { :amount => amount2,
        :fond => I18n.t('activerecord.taxonomy_rov_fond.spec_fund')
      },
    ].map { |line|
    {
        'amount' => line[:amount] / 100,
        'fond' => line[:fond],
        'source' => row[I18n.t('activerecord.taxonomy_rov_fond.source')].to_s,
        'owner' => row[I18n.t('activerecord.taxonomy_rov_fond.disposer')].to_s.split('.')[0],
        'ktfk' => row[I18n.t('activerecord.taxonomy_rov_fond.func_class')].to_s.split('.')[0],
        '_year' => row['_year'].to_i,
        '_month' => row['_month'].to_i
    }
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

  protected

end
