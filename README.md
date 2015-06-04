[fluent-plugin-riak2f](https://github.com/kyanagimoto/fluent-plugin-riak2), a plugin for [Fluentd](http://fluentd.org)
==================


`fluent-plugin-riak2f` is a fluentd output plugin designed to stuff log messages into a riak cluster.

This version is based on the work of [fluent-plugin-riak2](https://github.com/collectivehealth/fluent-plugin-riak2).  We are very thankful for his effort and his decision to release the work under the Apache 2 license.

`fluent-plugin-riak2` is designed to be used with Riak 2.x clusters and it's yokozuna/solr based search engine.  Support for secondary indicies is limited and should be considered deprecated.

Riak ( http://github.com/basho/riak ) is an open-source distributed KVS focused on availability.

Current status is still proof-of-concept: index setting and its configuration are to be decided. Also performance optimization is required. Another idea is in_tail_riak by using riak post-commit.

installation
------------

```bash
$ sudo gem install fluent-plugin-riak2f
```

Notice: you need Riak configured using eleveldb as backend.


fluent.conf example
-------------------

```
<match riak2.**>
  type riak2

  buffer_type memory
  flush_interval 10s
  retry_limit 5
  retry_wait 1s
  buffer_chunk_limit 256m
  buffer_queue_limit 8096
  bucket_type defalut # if not set, will use 'default'
  bucket_name fluentdlog # if not set, will use 'fluentdlog'

  # pb port
  nodes 127.0.0.1:8087
  #for cluster, define multiple machines
  #nodes 192.168.100.128:10018 129.168.100.128:10028
</match>

```

- key format -> %Y%m%d%H%M%S-<uuid>
- value format -> [records] in JSON
- index:

 - year_int -> year
 - month_bin -> <year>-<month>
 - tag_bin -> tags

easy querying log
-----------------

```bash
$ curl -X PUT http://localhost:8098/buckets/static/keys/browser.html -H 'Content-type: text/html' -d @browser.html
$ open http://localhost:8098/buckets/static/keys/browser.html
```

License
=======

Apache 2.0

Copyright Kota UENISHI, Collective Health, Inc.
