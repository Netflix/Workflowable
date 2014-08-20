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
    class Stage < ActiveRecord::Base
        belongs_to :workflow,  :inverse_of=>:stages
        has_many :stage_next_steps, :foreign_key=>:current_stage_id
        has_many :next_steps,
            :through=>:stage_next_steps,
            :class_name=>"Stage",
            :source=>:next_stage






        has_many :before_stage_actions, -> { where(event: 'before').order("position ASC") }, class_name: 'StageAction'
        has_many :after_stage_actions, -> { where(event: 'after').order("position ASC") }, class_name: 'StageAction'

        has_many :before_actions, :through=>:before_stage_actions, :class_name=>'Action', :source=>:action
        has_many :after_actions, :through=>:after_stage_actions, :class_name=>'Action', :source=>:action

        validates :name, :presence=>true
        validates :name, :uniqueness=>{:scope=> :workflow_id}

        #validates :workflow_id, :presence=>true
        validates_presence_of :workflow_id, :unless => lambda {|stage| stage.workflow.try(:valid?)}
        validates_associated :workflow

        accepts_nested_attributes_for :before_actions, :allow_destroy => true
        accepts_nested_attributes_for :after_actions, :allow_destroy => true
        accepts_nested_attributes_for :stage_next_steps, :allow_destroy => true





        def run_before_actions(options={}, object, current_stage, user)
            options ||= {}
            self.before_actions.each do |action|
                action.run(options[action.name], self.workflow, object, current_stage, self, user)
            end
        end

        def run_after_actions(options={}, object, next_stage, user)
            options ||= {}
            self.after_actions.each do |action|
                action.run(options[action.name], self.workflow, object, self, next_stage, user)
            end
        end

        def validate_after_actions(options={}, object, next_stage, user)
            options ||= {}
            after_action_errors = {}
            after_actions.each do |action|
                errors = action.validate_options(options[action.name] || {}, self.workflow, object, self, next_stage, user)
                after_action_errors[action.name] = errors if errors.present?
            end
            after_action_errors
        end

        def validate_before_actions(options={}, object, current_stage, user)
            options ||= {}
            before_action_errors = {}
            before_actions.each do |action|
                errors = action.validate_options(options[action.name] || {}, self.workflow, object, current_stage, self, user)
                before_action_errors[action.name] = errors if errors.present?
            end
            before_action_errors
        end

        def run_after_options(options={}, object, next_stage, user)
            options ||= {}
            after_action_options = {}
            after_actions.each do |action|
                after_action_options[action.name] = action.available_options(options[action.name] || {}, self.workflow, object, self, next_stage, user)
            end
            after_action_options
        end

        def run_before_options(options={}, object, current_stage, user)
            options ||= {}
            before_actions_options = {}
            before_actions.each do |action|
                before_actions_options [action.name] = action.available_options(options[action.name] || {}, self.workflow, object, current_stage, self, user)
            end
            before_actions_options
        end

    end
end
