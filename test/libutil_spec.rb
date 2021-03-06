#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# libutil_spec.rb -  "RSpec file for util.rb"
#
#   Copyright (c) 2012-2012  Kiyoka Nishiyama  <kiyoka@sumibi.org>
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
require 'pastehub'
include PasteHub


describe Util, "When message digest util is called...  " do

  before do
    @util = Util.new
  end

  it "should" do
    @util.digest( "text data1" ).should   == "f0c62da87f30bff2543cbd44733c17ea9ba84f68"
    @util.digest( "line 1
line 2
line 3
line 4
"
                  ).should                == "0a95120b8f964aed834e1781898d5243f6878a69"
    @util.currentTime().should            match( /^[0-9]+=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ )
  end
end


describe Util, "When key util is called...  " do

  before do
    @util = Util.new

    @key1 = "1338738983=06/04/12:00:56:22=f0c62da87f30bff2543cbd44733c17ea9ba84f68"
    @key2 = "1338814085=06/04/12:21:48:04=0a95120b8f964aed834e1781898d5243f6878a69"
  end

  it "should" do
    @util.key_seconds( @key1 ).should    == 1338738983
    @util.key_timestamp( @key1 ).should  == '06/04/12:00:56:22'
    @util.key_digest( @key1 ).should     == 'f0c62da87f30bff2543cbd44733c17ea9ba84f68'
  end
end


describe Util, "When use list utils " do

  before do
    @util = Util.new

    @list1 = [ 1,2,3,4,5,6,7,8,9,10 ]
  end

  it "should" do
    @util.takeList( @list1, -2 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]
    @util.takeList( @list1, -1 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]
    @util.takeList( @list1,  0 ).should     == [                      ]
    @util.takeList( @list1,  1 ).should     == [ 1                    ]
    @util.takeList( @list1,  2 ).should     == [ 1,2                  ]
    @util.takeList( @list1,  3 ).should     == [ 1,2,3                ]
    @util.takeList( @list1,  8 ).should     == [ 1,2,3,4,5,6,7,8      ]
    @util.takeList( @list1,  9 ).should     == [ 1,2,3,4,5,6,7,8,9    ]
    @util.takeList( @list1, 10 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]
    @util.takeList( @list1, 11 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]

    @util.dropList( @list1, -2 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]
    @util.dropList( @list1, -1 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]
    @util.dropList( @list1,  0 ).should     == [ 1,2,3,4,5,6,7,8,9,10 ]
    @util.dropList( @list1,  1 ).should     == [   2,3,4,5,6,7,8,9,10 ]
    @util.dropList( @list1,  2 ).should     == [     3,4,5,6,7,8,9,10 ]
    @util.dropList( @list1,  9 ).should     == [                   10 ]
    @util.dropList( @list1, 10 ).should     == [                      ]
    @util.dropList( @list1, 11 ).should     == [                      ]
  end
end


describe Util, "When master's diffList is larger " do

  before do
    @util = Util.new

    @masterList = [ "a", "b", "c", "d" ]
    @localList  = [      "b", "c"      ]
  end

  it "should" do
    @util.diffList( @masterList, @localList  ).should == [ "a", "d" ]
    @util.diffList( @localList,  @masterList ).should == [ ]
  end
end

describe Util, "When local's diffList is larger " do

  before do
    @util = Util.new

    @masterList = [      "2",      "4" ]
    @localList  = [ "1", "2", "3", "4" ]
  end

  it "should" do
    @util.diffList( @masterList, @localList  ).should == [ ]
    @util.diffList( @localList,  @masterList ).should == [ "1", "3" ]
  end
end

describe Util, "When differs in first 5 entries " do

  before do
    @util = Util.new

    @masterList = [      "2", "3",      "5", "6", "7", "8", "9", "10", "11", "12", "13", "7", "8", "9", "10", "11", "12", "13" ]
    @localList  = [ "1",      "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13" ]
  end

  it "should" do
    @util.diffList( @masterList, @localList  ).should == [ "2" ]
    @util.diffList( @localList,  @masterList ).should == [ "1", "4" ]
  end
end

