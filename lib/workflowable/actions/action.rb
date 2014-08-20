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
    module Actions
        class Action
            NAME = ""
            OPTIONS = {}

            def initialize(options={}, workflow=nil, object=nil, current_stage=nil, next_stage=nil, user=nil)
                options ||={}
                @options = options.with_indifferent_access
                @workflow = workflow
                @object = object
                @current_stage = current_stage
                @next_stage = next_stage
                @user = user

                errors = validate_options

                if(errors.present?)
                    return errors
                end

            end

            def run

            end

            def self.autocomplete(field_type=nil, value=nil, options={}, workflow=nil, object=nil, current_stage=nil, next_stage=nil, user=nil)
            end

            def self.name
                return self::NAME
            end

            def self.options(options={}, workflow=nil, object=nil, current_stage=nil, next_stage=nil, user=nil)

                return self::OPTIONS.with_indifferent_access.deep_merge(options)
            end

            def validate_options
                errors = []
                current_options = self.class.options(@options, @workflow, @object, @current_stage, @next_stage, @user)
                begin

                    @options.assert_valid_keys(current_options.keys)
                rescue ArgumentError=>e
                    errors << "#{e.message} for action: #{self.class.name}\n"
                end

                missing_keys = current_options.reject{|k,v| v[:required] != true }.keys - @options.reject{|k,v| v[:value].blank? }.keys

                missing_keys.each do |k|
                    errors <<  "#{k} is required\n"
                end

                return errors.blank? ? nil : errors
            end

        end
    end
end
