require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

Sequel.extension :pg_array, :pg_array_ops, :pg_json, :pg_json_ops

describe "Sequel::Postgres::JSONOp" do
  before do
    @db = Sequel.connect('mock://postgres', :quote_identifiers=>false)
    @j = Sequel.pg_json_op(:j)
    @jb = Sequel.pg_jsonb_op(:j)
    @l = proc{|o| @db.literal(o)}
  end

  it "should have #[] get the element" do
    @l[@j[1]].should == "(j -> 1)"
    @l[@j['a']].should == "(j -> 'a')"
  end

  it "should have #[] accept an array" do
    @l[@j[%w'a b']].should == "(j #> ARRAY['a','b'])"
    @l[@j[Sequel.pg_array(%w'a b')]].should == "(j #> ARRAY['a','b'])"
    @l[@j[Sequel.pg_array(:a)]].should == "(j #> a)"
  end

  it "should have #[] return a JSONOp" do
    @l[@j[1][2]].should == "((j -> 1) -> 2)"
    @l[@j[%w'a b'][2]].should == "((j #> ARRAY['a','b']) -> 2)"
  end

  it "should have #get be an alias to #[]" do
    @l[@j.get(1)].should == "(j -> 1)"
    @l[@j.get(%w'a b')].should == "(j #> ARRAY['a','b'])"
  end

  it "should have #get_text get the element as text" do
    @l[@j.get_text(1)].should == "(j ->> 1)"
    @l[@j.get_text('a')].should == "(j ->> 'a')"
  end

  it "should have #get_text accept an array" do
    @l[@j.get_text(%w'a b')].should == "(j #>> ARRAY['a','b'])"
    @l[@j.get_text(Sequel.pg_array(%w'a b'))].should == "(j #>> ARRAY['a','b'])"
    @l[@j.get_text(Sequel.pg_array(:a))].should == "(j #>> a)"
  end

  it "should have #get_text return an SQL::StringExpression" do
    @l[@j.get_text(1) + 'a'].should == "((j ->> 1) || 'a')"
    @l[@j.get_text(%w'a b') + 'a'].should == "((j #>> ARRAY['a','b']) || 'a')"
  end

  it "should have #array_length use the json_array_length function" do
    @l[@j.array_length].should == "json_array_length(j)"
    @l[@jb.array_length].should == "jsonb_array_length(j)"
  end

  it "should have #array_length return a numeric expression" do
    @l[@j.array_length & 1].should == "(json_array_length(j) & 1)"
    @l[@jb.array_length & 1].should == "(jsonb_array_length(j) & 1)"
  end

  it "should have #each use the json_each function" do
    @l[@j.each].should == "json_each(j)"
    @l[@jb.each].should == "jsonb_each(j)"
  end

  it "should have #each_text use the json_each_text function" do
    @l[@j.each_text].should == "json_each_text(j)"
    @l[@jb.each_text].should == "jsonb_each_text(j)"
  end

  it "should have #extract use the json_extract_path function" do
    @l[@j.extract('a')].should == "json_extract_path(j, 'a')"
    @l[@j.extract('a', 'b')].should == "json_extract_path(j, 'a', 'b')"
    @l[@jb.extract('a')].should == "jsonb_extract_path(j, 'a')"
    @l[@jb.extract('a', 'b')].should == "jsonb_extract_path(j, 'a', 'b')"
  end

  it "should have #extract return a JSONOp" do
    @l[@j.extract('a')[1]].should == "(json_extract_path(j, 'a') -> 1)"
    @l[@jb.extract('a')[1]].should == "(jsonb_extract_path(j, 'a') -> 1)"
  end

  it "should have #extract_text use the json_extract_path_text function" do
    @l[@j.extract_text('a')].should == "json_extract_path_text(j, 'a')"
    @l[@j.extract_text('a', 'b')].should == "json_extract_path_text(j, 'a', 'b')"
    @l[@jb.extract_text('a')].should == "jsonb_extract_path_text(j, 'a')"
    @l[@jb.extract_text('a', 'b')].should == "jsonb_extract_path_text(j, 'a', 'b')"
  end

  it "should have #extract_text return an SQL::StringExpression" do
    @l[@j.extract_text('a') + 'a'].should == "(json_extract_path_text(j, 'a') || 'a')"
    @l[@jb.extract_text('a') + 'a'].should == "(jsonb_extract_path_text(j, 'a') || 'a')"
  end

  it "should have #keys use the json_object_keys function" do
    @l[@j.keys].should == "json_object_keys(j)"
    @l[@jb.keys].should == "jsonb_object_keys(j)"
  end

  it "should have #array_elements use the json_array_elements function" do
    @l[@j.array_elements].should == "json_array_elements(j)"
    @l[@jb.array_elements].should == "jsonb_array_elements(j)"
  end

  it "should have #array_elements use the json_array_elements_text function" do
    @l[@j.array_elements_text].should == "json_array_elements_text(j)"
    @l[@jb.array_elements_text].should == "jsonb_array_elements_text(j)"
  end

  it "should have #typeof use the json_typeof function" do
    @l[@j.typeof].should == "json_typeof(j)"
    @l[@jb.typeof].should == "jsonb_typeof(j)"
  end

  it "should have #to_record use the json_to_record function" do
    @l[@j.to_record].should == "json_to_record(j)"
    @l[@jb.to_record].should == "jsonb_to_record(j)"
  end

  it "should have #to_recordset use the json_to_recordsetfunction" do
    @l[@j.to_recordset].should == "json_to_recordset(j)"
    @l[@jb.to_recordset].should == "jsonb_to_recordset(j)"
  end

  it "should have #populate use the json_populate_record function" do
    @l[@j.populate(:a)].should == "json_populate_record(a, j)"
    @l[@jb.populate(:a)].should == "jsonb_populate_record(a, j)"
  end

  it "should have #populate_set use the json_populate_record function" do
    @l[@j.populate_set(:a)].should == "json_populate_recordset(a, j)"
    @l[@jb.populate_set(:a)].should == "jsonb_populate_recordset(a, j)"
  end

  it "#contain_all should use the ?& operator" do
    @l[@jb.contain_all(:h1)].should == "(j ?& h1)"
  end

  it "#contain_all handle arrays" do
    @l[@jb.contain_all(%w'h1')].should == "(j ?& ARRAY['h1'])"
  end

  it "#contain_any should use the ?| operator" do
    @l[@jb.contain_any(:h1)].should == "(j ?| h1)"
  end

  it "#contain_any should handle arrays" do
    @l[@jb.contain_any(%w'h1')].should == "(j ?| ARRAY['h1'])"
  end

  it "#contains should use the @> operator" do
    @l[@jb.contains(:h1)].should == "(j @> h1)"
  end

  it "#contains should handle hashes" do
    @l[@jb.contains('a'=>'b')].should == "(j @> '{\"a\":\"b\"}'::jsonb)"
  end

  it "#contains should handle arrays" do
    @l[@jb.contains([1, 2])].should == "(j @> '[1,2]'::jsonb)"
  end

  it "#contained_by should use the <@ operator" do
    @l[@jb.contained_by(:h1)].should == "(j <@ h1)"
  end

  it "#contained_by should handle hashes" do
    @l[@jb.contained_by('a'=>'b')].should == "(j <@ '{\"a\":\"b\"}'::jsonb)"
  end

  it "#contained_by should handle arrays" do
    @l[@jb.contained_by([1, 2])].should == "(j <@ '[1,2]'::jsonb)"
  end

  it "#has_key? and aliases should use the ? operator" do
    @l[@jb.has_key?('a')].should == "(j ? 'a')"
    @l[@jb.include?('a')].should == "(j ? 'a')"
  end

  it "#pg_json should return self" do
    @j.pg_json.should equal(@j)
    @jb.pg_jsonb.should equal(@jb)
  end

  it "Sequel.pg_json_op should return arg for JSONOp" do
    Sequel.pg_json_op(@j).should equal(@j)
    Sequel.pg_jsonb_op(@jb).should equal(@jb)
  end

  it "should be able to turn expressions into json ops using pg_json" do
    @db.literal(Sequel.qualify(:b, :a).pg_json[1]).should == "(b.a -> 1)"
    @db.literal(Sequel.function(:a, :b).pg_json[1]).should == "(a(b) -> 1)"
    @db.literal(Sequel.qualify(:b, :a).pg_jsonb[1]).should == "(b.a -> 1)"
    @db.literal(Sequel.function(:a, :b).pg_jsonb[1]).should == "(a(b) -> 1)"
  end

  it "should be able to turn literal strings into json ops using pg_json" do
    @db.literal(Sequel.lit('a').pg_json[1]).should == "(a -> 1)"
    @db.literal(Sequel.lit('a').pg_jsonb[1]).should == "(a -> 1)"
  end

  it "should be able to turn symbols into json ops using Sequel.pg_json_op" do
    @db.literal(Sequel.pg_json_op(:a)[1]).should == "(a -> 1)"
    @db.literal(Sequel.pg_jsonb_op(:a)[1]).should == "(a -> 1)"
  end

  it "should be able to turn symbols into json ops using Sequel.pg_json" do
    @db.literal(Sequel.pg_json(:a)[1]).should == "(a -> 1)"
    @db.literal(Sequel.pg_jsonb(:a)[1]).should == "(a -> 1)"
    @db.literal(Sequel.pg_jsonb(:a).contains('a'=>1)).should == "(a @> '{\"a\":1}'::jsonb)"
  end

  it "should allow transforming JSONArray instances into ArrayOp instances" do
    @db.literal(Sequel.pg_json([1,2]).op[1]).should == "('[1,2]'::json -> 1)"
  end

  it "should allow transforming JSONHash instances into ArrayOp instances" do
    @db.literal(Sequel.pg_json('a'=>1).op['a']).should == "('{\"a\":1}'::json -> 'a')"
  end

  it "should allow transforming JSONBArray instances into ArrayOp instances" do
    @db.literal(Sequel.pg_jsonb([1,2]).op[1]).should == "('[1,2]'::jsonb -> 1)"
  end

  it "should allow transforming JSONBHash instances into ArrayOp instances" do
    @db.literal(Sequel.pg_jsonb('a'=>1).op['a']).should == "('{\"a\":1}'::jsonb -> 'a')"
  end
end
