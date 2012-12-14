module Rubyzilla
  class Product
    attr_accessor :id, :name

    # Rather than search for projects by id, which is not readily available to the user, search
    # by product name
    def initialize name
      product = Bugzilla.server.call("Product.get_products", {:names => [name]})
      #product = Bugzilla.server.call("Product.get_products", {:ids => [id]})
      @id = product["products"][0]["id"]
      @name = product["products"][0]["name"]
    end
    
    # accessible, enterable, selectable
    def self.list s="accessible"
      product_list = Array.new

      product_names = Bugzilla.server.call("Product.get_#{s}_products")["names"]

      product_names.map {|name| product_list << Product.new(name) }
      return product_list
    end
    
    def components
      result = Bugzilla.server.call("Bug.legal_values", {
        :field => 'component', :product_id => @id
      })
      return result["values"]
    end
    
    def milestones
      result = Bugzilla.server.call("Bug.legal_values", {
        :field => 'target_milestone', :product_id => @id
      })
      result["values"]
    end
    
    def versions
      result = Bugzilla.server.call("Bug.legal_values", {
        :field => 'version', :product_id => @id
      })
      result["values"]
    end
    
    def to_s
      @name
    end
  end
end
