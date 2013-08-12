require 'dbus'

class PulseAudio
  
  def initialize(dbus_address)
    bus = DBus::Connection.new(dbus_address)
    bus.connect
    @pulseaudio_service = bus.service('org.PulseAudio.Core1')
    @pulseaudio_service.introspect
    pulseaudio_core_object = @pulseaudio_service.object('/org/pulseaudio/core1')
    @pulseaudio_core_interface = pulseaudio_core_object['org.PulseAudio.Core1']
  end
  

  def fetch_playback_stream(stream_path)
    stream_object = @pulseaudio_service.object(stream_path)
    stream_object.introspect
    stream_interface = stream_object['org.PulseAudio.Core1.Stream']
    additional_stream_properties = decode_property_list(stream_interface['PropertyList'])

    {
      volume: stream_interface['Volume'],
      application: (additional_stream_properties['application.name'] rescue ''),
      user: (additional_stream_properties['application.process.user'] rescue ''),
      host: (additional_stream_properties['application.process.host'] rescue ''),
    }
  end

  def fetch_playback_streams
    playback_streams = {}
    @pulseaudio_core_interface['PlaybackStreams'].each do |stream_path|
      stream_index = extract_index_from_path(stream_path)
      playback_streams[stream_index] = fetch_playback_stream(stream_path)
    end
    playback_streams
  end
  
  def set_playback_stream_volume(index, volume)
    stream_path = "/org/pulseaudio/core1/playback_stream#{index}"
    stream_object = @pulseaudio_service.object(stream_path)
    stream_object.introspect
    stream_interface = stream_object['org.PulseAudio.Core1.Stream']
    stream_interface['Volume'] = DBus.variant('au', [volume, volume])
  end

  def set_sink_volume(index, volume)
    sink_path = "/org/pulseaudio/core1/sink#{index}"
    sink_object = @pulseaudio_service.object(sink_path)
    sink_object.introspect
    sink_interface = sink_object['org.PulseAudio.Core1.Device']
    sink_interface['Volume'] = DBus.variant('au', [volume, volume])
  end

  def fetch_sink(sink_path)
    sink_object = @pulseaudio_service.object(sink_path)
    sink_object.introspect
    sink_interface = sink_object['org.PulseAudio.Core1.Device']
    additional_sink_properties = decode_property_list(sink_interface['PropertyList'])

    {
      description: (additional_sink_properties['device.description'] rescue ''),
      volume: sink_interface['Volume'],
    }
  end

  def fetch_sinks
    sinks = {}
    @pulseaudio_core_interface['Sinks'].each do |sink_path|
      sink_index = extract_index_from_path(sink_path)
      sinks[sink_index] = fetch_sink(sink_path)
    end
    sinks
  end
  
  protected
  
    def decode_property_list(property_list)
      properties = {}
      property_list.each do |name, bytes|
        bytes_without_null_byte = bytes[0..-2]
        properties[name] = bytes_without_null_byte.pack('C*')
      end
      properties
    end
    
    def extract_index_from_path(path)
      matches = /\d+$/.match(path)
      return matches[0]
    end
end