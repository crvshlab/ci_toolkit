# frozen_string_literal: true

# Credits: https://metabates.com/2011/02/07/building-interfaces-and-abstract-classes-in-ruby/
module AbstractInterface
  # Use this if you want to enforce some form of contract for an implementing class
  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(klass)
    klass.send(:include, AbstractInterface::Methods)
    klass.send(:extend, AbstractInterface::Methods)
  end

  module Methods

    def api_not_implemented(klass, method_name = nil)
      if method_name.nil?
        caller.first.match(/in \`(.+)\'/)
        method_name = $1
      end
      raise AbstractInterface::InterfaceNotImplementedError.new("#{klass.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end

  end
  
end

module CiToolkit
  # This needs to be implemented if you want to implement a distribution version control system be used by 
  # ci_toolkit. Similar to GithubPr and GitlabPr classes
  class DvcsPr
    include AbstractInterface
    
    def title
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def number
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def lines_of_code_changed
      CiToolkit::DvcsPr.api_not_implemented(self)
    end
    
    def comments
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def comment(text)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def delete_comments_including_text(text)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def comment(text)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def delete_comments_including_text(text)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def delete_comment(comment_id)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def find_comments_including_text(text)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def labels
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def files
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def create_status(state, context, target_url, description)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def get_status(context)
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def build_types
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def infrastructure_work?
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def work_in_progress?
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def big?
      CiToolkit::DvcsPr.api_not_implemented(self)
    end

    def realm_module_modified?
      CiToolkit::DvcsPr.api_not_implemented(self)
    end
  end

end
