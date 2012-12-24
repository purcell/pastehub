PasteHub
=======================

## Server Sample

1. enviroment veriable

  export JRUBY_HOME=/usr/local

2. tested version

  1) platform
     jdk-1.7.0_05
     vert.x-1.3.0.final
     jruby-1.7.0

  2) gems
     activemodel (3.2.9)
     activesupport (3.2.9)
     aws-sdk (1.7.1, 1.5.7)
     builder (3.1.4, 3.0.4)
     bundler (1.2.2)
     diff-lcs (1.1.3)
     dynamoid (0.5.0, 0.4.1)
     fake_dynamo (0.1.1)
     gdbm (1.2)
     highline (1.6.15)
     httparty (0.9.0, 0.8.3)
     i18n (0.6.1)
     jeweler2 (2.0.9)
     json (1.7.5 java)
     memcache (1.2.13)
     multi_json (1.3.7)
     multi_xml (0.5.1)
     nokogiri (1.5.5 java)
     rack (1.4.1)
     rack-protection (1.2.0)
     rake (10.0.1, 0.9.2.2)
     rspec (2.12.0)
     rspec-core (2.12.0)
     rspec-expectations (2.12.0)
     rspec-mocks (2.12.0)
     sinatra (1.3.3)
     tilt (1.3.3)
     tzinfo (0.3.35)
     uuidtools (2.1.3)


2. config file
{
  "aws":           true,
  "dynamoAccessKey": "xxx",
  "dynamoSecretKey": "xxx",
  "memcacheHost":  "localhost:11211",
  "domain":        "pastehub.org" # or "pastehub.net" (table prefix name)
}


3. Create tables on DynamoDB
  1) users
    tablename:  pastehub.org_users
    key:        username 

  2) entries
    tablename:  pastehub.org_entries
    key:        userkey

## Client Sample

1. Start
  PastehubSync

2. config file for local customization

~/.pastehub.conf
{
  "targetApiURL":        "http://localhost:8000/",
  "targetNotifierURL":   "http://localhost:8001/",
  "localDbPath":         "/tmp/local/"
}

