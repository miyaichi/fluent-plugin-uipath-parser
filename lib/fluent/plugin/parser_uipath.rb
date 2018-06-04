require 'fluent/parser'

module Fluent
  class TextParser
    class UiPathParser < Parser
      Plugin.register_parser('uipath', self)

      desc 'Encoding of log file'
      config_param :encoding, :string, default: 'Windows31_J'
  
      def initialize
        super
        require 'json'
      end

      def parse(text)
        time = Fluent::Engine.now
        record = { 'raw' => text }
  
        text = text.encode('UTF-16BE', @encoding,
                           :invalid => :replace, :undef => :replace,
                           :replace => '?').encode('UTF-8')
  
        if md = text.match(/^[^ ]* [^ ]* (.*)$/)
          record = JSON.parse(md[1])
          if record.has_key?('timeStamp')
            time = Time.parse(record['timeStamp']).to_i
            record['timeStamp'] = time.to_json
          end
        end
  
        yield time, record
        return
      end
    end
  end
end
