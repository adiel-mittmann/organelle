require 'org'
require 'html-formatter'

require 'time'

class AtDawn

  include HtmlFormatter

  attr_reader :send

  def initialize(path)
    @org = Org.new(path)

    case
    when ENV['TODAY']
      @today = Date.parse(ENV['TODAY']).to_time
    else
      @today = Date.today.to_time
    end

    @send = true
  end

  def todo_list

    def get_appt_nodes
      nodes = @org.nodes(:time)
      nodes = nodes.select do |node|
        case
        when node.type != :appt
          false
        when node.warning == nil
          false
        when node.warning.to_date.to_time != @today
          false
        else
          true
        end
      end
    end

    def get_todo_nodes
      nodes = @org.nodes(:priority_time)
      nodes = nodes.select do |node|
        case
        when node.type != :todo
          false
        when node.warning == nil
          false
        when node.warning > @today
          false
        else
          true
        end
      end
    end

    s = ""

    appts = get_appt_nodes
    todos = get_todo_nodes

    case
    when (appts.size + todos.size) == 0
      s << "<p><i>Apparently you have nothing to do today.</i></p>\n"

    else

      case
      when appts.size == 0
        s << "<p><i>Looks like you have no appointments today.</i></p>\n"

      else
        s << "<p>Here are your appointments:</p>\n"
        s << "<ul>\n"
        appts.each do |appt|
          s << "<li>#{self.format_node(appt)}</li>\n"
        end
        s << "</ul>\n"
      end

      case
      when todos.size == 0
        s << "<p><i>It seems you have nothing TODO today.</i></p>\n"
      else
        s << "<p>Here's your TODO list:</p>\n"
        s << "<ul>\n"
        todos.each do |todo|
          s << "<li>#{self.format_node(todo)}</li>\n"
        end
        s << "</ul>\n"
      end

    end

    return s
  end

  def email
    subject = "Your TODO list"
    body    = self.todo_list
    if @send
      return [subject, body]
    else
      return [nil, nil]
    end
  end

end
