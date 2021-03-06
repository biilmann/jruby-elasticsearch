require "java"
require "jruby-elasticsearch/namespace"
require "jruby-elasticsearch/indexrequest"
require "jruby-elasticsearch/searchrequest"

class ElasticSearch::Client

  # Creates a new ElasticSearch client.
  #
  # options:
  # :type => [:local, :node] - :local will create a process-local
  #   elasticsearch instances
  # :host => "hostname" - the hostname to connect to.
  # :port => 9200 - the port to connect to
  # :cluster => "clustername" - the cluster name to use
  def initialize(options={})
    builder = org.elasticsearch.node.NodeBuilder.nodeBuilder
    builder.client(true)

    # The client doesn't need to serve http
    builder.settings.put("http.enabled", false)

    case options[:type]
    when :local
      builder.local(true)
      @node = builder.node
      @client = @node.client
    when :transport
      # TODO(sissel): Support transport client
    else
      # Use unicast discovery a host is given
      if !options[:host].nil?
        host = options[:host].is_a?(Array) ? options[:host] : [options[:host]]
        port = options[:port] || 9300
        builder.settings.put("discovery.zen.ping.multicast.enabled", false)
        hosts = host.reject {|h| h == options[:bind_host] }.map { |h| 
          "#{h}#{(port.is_a?(Array) ? "[#{port.first}-#{port.last}]" : ":#{port}")}"
        }.join(",")
        puts "Settings hosts to #{hosts}"
        builder.settings.put("discovery.zen.ping.unicast.hosts", hosts)
        
        builder.settings.put("discovery.zen.ping_timeout", "30s")
                
        builder.settings.put("discovery.zen.fd.ping_retries", 10)
        builder.settings.put("discovery.zen.fd.ping_interval", "5s")
        builder.settings.put("discovery.zen.fd.ping_timeout", "30s")
      end

      if options[:bind_host]
        builder.settings.put('network.host', options[:bind_host])
      end

      if !options[:cluster].nil?
        builder.clusterName(options[:cluster])
      end
      @node = builder.node
      @client = @node.client
    end

  end # def initialize

  # Index a new document
  #
  # args:
  #   index: the index name
  #   type: the type name
  #   id: (optional) the id of the document
  #   data: (optional) the data for this document
  #   &block: (optional) optional block for using the DSL to add data
  #
  # Returns an ElasticSearch::IndexRequest instance.
  #
  # Example w/ DSL:
  #
  #     request = client.index("foo", "logs") do
  #       filename "/var/log/message"
  #       mesage "hello world"
  #       timestamp 123456
  #     end
  #
  #     request.execute!
  def index(index, type, id=nil, data={}, &block)
    # Permit 'id' being omitted entirely.
    # Thus a call call: index("foo", "bar", somehash) is valid.
    if id.is_a?(Hash)
      data = id
      id = nil
    end

    indexreq = ElasticSearch::IndexRequest.new(@client, index, type, id, data)
    if block_given?
      indexreq.instance_eval(&block)
    end
    return indexreq
  end # def index

  # Search for data.
  # If a block is given, it is passed to SearchRequest#with so you can
  # more easily configure the search, like so:
  #
  #   search = client.search("foo") do
  #     query("*")
  #     histogram("field", 1000)
  #   end
  #
  #   The context of the block is of the SearchRequest object.
  public
  def search(&block)
    searchreq = ElasticSearch::SearchRequest.new(@client)
    if block_given?
      searchreq.with(&block)
    end
    return searchreq
  end # def search

  def cluster
    return @client.admin.cluster
  end

  def node
    return @client.admin.cluster
  end
end # class ElasticSearch::Client

