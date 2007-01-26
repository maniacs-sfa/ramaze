#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ostruct'
require 'set'

module Ramaze
  class GlobalStruct < OpenStruct
    # The default variables for Global:
    #   uses the class from Adapter:: (is required automatically)
    #       Global.adapter #=> :webrick
    #   restrict access to a specific host
    #       Global.host #=> '0.0.0.0'
    #   adapter runs on that port
    #       Global.port #=> 7000
    #   the running/debugging-mode (:debug|:stage|:live|:silent) - atm only differ in verbosity
    #       Global.mode #=> :debug
    #   detaches Ramaze to run in the background (used for testcases)
    #       Global.run_loose #=> false
    #   caches requests to the controller based on request-values (action/params)
    #       Global.cache #=> false
    #   run tidy over the generated html if Content-Type is text/html
    #       Global.tidy #=> false
    #   display an error-page with backtrace on errors (empty page otherwise)
    #       Global.error_page    #=> true
    #   trap this signal for clean shutdown (calls Ramaze.shutdown)
    #       Global.shutdown_trap #=> 'SIGINT'

    DEFAULT = {
      :adapter        => :webrick,
      :autoreload     => true,
      :cache          => MemoryCache,
      :cache_all      => false,
      :error_page     => true,
      :host           => '0.0.0.0',
      :inform         => {
          :to             => $stdout,
          :tags           => Set.new([:debug, :info, :error]),
          :backtrace_size => 10,
          :timestamp      => "%Y-%m-%d %H:%M:%S",
          :prefix_info    => 'INFO ',
          :prefix_debug   => 'DEBUG',
          :prefix_error   => 'ERROR',
        },
      :port           => 7000,
      :mapping        => {},
      :run_loose      => false,
      :tidy           => false,
      :template_root  => 'template',
      :cache_actions  => Hash.new{|h,k| h[k] = Set.new},

      :autoreload => {
        :benchmark  => 5,
        :debug      => 5,
        :stage      => 10,
        :live       => 20,
        :silent     => 40,
        },
    }

    def setup hash = {}, &block
      Global.instance_eval(&block) if block_given?
      table.merge!(hash)
    end

    def update hash = {}, &block
      Global.instance_eval(&block) if block_given?
      table.merge!(hash.merge(table))
    end

    def []=(key, value)
      table[key] = value
    end

    def [](key)
      table[key]
    end

    def values_at(*keys)
      table.values_at(*keys)
    end

    def each
      table.each do |e|
        yield(e)
      end
    end
  end

  Thread.current[:global] = GlobalStruct.new(GlobalStruct::DEFAULT)
  Global = Thread.current[:global]
end
