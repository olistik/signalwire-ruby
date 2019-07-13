# frozen_string_literal: true

module Signalwire::Relay
  class Consumer
    include Signalwire::Logger
    attr_reader :client, :project, :token

    class << self
      def contexts(val = nil)
        if val.nil?
          @contexts || []
        else
          @contexts = val
        end
      end
    end

    # Creates a Consumer instance ready to be run
    #
    # The initialization parameters can also be supplied via ENV variables
    # (SIGNALWIRE_ACCOUNT, SIGNALWIRE_TOKEN and SIGNALWIRE_SPACE_URL)
    # Passed-in values override the environment ones.
    #
    # @param project [String] Your SignalWire project identifier
    # @param token [String] Your SignalWire secret token
    # @param signalwire_space_url [String] Your SignalWire space URL (not needed for production usage)

    def initialize(project: nil, token: nil, space_url: nil)
      @project = project   || ENV['SIGNALWIRE_ACCOUNT']
      @token =   token     || ENV['SIGNALWIRE_TOKEN']
      @url =     space_url || ENV['SIGNALWIRE_SPACE_URL'] || Signalwire::Relay::DEFAULT_URL

      @client = Signalwire::Relay::Client.new(project: @project,
        token: @token, signalwire_space_url: @url)
    end

    def setup
      # do stuff here.
    end

    def ready
      # do stuff here.
    end

    def teardown
      # do stuff here.
    end

    def on_task(task); end

    def on_event(event)
      # all-events firespout
    end

    def on_incoming_call(call); end

    def run
      setup
      client.on :ready do
        ready
        setup_receive_listeners
        setup_all_events_listener
        # not sure if ordering matters
      end

      client.connect!
    end

    def stop
      teardown
      client.disconnect!
    end

  private

    def setup_receive_listeners
      self.class.contexts.each do |cxt|
        client.calling.receive context: cxt do |call|
          on_incoming_call(call)
        end
      end
    end

    def setup_all_events_listener
      client.on :event do |evt|
        on_event(evt)
      end
    end
  end
end
