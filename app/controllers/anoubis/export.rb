module Anubis
  class Export
    class_attribute :data
    class_attribute :title
    class_attribute :format
    class_attribute :fields

    def initialize(options = {})
      self.data = []
      self.title = []
      options[:format] = 'xls' if !options.key? :format
      self.format = options[:format]
      self.fields = if options.key?(:fields) then options[:fields] else nil end
      if self.fields
        self.fields.each do |field|
          self.title.push field[:title]
        end
      end
    end

    def add (data)
      data.each do |dat|
        new_data = []
        self.fields.each do |field|
          if dat.key? field[:id].to_sym
            new_data.push dat[field[:id].to_sym]
          else
            new_data.push ''
          end
        end
        #new_data = dat.except :actions, :sys_title
        self.data.push(new_data)
      end
    end

    def to_h
      {
          data: self.data,
          title: self.title,
          fields: self.fields,
          format: self.format
      }
    end

    public :format
  end
end