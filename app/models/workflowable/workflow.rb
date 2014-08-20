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
    class Workflow < ActiveRecord::Base
        has_many :stages, :inverse_of=>:workflow
        belongs_to :initial_stage, :class_name=>Stage
        has_many :workflow_actions, -> { order("position ASC") }
        has_many :actions, :through=>:workflow_actions
        accepts_nested_attributes_for :stages, :allow_destroy => true
        accepts_nested_attributes_for :actions, :allow_destroy => true



        validates :name, :presence=>true
        validates :name, :uniqueness=>true



        def run_workflow_actions(options={}, object, current_stage, next_stage, user)
            actions.each do |action|
                action.run(options.try(:[],action.name), self, object, current_stage, next_stage, user)
            end
        end

        def workflow_action_options(options={}, object, current_stage, next_stage, user)
            options ||= {}
            workflow_action_options = {}
            actions.each do |action|
                workflow_action_options[action.name] = action.available_options(options.try(:[],action.name) || {}, self, object, current_stage, next_stage, user)
            end
            workflow_action_options
        end

        def validate_action_options(options={}, object, current_stage, next_stage, user)
            options ||= {}
            action_errors = {}
            actions.each do |action|
                errors = action.validate_options(options[action.name] || {}, self, object, current_stage, next_stage, user)
                action_errors[action.name] = errors if errors.present?
            end
            action_errors
        end
    end
end
