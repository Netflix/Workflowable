json.nodes @workflow.stages, :id, :name



next_steps=[]
@workflow.stages.each{|s| next_steps += s.stage_next_steps}

json.edges next_steps, :current_stage_id, :next_stage_id
