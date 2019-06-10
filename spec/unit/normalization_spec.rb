require 'spec_helper'

describe ByStar::Normalization do

  let(:options){ {} }

  shared_examples_for 'date normalization from string' do

    context 'when Chronic is defined' do

      context 'date String' do
        let(:input){ '2014-01-01' }
        it { should eq Date.parse('2014-01-01') }
      end

      context 'time String' do
        let(:input){ '2014-01-01 15:00:00' }
        it { should eq Date.parse('2014-01-01') }
      end

      context 'natural language String' do
        let(:input){ 'tomorrow at 3:30 pm' }
        it { should eq Date.parse('2014-01-02') }
      end
    end

    context 'when Chronic is not defined' do

      before { hide_const('Chronic') }

      context 'date String' do
        let(:input){ '2014-01-01' }
        it { should eq Date.parse('2014-01-01') }
      end

      context 'time String' do
        let(:input){ '2014-01-01 15:00:00' }
        it { should eq Date.parse('2014-01-01') }
      end

      context 'natural language String' do
        let(:input){ 'tomorrow at noon' }
        it { expect{ subject }.to raise_error(ByStar::ParseError, "Cannot parse String #{input.inspect}") }
      end
    end
  end

  shared_examples_for 'date normalization from time value' do
    context 'Date' do
      let(:input){ Date.parse('2014-01-01') }
      it { expect eq Date.parse('2014-01-01') }
    end

    context 'DateTime' do
      let(:input){ Date.parse('2014-01-01').to_datetime }
      it { expect eq Date.parse('2014-01-01') }
    end

    context 'Time' do
      let(:input){ Date.parse('2014-01-01') }
      it { expect eq Date.parse('2014-01-01') }
    end
  end

  describe '#time' do
    subject { ByStar::Normalization.time(input) }

    context 'when Chronic is defined' do

      context 'date String' do
        let(:input){ '2014-01-01' }
        it { should eq Time.zone.parse('2014-01-01 12:00:00') }
      end

      context 'time String' do
        let(:input){ '2014-01-01 15:00:00' }
        it { should eq Time.zone.parse('2014-01-01 15:00:00') }
      end

      context 'natural language String' do
        let(:input){ 'tomorrow at 3:30 pm' }
        it { should eq Time.zone.parse('2014-01-02 15:30:00') }
      end
    end

    context 'when Chronic is not defined' do

      before { hide_const('Chronic') }

      context 'date String' do
        let(:input){ '2014-01-01' }
        it { should eq Time.zone.parse('2014-01-01 00:00:00') }
      end

      context 'time String' do
        let(:input){ '2014-01-01 15:00:00' }
        it { should eq Time.zone.parse('2014-01-01 15:00:00') }
      end

      context 'natural language String' do
        let(:input){ 'tomorrow at noon' }
        it { expect{ subject }.to raise_error(ByStar::ParseError, "Cannot parse String #{input.inspect}") }
      end
    end

    context 'Date' do
      let(:input){ Date.parse('2014-01-01') }
      it { expect eq Time.zone.parse('2014-01-01 00:00:00') }
    end

    context 'DateTime' do
      let(:input){ Time.zone.parse('2014-01-01 15:00:00').to_datetime }
      it { expect eq Time.zone.parse('2014-01-01 15:00:00') }
    end

    context 'Time' do
      let(:input){ Time.zone.parse('2014-01-01 15:00:00') }
      it { expect eq Time.zone.parse('2014-01-01 15:00:00') }
    end
  end

  describe '#week' do
    subject { ByStar::Normalization.week(input, options) }
    it_behaves_like 'date normalization from string'
    it_behaves_like 'date normalization from time value'

    context 'Integer -1' do
      let(:input){ -1 }
      it { expect{subject}.to raise_error(ByStar::ParseError, 'Week number must be between 0 and 52') }
    end

    context 'Integer 0' do
      let(:input){ 0 }
      it { expect eq Date.parse('2014-01-01') }
    end

    context 'Integer 20' do
      let(:input){ 20 }
      it { expect eq Date.parse('2014-05-21') }
    end

    context 'Integer 53' do
      let(:input){ 53 }
      it { expect{subject}.to raise_error(ByStar::ParseError, 'Week number must be between 0 and 52') }
    end

    context 'with year option' do
      let(:options){ { year: 2011 } }

      context 'Integer 0' do
        let(:input){ 0 }
        it { expect eq Date.parse('2011-01-01') }
      end

      context 'Integer 20' do
        let(:input){ 20 }
        it { expect eq Date.parse('2011-05-21') }
      end
    end
  end

  describe '#cweek' do
    subject { ByStar::Normalization.cweek(input, options) }
    it_behaves_like 'date normalization from string'
    it_behaves_like 'date normalization from time value'

    context 'Integer 9' do
      let(:input){ 0 }
      it { expect{subject}.to raise_error(ByStar::ParseError, 'cweek number must be between 1 and 53') }
    end

    context 'Integer 1' do
      let(:input){ 1 }
      it { expect eq Date.parse('2014-01-01') }
    end

    context 'Integer 21' do
      let(:input){ 21 }
      it { expect eq Date.parse('2014-05-21') }
    end

    context 'Integer 54' do
      let(:input){ 54 }
      it { expect{subject}.to raise_error(ByStar::ParseError, 'cweek number must be between 1 and 53') }
    end

    context 'with year option' do
      let(:options){ { year: 2011 } }

      context 'Integer 1' do
        let(:input){ 1 }
        it { expect eq Date.parse('2011-01-01') }
      end

      context 'Integer 21' do
        let(:input){ 21 }
        it { expect eq Date.parse('2011-05-21') }
      end
    end
  end

  describe '#fortnight' do
    subject { ByStar::Normalization.fortnight(input, options) }
    it_behaves_like 'date normalization from string'
    it_behaves_like 'date normalization from time value'

    context 'Integer 0' do
      let(:input){ 0 }
      it { expect eq Date.parse('2014-01-01') }
    end

    context 'Integer 26' do
      let(:input){ 26 }
      it { expect eq Date.parse('2014-12-31') }
    end

    context 'out of range' do
      specify { expect{ ByStar::Normalization.fortnight(-1) }.to raise_error(ByStar::ParseError, 'Fortnight number must be between 0 and 26') }
      specify { expect{ ByStar::Normalization.fortnight(27) }.to raise_error(ByStar::ParseError, 'Fortnight number must be between 0 and 26') }
    end

    context 'with year option' do
      let(:options){ { year: 2011 } }

      context 'Integer 0' do
        let(:input){ 0 }
        it { expect eq Date.parse('2011-01-01') }
      end

      context 'Integer 26' do
        let(:input){ 26 }
        it { expect eq Date.parse('2011-12-31') }
      end
    end
  end

  describe '#month' do
    subject { ByStar::Normalization.month(input, options) }
    it_behaves_like 'date normalization from time value'

    context 'month abbr String' do
      let(:input){ 'Feb' }
      it { expect eq Date.parse('2014-02-01') }
    end

    context 'month full String' do
      let(:input){ 'February' }
      it { expect eq Date.parse('2014-02-01') }
    end

    context 'number String' do
      let(:input){ '2' }
      it { expect eq Date.parse('2014-02-01') }
    end

    context 'Integer' do
      let(:input){ 2 }
      it { expect eq Date.parse('2014-02-01') }
    end

    context 'out of range' do
      specify { expect{ ByStar::Normalization.month(0) }.to raise_error(ByStar::ParseError, 'Month must be a number between 1 and 12 or a month name') }
      specify { expect{ ByStar::Normalization.month(13) }.to raise_error(ByStar::ParseError, 'Month must be a number between 1 and 12 or a month name') }
    end

    context 'with year option' do
      let(:options){ { year: 2011 } }

      context 'month abbr String' do
        let(:input){ 'Dec' }
        it { expect eq Date.parse('2011-12-01') }
      end

      context 'Integer 12' do
        let(:input){ 10 }
        it { expect eq Date.parse('2011-10-01') }
      end
    end
  end

  describe '#quarter' do
    subject { ByStar::Normalization.quarter(input, options) }
    it_behaves_like 'date normalization from string'
    it_behaves_like 'date normalization from time value'

    context 'Integer 1' do
      let(:input){ 1 }
      it { expect eq Date.parse('2014-01-01') }
    end

    context 'Integer 2' do
      let(:input){ 2 }
      it { expect eq Date.parse('2014-04-01') }
    end

    context 'Integer 3' do
      let(:input){ 3 }
      it { expect eq Date.parse('2014-07-01') }
    end

    context 'Integer 4' do
      let(:input){ 4 }
      it { expect eq Date.parse('2014-10-01') }
    end

    context 'with year option' do
      let(:options){ { year: 2011 } }

      context 'Integer 3' do
        let(:input){ 3 }
        it { expect eq Date.parse('2011-07-01') }
      end
    end

    context 'out of range' do
      specify { expect{ ByStar::Normalization.quarter(0) }.to raise_error(ByStar::ParseError, 'Quarter number must be between 1 and 4') }
      specify { expect{ ByStar::Normalization.quarter(5) }.to raise_error(ByStar::ParseError, 'Quarter number must be between 1 and 4') }
    end
  end

  describe '#year' do
    subject { ByStar::Normalization.year(input, options) }
    it_behaves_like 'date normalization from string'
    it_behaves_like 'date normalization from time value'

    context 'Integer 69' do
      let(:input){ 69 }
      it { expect eq Date.parse('2069-01-01') }
    end

    context 'Integer 99' do
      let(:input){ 99 }
      it { expect eq Date.parse('1999-01-01') }
    end

    context 'Integer 2001' do
      let(:input){ 1 }
      it { expect eq Date.parse('2001-01-01') }
    end

    context 'String 01' do
      let(:input){ '01' }
      it { expect eq Date.parse('2001-01-01') }
    end

    context 'String 70' do
      let(:input){ '70' }
      it { expect eq Date.parse('1970-01-01') }
    end

    context 'String 2001' do
      let(:input){ '2001' }
      it { expect eq Date.parse('2001-01-01') }
    end
  end

  describe '#time_in_units' do
    subject { ByStar::Normalization.time_in_units(input) }

    context 'when less than a day' do
      let(:input) { 34876 }
      it { is_expected.to eq(days: 0, hour: 9, min: 41, sec: 16) }
    end

    context 'when more than a day' do
      let(:input) { 97532 }
      it { is_expected.to eq(days: 1, hour: 3, min: 5, sec: 32) }
    end
  end

  describe '#apply_offset_start' do
    subject { ByStar::Normalization.apply_offset_start(input, offset) }
    let(:input) { Time.zone.parse('2020-04-05 00:00:00') }
    let(:offset) { 5.hours }
    it { is_expected.to eq Time.zone.parse('2020-04-05 05:00:00') }
  end

  describe '#apply_offset_end' do
    subject { ByStar::Normalization.apply_offset_end(input, offset) }
    let(:input) { Time.zone.parse('2020-10-04 00:00:00') }
    let(:offset) { 5.hours }
    it { is_expected.to eq Time.zone.parse('2020-10-05 04:59:59') }
  end
end
