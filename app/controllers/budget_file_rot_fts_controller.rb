class BudgetFileRotFtsController < BudgetFileRotsController

  protected

  def get_file_name_for uploaded_io
    "#{uploaded_io.original_filename}.dbf"
  end

  def generate_budget_file
    @budget_file = BudgetFileRotFt.new
  end

end