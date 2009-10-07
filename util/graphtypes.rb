#!/usr/bin/ruby

$file = "types.lil"
$dir = File.dirname(File.dirname(__FILE__))

base = { "string" => "str", "integer" => "int", "float" => "flt", "nil" => "nil", "cons" => "cons", "list" => "list", "bot" => "bot" }

dot = []

re = /^\s*(\w+?) <- \[(.+?)\](?:\s*\+\s*\[(.+?)\])?/
comma = /\s*,\s*/
firstword = /^([^(]+)/

descs = {}

dot << "digraph G {"
dot << "  rankdir=LR;"
dot << "  node [shape=plaintext,fontsize=10,color=\"#666666\"];"
dot << "  edge [color=\"#0000ff\"];"

IO.foreach("#{$dir}/#{$file}") do |line|
  if m = re.match(line)
    cl = m[1]
    next if m[2] == "pred"
    parents = m[2].split(comma);
    descs[cl] = m[3] ? m[3].split(comma) : false;
    next if m[2] == "bot"
    parents.each do |par|
      dot << "  #{par}:class:e -> #{cl}:class:w [group=\"c_#{ par }\"];" if !base[par]
    end
  end
end


uses = []
dot << '  edge [color="#ff0000",arrowType="empty"]'

descs.each do |cl, feats|
  featstr = feats ?
    feats.map do |f|
          if f
            (fname, fclass) = f.split("\\");
            m = firstword.match(fclass)
            fclass = m[1] if m
            fdname = fname
            if base[fclass]
              fdname += "<font color=\"#666666\">:" + base[fclass] + "</font>"
            end
            uses << "  #{ cl }:#{ fname }:e -> #{ fclass }:class:w [group=\"f_#{ cl }\"];" if fclass && !base[fclass]
          end
          "<tr><td port=\"#{ fname }\"><font point-size=\"10\">#{ fdname }</font></td></tr>"
        end :
      "";
  dot << "  #{cl} [label=< <table border=\"0\" cellborder=\"1\"><tr><td port=\"class\" bgcolor=\"#cccccc\">#{cl}</td></tr>#{ featstr }</table> >];"
end
dot << uses.join("\n")
dot << "}"

IO.popen("dot -Tpng -otypes.png", "w") do |f|
  f.puts dot.join("\n")
end
