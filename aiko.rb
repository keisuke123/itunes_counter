require "gnuplot"

# scriptの実行
elements = `osascript itunes.scpt`.chomp.split(",").map{ |item| item.strip }

# 曲名ごとにカウント
hash = Hash.new(0)
albums = ["小さな丸い好日", "桜の木の下", "夏服", "秋 そばにいるよ", "暁のラブレター", "夢の中のまっすぐな道", "彼女", "秘密", "BABY", "まとめ I", "まとめ II", "時のシルエット", "泡のような愛だった", "May Dream"]
elements.each do |elem|
  next if (elem.index("instrumental"))
  len = elem.rindex(" ")
  name = elem[0..len-1]
  time = elem[len+1..elem.length] 
  if albums.include?(name) then # アルバムであるかどうか
    hash[name] += time.to_i;
  end
end

# 再生数でソート
songs = hash.sort do |a, b|
  b[1] <=> a[1]
end

# グラフの上限を設定
# 1400なら2000にするなど.
tmp = songs[0][1].to_s
max_val = tmp[0].to_i + 1;
max_val *= (10 ** (tmp.size - 1))

# Gnuplot用にラベルと回数を別々に配列へ格納
labels = []
times = []
songs.each_with_index do |item, idx|
  labels << "\"#{item[0]}\""
  times << item[1]
  break if idx > 50
end

# 描画
Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal "aqua font 'ヒラギノ角ゴ Pro W3,10'"
    plot.title  "視聴回数"
    plot.yrange "[0:#{max_val}]"
    plot.ylabel "再生回数"
    plot.bmargin "8"
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
