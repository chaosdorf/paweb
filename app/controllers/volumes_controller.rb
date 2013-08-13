require 'server_side_events_writer'

class VolumesController < ApplicationController
  include ActionController::Live
  
  # render_to_string from AbstractController::Rendering, because render_to_string from ActionController::Rendering breaks live streaming
  def render_to_string(*args, &block)
    options = _normalize_render(*args, &block)
    render_to_body(options)
  end
  
  def index
    pulseaudio = PulseAudio.new(Settings.pulseaudio_server)
    @playback_streams = pulseaudio.fetch_playback_streams
    @sinks = pulseaudio.fetch_sinks
  end
  
  def update_playback_stream
    pulseaudio = PulseAudio.new(Settings.pulseaudio_server)
    pulseaudio.set_playback_stream_volume(params[:id].to_i, params[:volume].to_i)
    render nothing: true
  end
  
  def update_sinks
    pulseaudio = PulseAudio.new(Settings.pulseaudio_server)
    pulseaudio.set_sink_volume(params[:id].to_i, params[:volume].to_i)
    render nothing: true
  end

  def events
    response.headers['Content-Type'] = 'text/event-stream'
    server_side_events_writer = ServerSideEventsWriter.new(response.stream)
    pulseaudio = PulseAudio.new(Settings.pulseaudio_server)
    
    begin
      loop do
        @playback_streams = pulseaudio.fetch_playback_streams
        @sinks = pulseaudio.fetch_sinks
        server_side_events_writer.write(
          { code: render_to_string('events.js.erb') }, 
          { event: 'js' })
          sleep 0.5
      end
    rescue IOError
    ensure
      server_side_events_writer.close
    end
  end
end
