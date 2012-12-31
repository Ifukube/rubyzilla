module Rubyzilla
  class Bug
    # From taskmapper-bugzilla:lib/provider/ticket.rb
    attr_accessor :product_id
    attr_accessor :id
    attr_accessor :project_id
    attr_accessor :component_id
    attr_accessor :summary
    attr_accessor :title
    attr_accessor :version
    attr_accessor :op_sys
    attr_accessor :platform
    attr_accessor :priority
    attr_accessor :description
    attr_accessor :alias
    attr_accessor :qa_contact
    attr_accessor :assignee
    def assigned_to
      @assignee
    end
    attr_accessor :requestor
    def qa_contact
      @requestor
    end
    attr_accessor :status
    attr_accessor :target_milestone
    attr_accessor :severity
    attr_accessor :creation_time
    attr_accessor :last_change_time

=begin
    # Required create parameters
    attr_accessor :product_id, :summary, :version
    attr_accessor :component_id
    #@product # String value component for creation
    
    # Defaulted create parameters
    attr_accessor :op_sys, :platform, :priority, :severity
    attr_accessor :description
    
    # Optional create parameters
    attr_accessor :alias, :assigned_to, :cc, :qa_contact, :status
    attr_accessor :target_milestone
=end

    # To hold raw client data that came back from bugzilla
    attr_accessor :system_data

    def initialize id=nil
      unless id.nil?
        result = Bugzilla.server.call("Bug.get", {:ids => [id],
                                                  :include_fields => [:id, :product, :component, :summary, :version,
                                                                      :status, :creation_time, :last_change_time,
                                                                      :flags, :depends_on, :blocks, :clone_of]})
        #result = Bugzilla.server.call("Bug.get_bugs", {:ids => [id]})

        @system_data = result['bugs'][0]

        # TODO: These all need rework
        @id           = result["bugs"][0]["id"]
        @product_id   = result["bugs"][0]["product"]
        @component_id = result["bugs"][0]["component"][0]
        @summary      = result["bugs"][0]["summary"]
        #@title
        @version      = result["bugs"][0]["version"][0]
        #@op_sys       = result["bugs"][0]["internals"]["op_sys"]
        #@platform     = result["bugs"][0]["internals"]["rep_platform"]
        #@priority     = result["bugs"][0]["internals"]["priority"]
        #@description  = result["bugs"][0]["internals"]["short_desc"]
        #@alias        = result["bugs"][0]["alias"]
        #@qa_contact   = result["bugs"][0]["internals"]["qa_contact"]
        #@assignee
        #@requestor
        @status       = result["bugs"][0]["status"]
        #@target_milestone = result["bugs"][0]["internals"]["target_milestone"]
        #@severity     = result["bugs"][0]["internals"]["bug_severity"]
        @creation_time   = result["bugs"][0]["creation_time"]
        @last_change_time   = result["bugs"][0]["last_change_time"]
      end
      return self
    end
    
    #def product
    #  Product.new(@product_name)
    #end
    
    #def product= _product
    #  @product_name = _product.name
    #  #@product = _product.name
    #end
    
    def create
      if Bugzilla.logged_in?
        parameters = {
          #:product => @product,
          :component => @component,
          :summary => @summary || "",
          :version => @version || "unspecified",
          :op_sys => @op_sys || "Windows",
          :platform => @platform || "PC",
          :priority => @priority || "P5",
        }
      
        parameters.merge!({:severity => @severity}) if @severity
        parameters.merge!({:description => @description}) if @description
        parameters.merge!({:alias => @alias}) if @alias && @alias != ""
        parameters.merge!({:assigned_to => @assigned_to}) if @assigned_to
        parameters.merge!({:cc => @cc}) if @cc
        parameters.merge!({:qa_contact => @qa_contact}) if @qa_contact
        parameters.merge!({:status => @status}) if @status
        parameters.merge!({:target_milestone => @target_milestone}) if
          @target_milestone

        result = Bugzilla.server.call("Bug.create", parameters)
        
        @id = result["id"].to_i
      end
      return self
    end
    
    def add_comment(comment)
      if Bugzilla.logged_in?
        Bugzilla.server.call("Bug.add_comment", {:id => id, :comment => comment}) 
      end
    end
  end
end
