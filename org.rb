require 'org-node'

class Org

  ORG_DEADLINE_WARNING_DAYS = 14

  def initialize(path)

    @tree = Node.new(nil)

    self.parse(path)

    if ENV['DEBUG'] == "1"
      puts self.inspect
    end

  end

  def parse(path)

    chain = [@tree]

    File.read(path, {:encoding => 'UTF-8'}).lines.each do |line|

      line.strip!

      if line =~ /^(\*+)/

        level = $1.length

        if level < chain.size
          gap   = chain.size - level
          chain = chain[0..-(gap + 1)]
        end

        parent_node = chain[-1]
        child_node  = Node.new(parent_node, line)

        chain << child_node

      else
        chain[-1].append_line(line)
      end
    end
    @tree.visit do |node| node.parse end
  end

  def nodes(sort_by = :priority_time)

    a = []
    @tree.visit do |node|
      a << node
    end

    case
    when sort_by == :priority_time

      a = a.sort do |a, b|
        case
        when a.priority == b.priority
          case
          when a.time && b.time
            a.time <=> b.time
          when !a.time && !b.time
            0
          when !a.time
            -1
          when !b.time
            1
          end
        else
          a.priority <=> b.priority
        end
      end

    when sort_by == :time
      a = a.sort do |a, b|
        case
        when !a.time && !b.time
          0
        when !a.time
          -1
        when !b.time
          1
        else
          a.time <=> b.time
        end
      end
    end

    return a
  end

  def inspect
    return @tree.inspect
  end

end
