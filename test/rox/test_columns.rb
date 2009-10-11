require 'test_setup'

class TestColumns < Test::Unit::TestCase
  def test_regular_column
    column = ROX::Column.new(12, :some_column, :string)
    
    assert_equal("Hallo", column.from_ox(nil, "Hallo"))
    assert_equal("Hallo", column.to_ox(nil, "Hallo"))
  
  end
  
  def test_time_column
    now = Time.now
    ny = TZInfo::Timezone.get("America/New_York")
    
    milliseconds_local = ny.utc_to_local(now.to_i) * 1000
    
    client = flexmock("client")
    client.should_receive("config.timezone").and_return(ny)
    
    column = ROX::TimeColumn.new(12, :some_column, :time) 
    assert_equal(now.to_i, column.from_ox(client, milliseconds_local).to_i)
    assert_equal(milliseconds_local, column.to_ox(client, now))
  end
  
  def test_date_column
    date = Time.utc(2009, 03, 23)
    
    column = ROX::DateColumn.new(12, :some_column, :date)

    assert_equal(date, column.from_ox(nil, date.to_i * 1000))
    assert_equal(date.to_i * 1000, column.to_ox(nil, date))
  end
  
  def test_mappable_column
    column = ROX::MappableColumn.new(12, :some_column, :mappable, {1 => :one, 2 => :two, 3 => :three, 4 => :four})
    assert_equal(:two, column.from_ox(nil, 2))
    assert_equal(2, column.to_ox(nil, :two))
  end
  
  def test_complex_column
    some_klass = flexmock("Some Class")
    some_klass.should_receive(:new).with(["complex", "value"]).once.and_return("Processed Value")
    
    column = ROX::ComplexColumn.new(12, :some_column, :complex, some_klass)
    
    assert_equal("Processed Value", column.from_ox(nil, ["complex", "value"]))
    
    some_complex_value = flexmock("Value")
    some_complex_value.should_receive(:to_ox).once.and_return(["complex", "value"])
    
    assert_equal(["complex", "value"], column.to_ox(nil, some_complex_value))
  end
  
end

class ColumnListTest < Test::Unit::TestCase

  def assert_chosen(type, expected_klass)
    list = ROX::ColumnList.new
    list.column(12, :some_column, type, nil)
    assert_equal(expected_klass, list[:some_column].class)
  end

  def test_choose_column_class
    assert_chosen(:number, ROX::Column)
    assert_chosen(:boolean, ROX::Column)
    assert_chosen(:string, ROX::Column)
    assert_chosen(:timestamp, ROX::Column)
    assert_chosen(:date, ROX::DateColumn)
    assert_chosen(:time, ROX::TimeColumn)
    assert_chosen(:mappable, ROX::MappableColumn)
    assert_chosen(:complex, ROX::ComplexColumn)
  end
  
  def test_column_lookup_inherited
    
    column_list1 = ROX::ColumnList.new
    column_list2 = ROX::ColumnList.new([column_list1])
    
    column_list1.column(12, :ancestor, :number)
    column_list2.column(13, :child, :number)
    
    assert_equal(12, column_list2[:ancestor].number)
    assert_equal(13, column_list2[:child].number)
    
  end
  
  def test_lookup_by_number
    column_list1 = ROX::ColumnList.new
    column_list2 = ROX::ColumnList.new([column_list1])
    
    column_list1.column(12, :ancestor, :number)
    column_list2.column(13, :child, :number)

    assert_equal(:ancestor, column_list2[12].name)
    assert_equal(:child, column_list2[13].name)
  end
  
  def test_column_sublist
    column_list1 = ROX::ColumnList.new
    column_list2 = ROX::ColumnList.new([column_list1])
    
    column_list1.column(12, :ancestor, :number)
    column_list2.column(13, :child, :number)
    column_list2.column(14, :other_child, :number)

    sublist = column_list2.sublist(:ancestor, :child)
    
    assert_equal(:ancestor, sublist[12].name)
    assert_equal(:child, sublist[13].name)
  end
  
end

class ColumnDefinitionsTest < Test::Unit::TestCase
  def test_column_definition
    column_defs = ROX::ColumnDefinitions.new
    column_defs.columns(:some_type) do
      column(13, :some_column, :number)
    end
    columns = column_defs[:some_type]
    assert_equal(13, columns[:some_column].number)
  end
  
  def test_column_definition_with_one_ancestor
    column_defs = ROX::ColumnDefinitions.new
    
    column_defs.columns(:some_common_type) do
      column(12, :ancestor, :number)
    end
    
    column_defs.columns(:some_type => :some_common_type) do
      column(13, :child, :number)
    end
    columns = column_defs[:some_type]
    assert_equal([column_defs[:some_common_type]], columns.ancestors)
  end
  
  def test_column_definition_with_multiple_ancestors
    column_defs = ROX::ColumnDefinitions.new
    
    column_defs.columns(:some_common_type) do
      column(12, :ancestor, :number)
    end
    
    column_defs.columns(:some_other_common_type) do
        column(11, :other_ancestor, :number)
    end
    
    column_defs.columns(:some_type => [:some_common_type, :some_other_common_type]) do
      column(13, :child, :number)
    end
    
    columns = column_defs[:some_type]
    assert_equal([column_defs[:some_common_type], column_defs[:some_other_common_type]], columns.ancestors)
  end
  
  
end