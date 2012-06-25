require 'spec_helper'

module Aladin
  describe Books do
    let(:ttb_key) { "TTB_Key" }

    describe ".configure" do
      it "sets ttb_key" do
        Books.configure do |config|
          config.ttb_key = ttb_key
        end

        Books.ttb_key.should == ttb_key
      end

      it "sets per_page" do
        Books.configure do |config|
          config.per_page = 20
        end

        Books.per_page.should == 20
      end
    end

    describe ".search" do
      let(:query) { "hello" }
      let(:body) { File.read(File.join(File.dirname(__FILE__), "../data/hello_result.txt")) }
      before(:each) do
        Books.configure {|c| c.ttb_key = ttb_key}

        stub_request(:get, "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx")
            .with(:query => hash_including(:Query => query))
            .to_return(:body => body)
      end

      it "returns books" do
        books = Books.search query

        books.should be_a(Books)
      end

      it "sends request to aladin" do
        Books.search query
        a_request(:get, "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx")
            .with(:query => hash_including(:Query => query)).should have_been_made
      end

      it "creates books object with respond body" do
        # Response from aladin ends with ';'
        # so we need to remove this last characator in order to parse json string smoothly
        hash = JSON.parse(body.gsub(/;?/, ""))

        Books.should_receive(:new).with(hash)
        Books.search query
      end

      # it "real connection test" do
      #   WebMock.allow_net_connect!
      #   Books.ttb_key = ""
      #   Books.search "ruby"
      # end
    end


    describe "#initialize" do
      let(:body) { File.read(File.join(File.dirname(__FILE__), "../data/ruby_result.txt")) }
      let(:hash) { JSON.parse(body.gsub(/;?/, "")) }
      let(:books) { Books.new(hash) }

      it "assigns a total attribute" do
        books.total.should == 1753
      end

      it "assigns a page attribute" do
        books.page.should == 1
      end

      it "assigns a per_page attribute" do
        books.per_page.should == 10
      end

      it "creates 10 books" do
        Book.should_receive(:new).exactly(10)
        books
      end

      it "assigns books array" do
        books.length.should == 10
        books.should be_a(Array)
        books.first.should be_a(Book)
      end
    end

  end
end
