require 'vertx'
require 'json/pure'
require 'cgi'
require 'date'
require 'memcache'

$LOAD_PATH.push( File.dirname(__FILE__) + "/../lib" )
require 'pastehub'

notifyHash = Memcache.new( :server => "localhost:11211" )

masterdb_server = Vertx::HttpServer.new
masterdb_server.request_handler do |req|

  req.body_handler do |body|
    util = PasteHub::Util.new
    auth = PasteHub::AuthForServer.new( "/var/pastehub/" )
    ret = auth.invoke( req.headers, util.currentSeconds() )

    if ret[0]
      username = ret[1]
      puts "Connected from user [#{username}]"
    else 
      puts "Error: " + ret[1].to_s
      req.response.status_code = 403
      req.response.status_message = "Authorization failure."
      req.response.end
      return
    end

    masterdb = PasteHub::MasterDB.new
    masterdb.open( username )

    case req.path
    when "/insertValue"
      data = body.to_s.dup

      # update db
      key = util.currentTime( ) + "=" + util.digest( data )
      puts "[#{username}]:insertValue: key=[#{key}] : " + data
      masterdb.insertValue( key, data )

      # notify to all client
      notifyHash[ username ] = key
      masterdb.close()
      req.response.end()

    when "/putValue"
      data = body.to_s.dup

      # update db
      key = req.headers[ 'X-Pastehub-Key' ].dup
      puts "[#{username}]:putValue: key=[#{key}] : " + data
      masterdb.insertValue( key, data )

      # notify to all client
      notifyHash[ username ] = key
      masterdb.close()
      req.response.end()

    when "/getList"
      str = masterdb.getList( ).join( "\n" )
      puts "[#{username}]:getList's response: "
      puts str
      masterdb.close()
      req.response.end( str )

    when "/getValue"
      k = body.to_s.chomp
      str = masterdb.getValue( k.dup )
      if str
        str
      else
        ""
      end
      puts "[#{username}]:getValue:" + k
      masterdb.close()
      req.response.end( str )
    end

  end
end.listen(8081, 'localhost')
