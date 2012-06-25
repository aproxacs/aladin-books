module Aladin
  class Books < Array

    class << self
      attr_accessor :ttb_key, :per_page
      def configure
        yield self
      end

      def search(query)
        uri = URI.parse('http://www.aladin.co.kr/ttb/api/ItemSearch.aspx')
        params = {
          :ttbkey => ttb_key,
          :Query => query,
          :QueryType => "Title",
          :MaxResults => 10,
          :start => 1,
          :SearchTarget => "Book",
          :output => "js"
        }
        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess)
          Books.new(JSON.parse(res.body.gsub(/;?/, "")))
        end
      end
    end

    attr_accessor :total, :page, :per_page

    def initialize(hash)
      @total = hash["totalResults"]
      @page = 1 + (hash["startIndex"]/hash["itemsPerPage"])
      @per_page = hash["itemsPerPage"]

      super hash["item"].map {|i| Book.new(i)}
    end

  end
end