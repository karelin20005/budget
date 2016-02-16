module Modules
  class BudgetNewsController < AdminController
    before_action :set_budget_news, only: [:show, :edit, :update, :destroy]
    before_action :check_admin_permission ,except: [:show]
    respond_to :html

    def index

      # @budget_news = Modules::BudgetNews.all
      @budget_news = @budget_news.page(params[:page]).per(10)

      respond_with(@budget_news)
    end

    def show
      @budgets_news = BudgetNews.limit(10)
      respond_with(@budget_news)
    end

    def new
      @budget_news = Modules::BudgetNews.new
      respond_with(@budget_news)
    end

    def edit
    end

    def create
      @budget_news = Modules::BudgetNews.new(modules_budget_news_params)

      @budget_news.save
      respond_with(@budget_news)
    end

    def update
      unless modules_budget_news_params[:img].blank?
        @budget_news.delete_image_file!
      end
      @budget_news.update(modules_budget_news_params)

      respond_with(@budget_news)
    end

    def destroy
      @budget_news.destroy
      respond_with(@budget_news)
    end


    def all_news
      @budget_news = @budget_news.page(params[:page]).per(10)
    end

    private

      def set_budget_news
        @budget_news = Modules::BudgetNews.find(params[:id])
      end

      def modules_budget_news_params
        params.require(:modules_budget_news).permit(:title, :news_text, :link, :img, :news_date)
      end


  end
end