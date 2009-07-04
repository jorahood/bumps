module Bumps
  class Feature
    
    attr_accessor :name, :content
    
    def initialize
      @name = ''
      @content = ''
    end  
    
    def self.pull
      Configuration.output_stream << "\nRetrieving features from #{Configuration.pull_url} ...\n"
      begin
        features = RemoteFeature.fetch(Configuration.pull_url)
      rescue Exception => e
        Configuration.output_stream << "\nCould not pull features: #{e}\n"
        features = []
      end
        
      features.each do |feature|
        feature.write_to Configuration.feature_directory
      end
      Configuration.output_stream << "Wrote #{features.size} features to #{Configuration.feature_directory}\n\n"
    end
    
    def write_to directory
      file_path = File.expand_path(File.join(directory, name))
      FileUtils.makedirs File.dirname(file_path)
      File.open(file_path, 'w') {|f| f.write(content) }
    end 
    
    def eql? match
      self.instance_variables.each do |attr|
        self_attr = self.instance_variable_get(attr)
        match_attr = match.instance_variable_get(attr)
        return false unless self_attr == match_attr
      end
        
      true
    end   
  end
end  