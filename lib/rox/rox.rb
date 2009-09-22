module ROX
  
  class Column
    
    attr_accessor :number, :name, :type, :options
    
    def initialize(number, name, type, options = nil)
      @number = number
      @name = name
      @type = type
      @options = options
    end
    
    def to_ox(client, value)
      value
    end
    
    def from_ox(client, value)
      value
    end
  
  end
  
  class MappableColumn < Column
    def initialize(number, name, type, options)
      super(number, name, type, options)
      @from_ox = options
      @inverse = @from_ox.inject({}) {|memo, pair| memo[pair[1]] = pair[0]; memo} if options
    end
    
    def to_ox(client, value)
      @inverse[value]
    end
    
    def from_ox(client, value)
      @from_ox[value]
    end
    
  end
  
  class TimeColumn < Column
    
    def from_ox(client, value)
      Time.at(client.config.timezone.local_to_utc(value / 1000))
    end
    
    def to_ox(client, value)
      client.config.timezone.utc_to_local(value.to_i) * 1000
    end
    
  end
  
  class DateColumn < Column
  
    def from_ox(client, value)
      Time.at(value / 1000)
    end
    
    def to_ox(client, value)
      value.to_i * 1000
    end
    
  end
  
  class ComplexColumn < Column
    def initialize(number, name, type, klass)
      super(number, name, type, klass)
      @klass = klass
    end  
  
    def from_ox(client, value)
      @klass.new(value)
    end
  
    def to_ox(client, value)
      value.to_ox
    end
  end
  
  class ColumnList
    attr_reader :columns, :ancestors
    
    def initialize(ancestors = nil)
      @ancestors = ancestors || Array.new
      @columns = Hash.new
      @columns_by_number = Hash.new
    end
  
    def column(number, name, type, options = nil)
      case(type)
      when :date
        klass = DateColumn
      when :time
        klass = TimeColumn
      when :mappable
        klass = MappableColumn
      when :complex
        klass = ComplexColumn
      else
        klass = Column
      end
      column = klass.new(number, name, type, options)
      add_column(column)
      self
    end
    
    def add_column(column_def)
      @columns[column_def.name] = column_def
      @columns_by_number[column_def.number] = column_def
    end
    
    def [](key)
      return @columns[key] if @columns.include?(key)
      return @columns_by_number[key] if @columns_by_number.include?(key)
      @ancestors.each do
        |ancestor|
        column = ancestor[key]
        return column if column
      end
      nil
    end
    
    def sublist(*keys)
      sublist = ColumnList.new
      keys.each do
        |key|
        value = self[key]
        sublist.add_column(value)
      end
      sublist
    end
    
    def to_s
      @columns_by_number.keys.join(",")
    end
  
  end
  
  
  class ColumnDefinitions
    
    def initialize
      @definitions = Hash.new
    end
    
    def columns(typedef, &block)
      name = typedef
      ancestors = Array.new
      if(typedef.kind_of?(Hash))
        name = typedef.keys.first
        ancestors = [*typedef[name]].map{|ancestor| self[ancestor]}
      end
      column_list = ColumnList.new(ancestors)
      column_list.instance_eval(&block)
      @definitions[name] = column_list
    end
    
    def [](key)
      @definitions[key]
    end
    
  end
  
  COLUMN_DEFINITIONS = ColumnDefinitions.new
  
  def self.columns(options, &block)
    COLUMN_DEFINITIONS.columns(options, &block)
  end

end