module BudgetFileUpload
  extend ActiveSupport::Concern

  def upload_file uploaded_io, new_file_name
    file_path = Rails.root.join('public', 'files', new_file_name )

    File.open(file_path, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    { name: new_file_name, path: file_path }
  end

  def read_table_from_file path
    require 'roo'

    case File.extname(path).upcase
      when '.CSV'
        read_csv_xls Roo::CSV.new(path, csv_options: {col_sep: ";"})
      when '.XLS'
        xls = Roo::Excel.new(path)
        xls.default_sheet = xls.sheets.first
        read_csv_xls xls
      when '.XLSX'
        xls = Roo::Excelx.new(path)
        xls.default_sheet = xls.sheets.first
        read_csv_xls xls
      else '.DBF'
        read_dbf DBF::Table.new(path)

    end
  end

  def read_dbf(dbf)
    cols = dbf.columns.map {|c| c.name}

    rows = dbf.map do |rec|
      row = {}
      cols.each { |col|
        row[col] = rec[col]
      }
      row
    end

    { :rows => rows, :cols => cols }
  end

  def read_csv_xls(xls)
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << xls.cell(1, col).to_s
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = {}

      # next if xls.respond_to?(:font) and xls.font(line, 1).bold?

      xls.first_column.upto(xls.last_column ) do |col|
        row[xls.cell(1, col)] = xls.cell(line,col).to_s
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end

  def get_arr_by_table_path(file_arr)
    file = upload_file(file_arr,file_arr.original_filename)
    read_table_from_file file[:path]
  end

end
