class Documentation::DocumentsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  load_and_authorize_resource

  before_action :set_documentation_document, only: [:show, :edit, :update, :destroy]

  # GET /documentation/documents
  # GET /documentation/documents.json
  def index
    @documentation_documents = Documentation::Document
    @documentation_documents = @documentation_documents.where(:town.in => params["town_select"]) if params["town_select"]
    @documentation_documents = @documentation_documents.where(:branch.in => params["branch_select"]) if params["branch_select"]
    @documentation_documents = @documentation_documents.where(:title => Regexp.new(".*"+params["q"]+".*")) if params["q"]

    respond_to do |format|
      format.js
      format.html
      format.json { head :no_content, status: :created }
    end
  end

  # GET /documentation/documents/1
  # GET /documentation/documents/1.json
  def show
  end

  # GET /documentation/documents/indicator_file
  def new
    @documentation_document = Documentation::Document.new
  end

  # GET /documentation/documents/1/edit
  def edit
  end

  # POST /documentation/documents
  # POST /documentation/documents.json
  def create
    @documents = []

    params['doc_file'].each do |f|
      doc = Documentation::Document.new(documentation_document_params)
      doc.doc_file = f

      doc.town = Town.where(title: current_user.town).first_or_create

      doc.owner = User.where(title: current_user.email).first

      doc.save!

      @documents << doc
    end unless params['doc_file'].nil?

    respond_to do |format|
      format.js
      format.json { head :no_content, status: :created }
    end

  end

  # PATCH/PUT /documentation/documents/1
  # PATCH/PUT /documentation/documents/1.json
  def update
    respond_to do |format|
      if @documentation_document.update!(documentation_document_params)
        format.js
        format.json { render :show, status: :ok, location: @documentation_document }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @documentation_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/documents/1
  # DELETE /documentation/documents/1.json
  def destroy
    @documentation_document.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_documentation_document
      @documentation_document = Documentation::Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def documentation_document_params
      params.require(:documentation_document).permit(:category_id, :title, :branch, :town, :description, :yearFrom, :yearTo)
    end
end
