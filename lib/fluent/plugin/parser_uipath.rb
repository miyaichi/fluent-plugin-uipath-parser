require 'fluent/parser'

module Fluent
  class TextParser
    class UiPathParser < Parser
      Plugin.register_parser('uipath', self)
  
      def initialize
        super
        require 'json'
      end
  
      def parse(text)
        time = Fluent::Engine.now
        record = { 'raw' => text }
  
        text = text.encode('UTF-16BE', 'UTF-8',
                           :invalid => :replace, :undef => :replace,
                           :replace => '?').encode('UTF-8')
  
        if md = text.match(/^[^ ]* [^ ]* (.*)$/)
          record = JSON.parse(md[1])
          if record.has_key?('timeStamp')
            time = Time.parse(record['timeStamp']).to_i
          end
        end
  
        yield time, record
        return
      end
    end
  end
end
