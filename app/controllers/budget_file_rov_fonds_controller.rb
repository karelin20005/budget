class BudgetFileRovFondsController < BudgetFileRovsController
  protected

  def generate_budget_file
    @budget_file = BudgetFileRovFond.new
  end

end
