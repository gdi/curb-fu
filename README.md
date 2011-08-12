# curb-fu - easy-to-use wrapper around curb - the ruby wrapper around libcurl

* http://github.com/curb-fu

Curb can be found at http://github.com/taf2/curb

## License

This gem is released under the terms of the Ruby license.  See the LICENSE file for details.

## Troubleshooting

If you are POSTing data and curb seems to be locking up, try posting it with an explicit 'Expect: 100-continue' header.

You can set this per-request, e.g.
    
    CurbFu.post({:host => 'example.com', :headers => { "Expect" => "100-continue" }}, { "data" => "here" })

or you can configure it as a global header, e.g.

    CurbFu.global_headers = { "Expect" => "100-continue" }
    # ... then make your requests as normal

however you feel best.

## Prerequisites

* Ruby (tested on 1.8.7, 1.9.1)
* The Curb gem (and its libcurl dependency)
  * http://github.com/taf2/curb

## Installation

    $ gem install curb-fu --source http://gems.github.com

Or, if you ahve the source:

    $ cd <source-dir>
    $ rake gem
    $ gem install pkg/

## Examples

Urls can be requested using hashes of options or strings.  The GET, POST, PUT, and DELETE methods are supported 
through their respective methods on CurbFu and CurbFu::Request. 

### String Examples

    response = CurbFu.get('http://slashdot.org')
    puts response.body

    response = CurbFu.post('http://example.com/some/resource', { :color => 'red', :shape => 'sphere' })
    puts response.body unless response.success?

### Hash Examples

    response = CurbFu.get(:host => 'github.com', :path => '/gdi/curb-fu')
    puts response.body

    response = CurbFu.post({:host => 'example.com', :path => '/some/resource'}, { :color => 'red', :shape => 'sphere' })
    puts response.body unless response.success?

if you need https:
    
    response = CurbFu.post({:host => 'example.com', :path => '/some/resource', :protocol => "https"}, { :color => 'red', :shape => 'sphere' })
    
### Cookies; changes as of 0.6.1

if you want to send a cookie, previous to 0.6.1 you have to pass a block to the HTTP verb method like so:

    response = CurbFu.get("http://myhost.com") do |curb|
      curb.cookies = "SekretToken=123234234235;"
    end

As of 0.6.1 one can set the cookies either as an optional final parameter or via a hash, e.g.:

    response = CurbFu.get("http://myhost.com", { :param => "value" }, "SekretToken=123234;")
    # or with a hash:
    response = CurbFu.get({ :host => "http://myhost", :cookies => "SekretToken=1234;" })

etc.

Have fun!

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
* Send a pull request!

## Contributors

* thickpaddy (https://github.com/thickpaddy)
* hoverlover (https://github.com/hoverlover)

## Original Authorship

* dkastner (https://github.com/dkastner)
* hypomodern (https://github.com/hypomodern)
* Greenview Data, Inc. (http://greenviewdata.com)
