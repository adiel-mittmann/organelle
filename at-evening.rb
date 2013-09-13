require 'org'
require 'html-formatter'

require 'time'

class AtEvening

  include HtmlFormatter

  attr_reader :send

  def initialize(path)
    @org      = Org.new(path)

    case
    when ENV['TODAY']
      @today = Date.parse(ENV['TODAY']).to_time
    else
      @today = Date.today.to_time
    end
    @tomorrow = (@today.to_date + 1).to_time
    @early    = Time.new(@tomorrow.year, @tomorrow.month, @tomorrow.day, 12, 00)

    @send     = false
  end

  def early_appointments
    s = ""

    nodes = @org.nodes(:time)
    nodes = nodes.select do |node|
      case
      when node.type != :appt
        false
      when node.time == nil
        false
      when node.time.to_date.to_time != @tomorrow
        false
      when node.time > @early
        false
      else
        true
      end
    end

    case
    when nodes.size == 0
      s << "<p>Looks like there are no early appointments this time.</p>"

    else

      s << "<p>Here are your <b>EARLY</b> appointments:</p>\n"
      s << "<ul>"
      nodes.each do |node|
        s << "<li>#{self.format_node(node)}</li>"
      end
      s << "</ul>"

      @send = true
    end

    return s
  end

  def email
    subject = "You have early appointments tomorrow"
    body    =  self.early_appointments
    if @send
      return [subject, body]
    else
      return [nil, nil]
    end
  end

end
