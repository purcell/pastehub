#
# localdb.rb - PasteHub's localdb manager
#  
#   Copyright (c) 2009-2011  Kiyoka Nishiyama  <kiyoka@sumibi.org>
#   
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#   
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#  
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#  
#   3. Neither the name of the authors nor the names of its contributors
#      may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#  
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
#
require 'gdbm'

module PasteHub

  ONLINE_STATE_KEY='__ONLINE_STATE'
  LOCAL_DATE_KEY  ='__LOCAL_DATE'
  SERVER_DATE_KEY ='__SERVER_DATE'

  LOCAL_PREFIX  = "local::"
  SERVER_PREFIX = "server::"

  class LocalDB
    def initialize( basepath = "/tmp/")
      @basepath = basepath
    end

    def open( username, reader = false )
      (60*2).times { |n|
        if reader
          @db = GDBM.new( @basepath + username + ".db", nil, GDBM::READER  | GDBM::NOLOCK )
        else
          @db = GDBM.new( @basepath + username + ".db", nil, GDBM::WRCREAT )
        end
        if not @db.closed?
          break
        end
        #STDERR.puts "#Warning: DB open fail(locked) retry..."
        sleep 0.5
      }
      if @db.closed?
        raise RuntimeError, sprintf( "DBM.new open error: file=%s", username + ".db" )
      end
      @username = username
    end

    def getList( limit = nil )
      arr = self._getList().reject{|x| x.match( /^_/ )}
      if limit
        arr.take( limit )
      else
        arr
      end
    end

    def _getList( )
      forward_match_keys( LOCAL_PREFIX ).sort {|a,b| -(a <=> b) }.map {|x|
        x[(LOCAL_PREFIX.size)...(x.size)]
      }
    end

    def getServerList( )
      self._getServerList().reject{|x| x.match( /^_/ )}
    end

    def _getServerList( )
      forward_match_keys( SERVER_PREFIX ).sort {|a,b| -(a <=> b) }.map {|x|
        x[(SERVER_PREFIX.size)...(x.size)]
      }
    end

    def getValue( key, fallback = false )
      val = @db[ LOCAL_PREFIX + key ]
      if val
        val.force_encoding("UTF-8")
      else
        fallback
      end
    end

    def insertValue( key, value )
      @db[ LOCAL_PREFIX + key.force_encoding("ASCII-8BIT") ] = value.force_encoding("ASCII-8BIT")
    end

    def deleteValue( key )
      val = @db[ LOCAL_PREFIX + key ]
      if val
        @db.delete( LOCAL_PREFIX + key )
        true
      else
        false
      end
    end

    def setServerFlag( key )
      @db[ SERVER_PREFIX + key ] = '1'
    end

    def onServer?( key )
      if @db[ SERVER_PREFIX + key ]
        true
      else
        false
      end
    end

    def forward_match_keys( prefix )
      @db.keys( ).select {|key|
        key.match( "^" + prefix )
      }
    end

    def clear
      @db.clear
    end

    def close
      @db.close
    end
  end
end
