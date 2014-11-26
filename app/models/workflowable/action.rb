#     Copyright 2014 Netflix, Inc.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.


module Workflowable
  class Action < ActiveRecord::Base
    has_many :workflow_actions
    has_many :workflows, :through=>:workflow_actions
    has_many :stage_actions
    has_many :stages, :through=>:stage_actions
    validate :validate_action_plugin
    validates :name, :uniqueness=>true

    before_save :reject_blank_values


    serialize :options, Hash

    def reject_blank_values
      options.each{|k,v| v.reject!{ |k,v| v.blank? }}
      options.reject!{|k,v| v.blank?}
    end

    def validate_action_plugin
      begin
        if(Workflowable::Actions.constants.include?(action_plugin.to_sym))
          #if(Workflowable::Actions::Action.subclasses.include?(("Workflowable::Actions::"+action_plugin).constantize))
          return true
        end
      rescue
      end
      errors.add :action_plugin, "is invalid"
    end

    def autocomplete(field_type, value, options={}, workflow=nil, object=nil, current_stage=nil, next_stage=nil, user=nil)
      ("Workflowable::Actions::"+action_plugin).constantize.autocomplete(field_type, value, options, workflow, object, current_stage, next_stage, user)
    end


    def run(options={}, workflow, object, current_stage, next_stage, user)
      options ||={}
      plugin = ("Workflowable::Actions::"+action_plugin).constantize#("Workflowable::Actions::" + self.action_plugin.to_s).constantize
      plugin.new(self.available_options(options), workflow, object, current_stage, next_stage, user).run

    end


    def validate_options(options={}, workflow=nil, object=nil, current_stage=nil, next_stage=nil, user=nil)
      plugin = ("Workflowable::Actions::"+action_plugin).constantize#("Workflowable::Actions::" + self.action_plugin.to_s).constantize
      results = plugin.new(self.available_options(options), workflow, object, current_stage, next_stage, user).validate_options

      return results
    end


    def available_options(options={}, workflow=nil, object=nil, current_stage=nil, next_stage=nil, user=nil)
      options ||={}

      # value_options = options.with_indifferent_access.deep_dup.each{|k1,v1|
      #   v1.reject!{|k2,v2| k2!= "value" || v2.blank?};
      #   v1[:user_specified]=true;
      # }
      # default_options = options.with_indifferent_access.deep_dup.each{ |k1,v1|
      #   v1.reject!{|k2,v2| k2!= "default" || v2.blank? }
      # }



      value_options = options.with_indifferent_access.each{|k1,v1|
        v1.reject{|k2,v2| k2 != "value" || v2.blank?};
        v1[:user_specified]=true;
      }



      default_options = options.with_indifferent_access.each{ |k1,v1|
        v1.reject{|k2,v2| k2 != "default" || v2.blank? }
      }

      options = self.options.with_indifferent_access.deep_merge(default_options)

      options = value_options.with_indifferent_access.deep_merge(options)
      if(action_plugin)
        all_options = ("Workflowable::Actions::"+action_plugin).constantize.options(options, workflow, object, current_stage, next_stage, user)
      else
        all_options = {}
      end


    end

    def action_plugin_options
      ("Workflowable::Actions::"+action_plugin).constantize.options
    end


    def action_plugin_name
      ("Workflowable::Actions::"+action_plugin).constantize.name
    end

  end
end
