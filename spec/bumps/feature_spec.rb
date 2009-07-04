require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bumps::Feature do
  describe 'when pulling' do
    
    before do
      @output_stream = mock('output stream').as_null_object
      Bumps::Configuration.stub!(:output_stream).and_return @output_stream
    end

    subject {Bumps::Feature}

    it 'should write fetched features to the feature directory' do
      Bumps::Configuration.stub!(:feature_directory).and_return 'feature_directory'
      Bumps::Configuration.stub!(:pull_url).and_return 'location'
  
      features = 3.times.collect do |index|
        feature = mock "feature #{index}"
        feature.should_receive(:write_to).with 'feature_directory'
        feature  
      end
     
      Bumps::RemoteFeature.stub!(:fetch).with('location').and_return features 
    
      Bumps::Configuration.stub!(:feature_directory).and_return 'feature_directory'

      subject.pull
    end 
    
    it 'should output an error message if the features could not be fetched' do
      Bumps::Configuration.stub! :pull_url
      Bumps::Configuration.stub! :feature_directory
      Bumps::RemoteFeature.stub!(:fetch).and_raise "exception message"
      
      @output_stream.should_receive(:<<).with "\nCould not pull features: exception message\n" 
      
      subject.pull
    end
    
    it 'should display which location the features are being retrieved from' do
      Bumps::RemoteFeature.stub!(:fetch).and_return []
      Bumps::Configuration.stub!(:pull_url).and_return 'pull_url'
      Bumps::Configuration.stub! :feature_directory
      
      @output_stream.should_receive(:<<).with "\nRetrieving features from pull_url ...\n"
      
      subject.pull
    end  
    
    it 'should display the total number of features retrieved and location they were written to' do
      features = 3.times.collect{|index| mock("feature #{index}").as_null_object}
      Bumps::RemoteFeature.stub!(:fetch).and_return features
      Bumps::Configuration.stub!(:feature_directory).and_return 'feature_directory'
      Bumps::Configuration.stub! :pull_url
      
      @output_stream.should_receive(:<<).with "Wrote 3 features to feature_directory\n\n"
      
      subject.pull
    end
  end

  describe 'when writing self to file' do 
  
    it 'should construct file name from expanded directory and feature name' do
      subject.stub!(:name).and_return 'name'
      File.stub!(:expand_path).with('directory/path/name').and_return 'expanded path'
      File.should_receive(:open).with 'expanded path', anything
    
      subject.write_to 'directory/path'
    end
  
    it 'should overwrite existing files' do
      FileUtils.stub! :makedirs
      
      File.should_receive(:open).with anything, 'w'
     
      subject.write_to ''
    end
    
    it 'should force the creation of directories in the feature name' do
      File.stub!(:expand_path).and_return 'features_dir/subdir/featurename.feature'
      File.stub :open
      
      FileUtils.should_receive(:makedirs).with 'features_dir/subdir'
      
      subject.write_to ''
    end
  
    it 'should write content to file' do
      FileUtils.stub! :makedirs
      @file = mock 'file'
      File.stub!(:open).and_yield @file
      subject.stub!(:content).and_return 'content'
    
      @file.should_receive(:write).with 'content' 
    
      subject.write_to ''
    end
    
  end
end