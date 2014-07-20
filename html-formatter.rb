module HtmlFormatter

  def escape(s)
    s.gsub(/</, "&lt;").gsub(/>/, "&gt;")
  end

  def priority_text(i)
    "#" + ("A".ord + i).chr
  end

  def format_node(node)

    text = "#{node.path}<b>#{self.escape(node.clean_label)}</b>"

    case
    when node.type == :appt
      return "<b style='color: red'>APPT #{self.priority_text(node.priority)}</b> <b>#{node.time.strftime('%H:%M')}</b> #{text}"
    when node.type == :todo
      return "<b style='color: red'>TODO #{self.priority_text(node.priority)}</b> <b>#{node.time.strftime('%Y-%m-%d')}</b> #{text}"
    end

  end

end
