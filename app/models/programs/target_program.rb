class Programs::TargetProgram
  include Mongoid::Document
  field :title, type: String
  field :years, type: Hash
  field :p_id,type: String
  field :responsible,type: String
  field :kvkv,type: String # program code
  field :kfkv,type: String # functional code (branch)
  field :manager,type: String
  field :reason,type: String
  field :budget_sum, type: Hash
  field :objective, type: String
  field :tasks,type: Hash
  field :region_target_program,type: Hash

  has_many :sub_programs,class_name: 'Programs::TargetProgram',foreign_key: 'p_id'
  has_many :indicators,class_name: 'Programs::Indicator'

  scope :get_main_programs,-> {where(p_id: nil)}

  validates :title,:responsible,presence: true

  def init_default_budget_sum
    self.budget_sum = {
        general_fund: '',
        special_fund: '',
        sum: ''
    }
  end

  def init_default_task
    self.tasks = {
        task1: {general_fund: '',
                special_fund: '',
                sum: ''
        }
    }
  end

end
