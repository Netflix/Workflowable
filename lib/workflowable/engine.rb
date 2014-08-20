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


require 'rubygems'
require 'rails'
require 'jquery-rails'
require 'jbuilder'
require 'nested_form'


module Workflowable
  class Engine < ::Rails::Engine
    isolate_namespace Workflowable


    config.to_prepare do
      Dir[File.dirname(__FILE__)+ "/actions/*.rb"].each {|file| require file }
      Dir[Rails.root + "lib/workflowable/actions/*.rb"].each {|file| require file } if Rails.root
    end


    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/support/factories'
    end

  end
end






#ActiveRecord::Base.send :include, Workflowable::Workflow
