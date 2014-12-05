module Fluent

class Riak2Output < BufferedOutput

  Fluent::Plugin.register_output('riak2', self)
  include SetTimeKeyMixin
  config_set_default :include_tag_key, true
  include SetTagKeyMixin
  config_set_default :include_time_key, true

  config_param :bucket_type, :string, :default => "fluentlog" # we assume that search is on and this bucket type has an search index attached to it.
  config_param :bucket_name, :string, :default => "fluentlog"
  config_param :riak2_metadata_bucket_type, :string, :default => ""
  config_param :nodes, :string, :default => "localhost:8087"

  def initialize
    super
    require 'riak'
    require 'msgpack'
    require 'uuidtools'
  end

  def configure(conf)
    super

    @nodes = @nodes.split(',').map{ |s|
      ip,port = s.split(':')
      {:host => ip, :pb_port => port.to_i}
    }
    $log.info "riak nodes=#{@nodes}"
  end

  def start
    $log.debug " => #{@buffer.chunk_limit} #{@buffer.queue_limit} "
    @client = Riak::Client.new(:nodes => @nodes)
    @bucket = @client.bucket(@bucket_name)
    @buf = {}

    # $log.debug "riak2_metadata_bucket_type => #{@riak2_metadata_bucket_type}"
    # $log.debug "bucket_type => #{@bucket_type}"

    if not @riak2_metadata_bucket_type.empty? then
      # Here we are storing our bucket type and bucket name in a metadata map.  This allows clients to query that map to see a list of all fluentd buckets.

      # bucket_type/name/key is returns a metadata map
      metadata_bucket_type = @riak2_metadata_bucket_type        # config defined bucket type
      metadata_bucket_name = "fluent-plugin-riak2-metadata"     # bucket name
      metadata_key         = "fluent-plugin-riak2-metadata-key" # root level key for our metadata map

      # our metadata map has a kv where:
      # 1. key is set_of_logfile_buckets_key
      # 2. value is a set of strings.  each string represents the bucket type and name for a single logfile
      set_of_logfile_buckets_key = "all_buckets"                # inner key for our set of all logfile bucket type/name

      mdbucket = @client.bucket(metadata_bucket_name)
      Riak::Crdt::DEFAULT_BUCKET_TYPES[:map] = metadata_bucket_type
      map = Riak::Crdt::Map.new(mdbucket, metadata_key)
      map.sets[set_of_logfile_buckets_key].add "#{@bucket_type} #{@bucket_name}"
    end
    super
  end

  def format(tag, time, record)
    [time, tag, record].to_msgpack
  end

  def write(chunk)
    $log.debug " <<<<<===========\n"
    records  = []
    chunk.msgpack_each { |time, tag, record|
      record[@tag_key] = tag
      records << record
      $log.debug record
    }
    put_now(records)
  end

  private

  def put_now(records)
    if not records.empty? then
      threads = []
      records.each { |record|
        #if you put log statements here, you must take care to NOT forward fluentd's logs to riak.  you will trigger a recursive avalance of riak storage activity.
        now = DateTime.now.iso8601(9)
        key = "#{now}-#{UUIDTools::UUID.timestamp_create.to_s}"
        # $log.debug "#{@bucket_name} #{key} \n"

        # we are doing the somewhat granular storage, instead of chunked, at the record level.  This probably should be a config option.
        threads << Thread.new {
          robj = Riak::RObject.new(@bucket, key)
          robj.content_type = "application/json"
          raw_data = "{\"msg_s\":\"#{record["msg"]}\",\"time_dt\":\"#{record["time"]}\",\"src_s\":\"fluentd\"}"
          # $log.debug "raw_data #{raw_data}\n"
          robj.raw_data = raw_data
          robj.store(type: @bucket_type)
        }
      }
    end # if
  end # put_now
end # class Riak2Output

end # Module
