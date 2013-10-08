require_relative './spec_helper'

require 'norikra/query'

include Norikra::SpecHelper

describe Norikra::Query do
  context 'when instanciate' do
    describe '#initialize' do
      context 'with simple query' do
        it 'returns query instances collectly parsed' do
          expression = 'SELECT count(*) AS cnt FROM TestTable.win:time_batch(10 sec) WHERE path="/" AND size > 100 and param.length() > 0'
          q = Norikra::Query.new(
            :name => 'TestTable query1', :expression => expression
          )
          expect(q.name).to eql('TestTable query1')
          expect(q.group).to be_nil
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['TestTable'])

          expect(q.fields).to eql(['param', 'path', 'size'].sort)
          expect(q.fields('TestTable')).to eql(['param','path','size'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end

      context 'with query including Static lib call' do
        it 'returns query instances collectly parsed' do
          expression = 'SELECT count(*) AS cnt FROM TestTable.win:time_batch(10 sec) AS source WHERE source.path="/" AND Math.abs(-1 * source.size) > 3'
          q = Norikra::Query.new(
            :name => 'TestTable query2', :group => 'label1', :expression => expression
          )
          expect(q.name).to eql('TestTable query2')
          expect(q.group).to eql('label1')
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['TestTable'])

          expect(q.fields).to eql(['path', 'size'].sort)
          expect(q.fields('TestTable')).to eql(['path', 'size'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end

      context 'with query with join' do
        it 'returns query instances collectly parsed' do
          expression = 'select product, max(sta.size) as maxsize from StreamA.win:keepall() as sta, StreamB(size > 10).win:time(20 sec) as stb where sta.data.substr(0,8) = stb.header AND Math.abs(sta.size) > 3'
          q = Norikra::Query.new(
            :name => 'TestTable query3', :expression => expression
          )
          expect(q.name).to eql('TestTable query3')
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['StreamA', 'StreamB'])

          expect(q.fields).to eql(['product', 'size', 'data', 'header'].sort)
          expect(q.fields('StreamA')).to eql(['size','data'].sort)
          expect(q.fields('StreamB')).to eql(['size','header'].sort)
          expect(q.fields(nil)).to eql(['product'])
        end
      end

      context 'with query with subquery (where clause)' do
        it 'returns query instances collectly parsed' do
          expression = 'select * from RfidEvent as RFID where "Dock 1" = (select name from Zones.std:unique(zoneName) where zoneId = RFID.zoneId)'
          q = Norikra::Query.new(
            :name => 'TestTable query4', :expression => expression
          )
          expect(q.name).to eql('TestTable query4')
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['RfidEvent', 'Zones'])

          expect(q.fields).to eql(['name','zoneName','zoneId'].sort)
          expect(q.fields('RfidEvent')).to eql(['zoneId'])
          expect(q.fields('Zones')).to eql(['name','zoneName','zoneId'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end

      context 'with query with subquery (select clause)' do
        it 'returns query instances collectly parsed' do
          expression = 'select zoneId, (select name from Zones.std:unique(zoneName) where zoneId = RfidEvent.zoneId) as name from RfidEvent'
          q = Norikra::Query.new(
            :name => 'TestTable query5', :expression => expression
          )
          expect(q.name).to eql('TestTable query5')
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['RfidEvent', 'Zones'].sort)

          expect(q.fields).to eql(['name','zoneName','zoneId'].sort)
          expect(q.fields('RfidEvent')).to eql(['zoneId'])
          expect(q.fields('Zones')).to eql(['name','zoneName','zoneId'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end

      context 'with query with subquery (from clause)' do
        it 'returns query instances collectly parsed' do
          expression = "select * from BarData(ticker='MSFT', sub(closePrice, (select movAgv from SMA20Stream(ticker='MSFT').std:lastevent())) > 0)"
          q = Norikra::Query.new(
            :name => 'TestTable query6', :expression => expression
          )
          expect(q.name).to eql('TestTable query6')
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['BarData', 'SMA20Stream'].sort)

          expect(q.fields).to eql(['ticker','closePrice','movAgv'].sort)
          expect(q.fields('BarData')).to eql(['ticker','closePrice'].sort)
          expect(q.fields('SMA20Stream')).to eql(['movAgv','ticker'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end

      context 'with simple query including container field accesses' do
        it 'returns query instances collectly parsed' do
          expression = 'SELECT count(*) AS cnt FROM TestTable.win:time_batch(10 sec) WHERE params.path="/" AND size > 100 and opts.$0 > 0'
          q = Norikra::Query.new(
            :name => 'TestTable query7', :expression => expression
          )
          expect(q.name).to eql('TestTable query7')
          expect(q.group).to be_nil
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['TestTable'])

          expect(q.fields).to eql(['params.path', 'size', 'opts.$0'].sort)
          expect(q.fields('TestTable')).to eql(['params.path', 'size', 'opts.$0'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end

      context 'with simple query including deep depth container field accesses and function calls' do
        it 'returns query instances collectly parsed' do
          expression = 'SELECT count(*) AS cnt FROM TestTable.win:time_batch(10 sec) WHERE params.$$path.$1="/" AND size.$0.bytes > 100 and opts.num.$0.length() > 0'
          q = Norikra::Query.new(
            :name => 'TestTable query8', :expression => expression
          )
          expect(q.name).to eql('TestTable query8')
          expect(q.group).to be_nil
          expect(q.expression).to eql(expression)
          expect(q.targets).to eql(['TestTable'])

          expect(q.fields).to eql(['params.$$path.$1', 'size.$0.bytes', 'opts.num.$0'].sort)
          expect(q.fields('TestTable')).to eql(['params.$$path.$1', 'size.$0.bytes', 'opts.num.$0'].sort)
          expect(q.fields(nil)).to eql([])
        end
      end
    end

    describe '#dup' do
      context 'for queries without group (default group)' do
        it 'returns query object with default group' do
          e1 = 'SELECT max(num) AS max FROM TestTable1.win:time(5 sec)'
          query = Norikra::Query.new(:name => 'q1', :group => nil, :expression => e1)
          q = query.dup
          expect(q.name).to eql('q1')
          expect(q.group).to be_nil
          expect(q.expression).to eql(e1)
        end
      end

      context 'for queries with group' do
        it 'returns query object with specified group' do
          e2 = 'SELECT max(num) AS max FROM TestTable2.win:time(5 sec)'
          query = Norikra::Query.new(:name => 'q2', :group => 'g2', :expression => e2)
          q = query.dup
          expect(q.name).to eql('q2')
          expect(q.group).to eql('g2')
          expect(q.expression).to eql(e2)
        end
      end
    end

    describe '.rewrite_event_field_name' do
      context 'without any container field access' do
        expression = 'select count(*) as cnt from TestTable.win:time_batch(10 seconds) where path = "/" and size > 100 and (param.length()) > 0'
        it 'returns same query with original' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_field_name(model, {'TestTable' => 'T1'}).toEPL).to eql(expression)
          end
        end
      end

      context 'with container field access' do
        expression = 'select max(result.$0.size) as cnt from TestTable.win:time_batch(10 seconds) where req.path = "/" and result.$0.size > 100 and (req.param.length()) > 0'
        expected   = 'select max(result$$0$size) as cnt from TestTable.win:time_batch(10 seconds) where req$path = "/" and result$$0$size > 100 and (req$param.length()) > 0'
        it 'returns query with encoded container fields' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_field_name(model, {'TestTable' => 'T1'}).toEPL).to eql(expected)
          end
        end
      end

      context 'with container field access with joins' do
        expression = 'select product, max(sta.param.size) as maxsize from StreamA.win:keepall() as sta, StreamB(size > 10).win:time(20 seconds) as stb where (sta.data.$0.$$body.substr(0, 8)) = stb.header and (Math.abs(sta.size)) > 3'
        expected   = 'select product, max(sta.param$size) as maxsize from StreamA.win:keepall() as sta, StreamB(size > 10).win:time(20 seconds) as stb where (sta.data$$0$$$body.substr(0, 8)) = stb.header and (Math.abs(sta.size)) > 3'
        it 'returns query with encoded container fields' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_field_name(model, {'StreamA' => 'S1', 'StreamB' => 'S2'}).toEPL).to eql(expected)
          end
        end
      end

      context 'without any container field access, but with alias specification, without joins' do
        expression = 'select count(*) as cnt from TestTable.win:time_batch(10 seconds) where path = "/" and TestTable.size > 100 and (param.length()) > 0'
        expected =   'select count(*) as cnt from TestTable.win:time_batch(10 seconds) where path = "/" and T1.size > 100 and (param.length()) > 0'
        it 'returns query expression' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_field_name(model, {'TestTable' => 'T1'}).toEPL).to eql(expected)
          end
        end
      end

      context 'with subquery in select clause' do
        expression = 'select RfidEvent.zoneId.$0, (select name.x from Zones.std:unique(zoneName) where zoneId = RfidEvent.zoneId.$0) as name from RfidEvent'
        expected   = 'select Z2.zoneId$$0, (select name$x from Zones.std:unique(zoneName) where zoneId = Z2.zoneId$$0) as name from RfidEvent'
        it 'returns query model which have replaced stream name, for only targets of fully qualified field name access' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_field_name(model, {'Zones' => 'Z1', 'RfidEvent' => 'Z2'}).toEPL).to eql(expected)
          end
        end
      end

      context 'with container field accesses, with targets, aliases and joins' do
        ###############TODO: write
      end
    end

    describe '.rewrite_event_type_name' do
      context 'with simple query' do
        expression = 'select count(*) as cnt from TestTable.win:time_batch(10 seconds) where path = "/" and size > 100 and (param.length()) > 0'

        it 'returns query model which have replaced stream name' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_type_name(model, {'TestTable' => 'hoge'}).toEPL).to eql(expression.sub('TestTable','hoge'))
          end
        end
      end
      context 'with subquery in select clause' do
        expression = 'select zoneId.$0, (select name.x from Zones.std:unique(zoneName) where zoneId = RfidEvent.zoneId.$0) as name from RfidEvent'
        expected   = 'select zoneId.$0, (select name.x from Z1.std:unique(zoneName) where zoneId = RfidEvent.zoneId.$0) as name from Z2'
        it 'returns query model which have replaced stream name, for only From clause' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_type_name(model, {'Zones' => 'Z1', 'RfidEvent' => 'Z2'}).toEPL).to eql(expected)
          end
        end
      end
      context 'with subquery in from clause' do
        expression = "select * from BarData(ticker='MSFT', sub(closePrice, (select movAgv from SMA20Stream(ticker='MSFT').std:lastevent())) > 0)"
        expected   = 'select * from B1(ticker = "MSFT" and (sub(closePrice, (select movAgv from B2(ticker = "MSFT").std:lastevent()))) > 0)'
        it 'returns query model which have replaced stream name' do
          with_engine do
            model = administrator.compileEPL(expression)
            expect(Norikra::Query.rewrite_event_type_name(model, {'BarData' => 'B1', 'SMA20Stream' => 'B2'}).toEPL).to eql(expected)
          end
        end
      end
      context 'with joins' do
        expression = 'select product, max(sta.size) as maxsize from StreamA.win:keepall() as sta, StreamB(size > 10).win:time(20 seconds) as stb where (sta.data.substr(0, 8)) = stb.header and (Math.abs(sta.size)) > 3'
        it 'returns query model which have replaced stream name' do
          with_engine do
            model = administrator.compileEPL(expression)
            mapping = {'StreamA' => 'sa', 'StreamB' => 'sb'}
            expect(Norikra::Query.rewrite_event_type_name(model, mapping).toEPL).to eql(expression.sub('StreamA','sa').sub('StreamB','sb'))
          end
        end
      end
    end
  end

  describe '.imported_java_class?' do
    it 'can do judge passed name exists under java package tree or not' do
      expect(Norikra::Query.imported_java_class?('String')).to be_true
      expect(Norikra::Query.imported_java_class?('Long')).to be_true
      expect(Norikra::Query.imported_java_class?('Void')).to be_true
      expect(Norikra::Query.imported_java_class?('BigDecimal')).to be_true
      expect(Norikra::Query.imported_java_class?('Format')).to be_true
      expect(Norikra::Query.imported_java_class?('Normalizer')).to be_true
      expect(Norikra::Query.imported_java_class?('Date')).to be_true
      expect(Norikra::Query.imported_java_class?('HashSet')).to be_true
      expect(Norikra::Query.imported_java_class?('Random')).to be_true
      expect(Norikra::Query.imported_java_class?('Timer')).to be_true

      expect(Norikra::Query.imported_java_class?('unexpected')).to be_false
      expect(Norikra::Query.imported_java_class?('parameter')).to be_false
      expect(Norikra::Query.imported_java_class?('param')).to be_false
    end
  end
end
