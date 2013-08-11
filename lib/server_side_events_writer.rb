require 'json'

# Code from http://tenderlovemaking.com/2012/07/30/is-it-live.html

class ServerSideEventsWriter
  def initialize io
    @io = io
  end

  def write object, options = {}
    options.each do |k,v|
      @io.write "#{k}: #{v}\n"
    end
    @io.write "data: #{JSON.dump(object)}\n\n"
  end

  def close
    @io.close
  end
end
