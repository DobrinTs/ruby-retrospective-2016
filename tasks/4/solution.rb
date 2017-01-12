RSpec.describe 'Version' do
  context 'Upon creating a new Version variable' do
    it 'accepts zero version through empty string' do
      Version.new('')
    end

    it 'accepts zero version through no arguments' do
      Version.new
    end

    it 'accepts correct versions through strings' do
      expect { Version.new('1.3.5') }.to_not raise_error
      expect { Version.new('3.14.12') }.to_not raise_error
      expect { Version.new('2.5.0') }.to_not raise_error
    end

    it 'accepts correct versions through other version instance' do
      expect { Version.new(Version.new('1.3.5')) }.to_not raise_error
    end

    it 'rejects incorrect versions through strings' do
      expect { Version.new('.9.1') }.to raise_error(ArgumentError)
      expect { Version.new('5..2') }.to raise_error(ArgumentError)
    end

    it 'rejects incorrect versions through other version instance' do
      expect { Version.new(Version.new('.9.1')) }.to raise_error(ArgumentError)
    end
  end

  context 'Upon comparing versions' do
    it 'compares equal versions' do
      expect(Version.new('1.1.0') == Version.new('1.1')).to eq true
    end

    it 'compares non-equal versions' do
      expect(Version.new('5.3.2') < Version.new('9')).to eq true
      expect(Version.new('5.3.2') > Version.new('2.3.0')).to eq true
    end

    it 'compares with spaceship operator' do
      expect(Version.new('5.3.2') <=> Version.new('9')).to eq -1
      expect(Version.new('5.3.2') <=> Version.new('2.3.0')).to eq 1
      expect(Version.new('5.3.2') <=> Version.new('5.3.2.0')).to eq 0
    end
  end

  context 'Upon string conversions' do
    it 'converts the zero version' do
      expect(Version.new('').to_s).to eq ''
      expect(Version.new.to_s).to eq ''
    end

    it 'converts when version does not end in zeros' do
      expect(Version.new('12.4.2').to_s).to eq '12.4.2'
    end

    it 'converts when version ends in zeros' do
      expect(Version.new('5.1.3.0.0').to_s).to eq '5.1.3'
    end
  end

  context 'Upon calling components method' do
    context 'When number of arguments is not set' do
      it 'works when version ends in zeros' do
        expect(Version.new('4.2.0.0.0').components).to eq [4, 2]
      end

      it 'works when version doesn\'t end in zeros' do
        expect(Version.new('4.2').components).to eq [4, 2]
      end
    end

    context 'When number of arguments is set' do
      it 'works when number of arguments is less than version length' do
        expect(Version.new('2.4.16').components(2)).to eq [2, 4]
      end

      it 'works when number of arguments is greater than version length' do
        expect(Version.new('6.8').components(5)).to eq [6, 8, 0, 0, 0]
      end
    end

    it 'does not allow modifications to version' do
      version = Version.new('1.2.3.4')
      components = version.components
      expect(version.components.equal?(components)).to eq false
      components[3] = 5
      expect(version.to_s).to_not eq '1.2.3.5'
      expect(version.to_s).to eq '1.2.3.4'
    end
  end

  describe 'Range' do
    context 'When initializing' do
      it 'works with two strings' do
        Version::Range.new('1.2.3', '4.5.6')
      end

      it 'works with two Version variables' do
        Version::Range.new(Version.new('1'), Version.new('2'))
      end
    end

    context 'When using include?' do
      it 'checks versions in between when argument is a Version' do
        version_range = Version::Range.new('1', '5')
        expect(version_range.include?(Version.new('3.5.4.6.2'))).to eq true
      end

      it 'checks versions outside of range when argument is a Version' do
        version_range = Version::Range.new('2', '3')
        expect(version_range.include?(Version.new('7.1.2'))).to eq false
      end

      it 'checks versions in between when argument is a string' do
        version_range = Version::Range.new('1', '5')
        expect(version_range.include?('3.5.4.6.2')).to eq true
      end

      it 'checks versions outside of range when argument is a string' do
        version_range = Version::Range.new('2', '3')
        expect(version_range.include?('7.1.2')).to eq false
      end
    end

    context 'When using to_a' do
      it 'includes start version' do
        version_range = Version::Range.new('1', '1.0.1')
        expect(version_range.to_a).to eq [1]
      end

      it 'excludes end version' do
        version_range = Version::Range.new('1', '1')
        expect(version_range.to_a).to eq []
      end

      it 'generates correct array' do
        version_range_array = Version::Range.new('2.5', '2.5.7').to_a
        arr = ['2.5', '2.5.1', '2.5.2', '2.5.3', '2.5.4', '2.5.5', '2.5.6']
        expect(version_range_array).to eq arr
      end
    end
  end
end
