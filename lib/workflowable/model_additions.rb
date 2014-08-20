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


require 'active_record/railtie'
require 'active_support/core_ext'

module Workflowable
  module ModelAdditions
    #extend ActiveSupport::Concern

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_workflowable
        include Workflowable::ModelAdditions::LocalInstanceMethods
        class_eval do
          attr_accessor :workflow_options
          attr_accessor :current_user

          belongs_to :workflow, :class_name => "Workflowable::Workflow"
          belongs_to :stage, :class_name => "Workflowable::Stage"
          before_save :set_default_stage

        end
      end
    end

    module LocalInstanceMethods




      def next_step_options(next_step, options={}, user=nil, unspecified_only=false)
        options ||= {}

        if(user.nil? && defined? current_user)
          user = current_user
        end



        if(stage)
          next_stage = stage.next_steps.find_by_id(next_step)
        else
          next_stage = workflow.stages.find_by_id(next_step)
        end

        if(next_stage)
          next_stage_options = {}
          next_stage_options[:global] = workflow.workflow_action_options(options[:global], self, self.stage, next_stage, user)
          next_stage_options[:before] = next_stage.run_before_options(options[:before], self, self.stage, user)
          next_stage_options[:after] = stage.run_after_options(options[:after], self, next_stage, user) if stage
          return next_stage_options

        else
          return nil
        end

      end



      def validate_actions(stage_id, options={}, user=nil)
        options ||= {}
        errors=[]

        if(user.nil? && defined? current_user)
          user = current_user
        end

        if(stage)
          new_stage = stage.next_steps.find_by_id(stage_id)
        else
          new_stage = workflow.stages.find_by_id(stage_id)
        end

        if(new_stage)
          workflow_errors = workflow.validate_action_options(options[:global], self, self.stage, new_stage, user)
          after_errors = stage.present? ?  stage.validate_after_actions(options[:after], self, new_stage, user) : nil
          before_errors = new_stage.validate_before_actions(options[:before], self, self.stage, user)
          errors << workflow_errors if workflow_errors.present?
          errors << after_errors if after_errors.present?
          errors << before_errors if before_errors.present?

          if(errors.present?)
            return errors
          end
          return nil
        else
          return errors + ["Could not identify next stage"]
        end

      end

      def set_stage(stage_id, options={}, user=nil)
        options ||= {}
        errors=[]
        if(user.nil? && defined? current_user)
          user = current_user
        end

        errors = validate_actions(stage_id, options, user)

        if(errors.present?)
          return errors
        end

        if(stage)
          new_stage = stage.next_steps.find_by_id(stage_id)
        else
          new_stage = workflow.stages.find_by_id(stage_id)
        end

        if(new_stage)

          workflow.run_workflow_actions(options[:global], self, self.stage, new_stage, user)
          stage.run_after_actions(options[:after], self, new_stage, user) if stage
          new_stage.run_before_actions(options[:before], self, self.stage, user)
          update_attributes(stage_id: new_stage.id)
          return true
        end
      end



      private

      def set_default_stage
        self.set_stage(workflow.initial_stage_id, self.workflow_options) if (workflow && workflow.initial_stage_id && self.stage.blank?)
        #self.stage_id = workflow.initial_stage_id

      end



    end
  end
end
