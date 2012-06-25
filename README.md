## aladin-books

aladin-books is the ruby wrapper of Aladin Search API.(More information about Aladin Search API is from http://blog.aladin.co.kr/ttb/category/16526940?communitytype=MyPaper.)

### Installation

You can install aladin-books by using rubygems.

    gem install aladin-books

### How to use

You need a ttb_key to use aladin api. You can get this key from http://www.aladin.co.kr/ttb/wblog_manage.aspx.  
Maybe, you need to register TTB(Thanks to Blogger) service first.(http://www.aladin.co.kr/ttb/wjoinus.aspx)

After receiving ttb_key, you are ready to use aladin-books gem.  
Here is a sample example.

    Aladin::Books.configure do |config|
      config.ttb_key = "aaa"
      config.per_page = 10
    end
    books = Aladin::Books.search "hello"

    books.first
    books.to_a
    books[1]
    books.each {|b| p b.title }
    books.map {|b| b.title}

## Contributing to aladin-books
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 aproxacs. See LICENSE.txt for
further details.

