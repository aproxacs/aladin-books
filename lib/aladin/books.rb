module Aladin
  class Books < Array

    class << self
      attr_accessor :ttb_key, :per_page
      def configure
        yield self
      end

      def search(query)
        uri.query = URI.encode_www_form(default_params.update(:Query => query))
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess)
          body = res.body.gsub(/;?/, "")
          hash = JSON.parse(body) rescue JSON.parse(body.gsub("'", '"'))

          Books.new(hash)
        end
      end

      private
        def uri
          @uri ||= URI.parse('http://www.aladin.co.kr/ttb/api/ItemSearch.aspx')
        end

        def default_params
          @default_params ||= {
            :ttbkey => ttb_key,
            :QueryType => "Title",
            :MaxResults => per_page,
            :start => 1,
            :SearchTarget => "Book",
            :output => "js"
          }
        end
    end

    attr_accessor :total, :page, :per_page, :error_code, :error_msg

    def initialize(hash)
      if hash["errorCode"]
        set_error(hash)
      else
        set_page_info(hash)

        super hash["item"].map {|i| Book.new(i)}
      end
    end

    def error?
      @error_code.present?
    end

    private
      def set_error(hash)
        @error_code = hash["errorCode"]
        @error_msg = hash["errorMessage"]
      end

      def set_page_info(hash)
        @total = hash["totalResults"]
        @page = 1 + (hash["startIndex"]/hash["itemsPerPage"])
        @per_page = hash["itemsPerPage"]
      end

  end
end