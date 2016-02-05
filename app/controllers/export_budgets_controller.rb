class ExportBudgetsController < ApplicationController
  layout 'visify', only: [:show]
  before_action :set_export_budget, only: [:show, :edit, :update, :destroy]
  before_action :get_town_calendar, only: [:show, :edit, :update, :destroy]

  # GET /export_budgets
  # GET /export_budgets.json
  def index
    @export_budgets = ExportBudget.all
  end

  # GET /export_budgets/1
  # GET /export_budgets/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'test_name',
               formats: [:html],
               # template: 'export_budgets/show',
               :layout => 'templs/templ',
               show_as_html: params.key?('debug')
      end
    end

  end

  # GET /export_budgets/new
  def new
    @export_budget = ExportBudget.new
  end

  # GET /export_budgets/1/edit
  def edit
    @export_budget = ExportBudget.find(params[:id])
  end

  # POST /export_budgets
  # POST /export_budgets.json
  def create
    @export_budget = ExportBudget.new(params[:export_budget])
    respond_to do |format|
      if @export_budget.save
        @result = 'save'
        format.html { redirect_to :back, notice: 'Export budget was successfully created.' }
        format.js { }
        format.json { render :back, status: :created, location: @export_budget }
      else
        @result = 'not_save'
        format.html { render :new }
        format.js { }
        format.json { render json: @export_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /export_budgets/1
  # PATCH/PUT /export_budgets/1.json
  def update
    respond_to do |format|
      if @export_budget.update(export_budget_params)
        format.html { redirect_to @export_budget, notice: 'Export budget was successfully updated.' }
        format.json { render :show, status: :ok, location: @export_budget }
      else
        format.html { render :edit }
        format.json { render json: @export_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /export_budgets/1
  # DELETE /export_budgets/1.json
  def destroy
    @export_budget.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Export budget was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Download pdf
  def download_pdf
    pdf = render_to_string(pdf: 'test.pdf', template: 'export_budgets/show.html.haml', encoding: "UTF-8", layout: 'application')
    send_data pdf ,:disposition => 'inline', filename: 'something.pdf', :type => 'application/pdf'
    save_path = Rails.root.join('pdfs','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_export_budget
      # -binding.pry
      @export_budget = ExportBudget.find(params[:id])
    end

    def get_town_calendar
      # -binding.pry
      @town_calendar = Calendar.where(:town => @export_budget.town.title).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def export_budget_params
      params.require(:export_budget).permit(:year, :title, :template, :town_id)
    end
end
