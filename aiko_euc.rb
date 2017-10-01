require "pp"
require "gnuplot"

# scriptの実行
elements = `osascript itunes.scpt`.chomp.split(",").map{ |item| item.strip }

# 曲名ごとにカウント
hash = Hash.new(0)
elements.each do |elem|
  next if (elem.index("instrumental"))
  len = elem.rindex(" ")
  name = elem[0..len]
  time = elem[len..elem.length]
  hash[name] += time.to_i;
end

# 再生数でソート
songs = hash.sort do |a, b|
  b[1] <=> a[1]
end

# Gnuplot用にラベルと回数を別々に配列へ格納
labels = []
times = []
songs.each_with_index do |item, idx|
  labels << "\"#{item[0]}\""
  times << item[1]
  break if idx > 50
end

t = Time.now
t_str = t.strftime("%Y%m%d_%H%M%S")
Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal "postscript eps enhanced font 'GothicBBB-Medium-EUC-H,15'"
    plot.output "graph.png"
    plot.title  "視聴回数"
    plot.yrange "[0:300]"
    plot.ylabel "再生回数"
    plot.bmargin "5"
    plot.style "fill solid border -1"
    plot.xtics "rotate by -90"
    plot.unset "key"

    plot.data << Gnuplot::DataSet.new([labels, times]) do |ds|
      ds.using = "2:xtic(1)"
      ds.with = 'boxes lc rgb "orange"'
      ds.title = "再生回数"
    end
  end
end