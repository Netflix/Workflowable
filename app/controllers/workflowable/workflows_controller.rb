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


require_dependency "workflowable/application_controller"

module Workflowable
  class WorkflowsController < ApplicationController
    before_filter :load_workflow, only: [:show, :edit, :update, :destroy, :stages, :configure_stages]
    def index
      @workflows = Workflowable::Workflow.order(:name)
    end

    def new
      @workflow = Workflow.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @workflow }
      end
    end

    # GET /workflows/1/edit
    def edit

    end

    # POST /workflows
    # POST /workflows.json
    def create
      @workflow = Workflow.new(workflow_params)


      respond_to do |format|
        if @workflow.save
          format.html {
            if(@workflow.stages.count > 1)
              redirect_to configure_stages_workflow_path(@workflow), notice: 'Workflow was successfully created. Please configure transitions.'
            else
              redirect_to @workflow, notice: 'Workflow was successfully created.'
            end

          }
          format.json { render json: @workflow, status: :created, location: @workflow }
        else
          format.html { render action: "new" }
          format.json { render json: @workflow.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /workflows/1
    # PUT /workflows/1.json
    def update


      respond_to do |format|
        if @workflow.update_attributes(workflow_params)
          format.html { redirect_to @workflow, notice: 'Workflow was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @workflow.errors, status: :unprocessable_entity }
        end
      end
    end

    def show


      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @workflow }
      end

    end

    def stages

    end

    def configure_stages

    end


    # DELETE /workflows/1
    # DELETE /workflows/1.json
    def destroy
      @workflow.destroy

      respond_to do |format|
        format.html { redirect_to workflows_url }
        format.json { head :no_content }
      end
    end

    private


    def workflow_params

      #params.require(:search).permit(:name, :description, :provider, :query, :tag_list).merge(:options =>all_options)

      params.require(:workflow).permit!

      # params.require(:workflow).permit(:name, :workflow_id,
      #   :actions_attributes=>[:id, :name, :action_plugin, :_destroy],
      #   :stages_attributes=>[:id, :name, :_destroy,
      #     :before_actions_attributes=>[:id, :name, :action_plugin, :_destroy],
      #     :after_actions_attributes=>[:id, :name, :action_plugin, :_destroy],
      #     :stage_next_steps_attributes=>[:next_stage_id, :id, :_destroy]

      #   ]
      # ).tap do |whitelisted|
      #   whitelisted[:actions_attributes] = params[:workflow].try(:[],:actions_attributes)
      #   whitelisted[:stages_attributes] = params[:workflow].try(:[], :stages_attributes)
      # end
    end

    def load_workflow
      @workflow = Workflow.find(params[:id])
    end
  end

end
