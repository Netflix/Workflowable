// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery_nested_form 
//= require_tree .




$(function() {

  $(document).foundation();

  $(".select2").select2(); 

  $(document).on('nested:fieldAdded', function(event){
    
    $(document).foundation();
    $(".select2").select2(); 
    
    // this field was just inserted into your form
    var field = event.field; 


    $(".action_plugin_select").on("change", 
    function(e) 
    { 
      options_field = $(this).closest("fieldset").find(".action_options_fields")
      options_field.addClass("active");
      $.getScript(options_field.data('url') +'?action_plugin=' + this.value + "&context=" + options_field.data('context'))
        

    });
  });


  $(".action_plugin_select").on("change", 
    function(e) 
    { 
      options_field = $(this).closest("fieldset").find(".action_options_fields")
      options_field.addClass("active");      
      $.getScript(options_field.data('url') +'?action_plugin=' + this.value + "&context=" + options_field.data('context'))
      
        

    }
  );


  $(".workflow_diagram").each(function(obj) {
    $.getJSON( $(this).data('url'), function( data ) {


    // Create a new directed graph
    var g = new dagreD3.Digraph();

    // Add nodes to the graph. The first argument is the node id. The second is
    // metadata about the node. In this case we're going to add labels to each of
    // our nodes.


    nodes = data.nodes

    for (var x in nodes)
    {

      g.addNode(nodes[x].id, { label: nodes[x].name });
    }


    edges= data.edges

    for (var x in edges)
    { 
      if(edges[x].current_stage_id != undefined && edges[x].next_stage_id != undefined )
      {
        g.addEdge(null, edges[x].current_stage_id, edges[x].next_stage_id);
      }
    }




    var renderer = new dagreD3.Renderer();

    var layout = dagreD3.layout()
                        .nodeSep(20)
                        .rankDir("LR");


    layout = renderer.layout(layout).run(g, d3.select("svg"));

     var svg = d3.select("svg")
       .attr("width", layout.graph().width + 40)
       .attr("height", layout.graph().height + 40)
       .call(d3.behavior.zoom().on("zoom", function() {
         var ev = d3.event;
         svg.select("g")
            .attr("transform", "translate(" + ev.translate + ") scale(" + ev.scale + ")");
       }));
    });
  });
  
});



