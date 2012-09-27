require 'spec_helper'

describe MotherBrain::PluginLoader do
  describe "ClassMethods" do
    subject { MB::PluginLoader }

    describe '::new' do
      it 'sets the paths attribute to an empty set' do
        obj = subject.new

        obj.paths.should be_a(Set)
        obj.paths.should be_empty
      end

      context 'given an array of paths' do
        let(:paths) do
          [
            '/tmp/one',
            '/tmp/two'
          ]
        end

        it 'adds two Pathnames to the paths set' do
          obj = subject.new(paths)

          obj.paths.should have(2).items
          obj.paths.should each be_a(Pathname)
        end
      end
    end
  end

  subject { MB::PluginLoader.new }

  describe '#load_all' do
    let(:paths) do
      [
        '/tmp/one',
        '/tmp/two',
        '/tmp/three'
      ]
    end

    before(:each) do
      paths.each { |path| subject.add_path(path) }
    end

    it 'sends the load message to self with each path in the paths attribute' do
      subject.should_receive(:load).with(anything).exactly(3).times

      subject.load_all
    end
  end

  describe '#load' do
    let(:path) { '/tmp/one' }
    let(:plugin) { double('plugin', name: 'reset', version: '1.2.3', id: 'reset-1.2.3') }

    before(:each) do
      MB::Plugin.stub(:from_file).with(path).and_return(plugin)
    end

    it 'adds an instantiated plugin to the hash of plugins' do
      subject.load(path)

      subject.plugins.should include(plugin)
    end

    context 'when a plugin is already loaded' do
      it 'raises an AlreadyLoaded error' do
        subject.load(path)

        lambda {
          subject.load(path)
        }.should raise_error(MB::AlreadyLoaded)
      end
    end
  end

  describe '#add_path' do
    let(:path) { '/tmp/one' }

    it 'adds the given string as a pathname to the set' do
      subject.add_path(path)

      subject.paths.should have(1).item
      subject.paths.first.should be_a(Pathname)
      subject.paths.first.to_s.should eql('/tmp/one')
    end

    context 'when a path already exists in the set' do
      it 'does not add a duplicate item to the set' do
        subject.add_path(path)
        subject.add_path(path)

        subject.paths.should have(1).item
      end
    end

    context 'given a pathname object' do
      let(:path) { Pathname.new('/tmp/one') }

      it 'adds the pathname to the set' do
        subject.add_path(path)

        subject.paths.should have(1).item
      end
    end
  end

  describe '#remove_path' do
    let(:path) { Pathname.new('/tmp/one') }
    before(:each) { subject.add_path(path) }

    it 'removes the given pathname from the set' do
      subject.remove_path(path)

      subject.paths.should have(0).items
    end
  end

  describe '#plugin' do
    let(:path) { '/tmp/one' }
    let(:plugin) { double('plugin', name: 'reset', version: '1.2.3', id: :'reset-1.2.3') }

    before(:each) do
      MB::Plugin.stub(:from_file).with(path).and_return(plugin)
      subject.load(path)
    end

    it 'it returns the plugin of the given name and version' do
      subject.plugin(plugin.name, plugin.version).should eql(plugin)
    end
  end  
end