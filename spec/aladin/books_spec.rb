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
      let(:per_page) { 10 }
      let(:body) { File.read(File.join(File.dirname(__FILE__), "../data/hello_result.txt")) }

      before(:each) do
        Books.configure {|c| c.ttb_key = ttb_key; c.per_page = per_page}

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

        query_params = {
          :ttbkey => ttb_key,
          :Query => query,
          :start => "1",
          :MaxResults => per_page.to_s,
          :SearchTarget => "Book",
          :output => "js"
        }
        a_request(:get, "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx")
            .with(:query => hash_including(query_params)).should have_been_made
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

      context "when error was responded" do
        let(:body) { File.read(File.join(File.dirname(__FILE__), "../data/error.txt")) }

        it "returned books has error_code and error_msg" do
          books = Books.search query

          books.should be_error
          books.error_code.should == 1
          books.error_msg.should be_present
        end
      end

      context "when page option is specified" do
        let(:page) { 2 }
        let(:per_page) { 20 }
        it "sends request including page info" do
          books = Books.search query, page: page

          query_params = {
            :Query => query,
            :start => "21",
            :MaxResults => per_page.to_s
          }
          a_request(:get, "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx")
              .with(:query => hash_including(query_params)).should have_been_made
        end
      end

      context "when per_page options is specified" do
        it "sends request including page info" do
          books = Books.search query, page: 2, per_page: 5

          query_params = {
            :Query => query,
            :start => "6",
            :MaxResults => "5"
          }
          a_request(:get, "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx")
              .with(:query => hash_including(query_params)).should have_been_made
        end
      end
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
