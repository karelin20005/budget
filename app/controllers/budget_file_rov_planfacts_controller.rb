class BudgetFileRovPlanfactsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRovPlanfact.new
  end

end
