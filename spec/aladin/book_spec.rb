require 'spec_helper'

module Aladin
  describe Book do
    describe "#initialize" do
      it "receives hash as paramenter and assigns attributes with hash" do
        book = Book.new title: "ruby rules"
        book.title.should == "ruby rules"
      end

      it "key is underscored if key is camelstring" do
        book = Book.new :categoryId => 439
        book.category_id.should == 439
      end
    end
  end
end
