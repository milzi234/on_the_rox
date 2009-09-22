module ROX
  
  columns(:common) {
    
    column(1, :id, :string)
    column(2, :created_by, :string)
    column(3, :modified_by, :string)
    column(4, :creation_date, :time)
    column(5, :last_modified, :time)
    column(6, :last_modified_utc, :timestamp)
    column(20, :folder_id, :string)
  
  }
  
  columns(:folder => :common) {
    
    column(300, :title, :string)
    column(301, :module, :string)
    column(302, :type, :mappable, {1 => :private, 2 => :public, 3 => :shared, 5 => :system})
    column(304, :boolean, :subfolders)
    #column(305, :own_rights, :)
    #column(306, :permissions, :)
    column(307, :summary, :string)
    column(308, :standard_folder, :boolean)
    column(309, :total, :number)
    column(310, :new, :number)
    column(311, :unread, :number)
    column(312, :deleted, :number)
    column(313, :capabilities, :number)
    column(314, :subscribed, :boolean)
    column(315, :subscr_subflds, :boolean)
  }
  
  
  class Folders
    def initialize(client)
      @client = client
      @columns = COLUMN_DEFINITIONS[:folder]
    end
    
    def root(*columns)
      column_list = get_columns(*columns)
      @client.get_response("/ajax/folders", :action => :root, :columns => column_list.to_s)
    end
    
    def get_columns(*columns)
      @columns.sublist(*columns)
    end
    
  end


  class Client
    def folders
      Folders.new(self)
    end
  end

end