require 'server_side_events_writer'

class VolumesController < ApplicationController
  include ActionController::Live
  
  def index
    pulseaudio = PulseAudio.new('tcp:host=localhost,port=24883')
    playback_streams = pulseaudio.fetch_playback_streams
    sinks = pulseaudio.fetch_sinks

    render json: {
      playback_streams: playback_streams,
      sinks: sinks,
    }
  end

  def events
    response.headers['Content-Type'] = 'text/event-stream'
    server_side_events_writer = ServerSideEventsWriter.new(response.stream)
    pulseaudio = PulseAudio.new('tcp:host=localhost,port=24883')
    
    begin
      loop do
        playback_streams = pulseaudio.fetch_playback_streams
        sinks = pulseaudio.fetch_sinks
        server_side_events_writer.write(
          { playback_streams: playback_streams, sinks: sinks }, 
          { event: 'volumes' })
        sleep 0.5
      end
    rescue IOError
    ensure
      server_side_events_writer.close
    end
  end
end
