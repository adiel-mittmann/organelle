# -*- coding: utf-8 -*-
require 'time'

class Node

  attr_reader :parent, :children
  attr_reader :label, :text, :time, :warning, :type, :priority

  def initialize(parent, label = nil)
    @parent   = parent
    @children = []

    @label    = label
    @text     = nil
    @time     = nil
    @warning  = nil
    @type     = nil
    @priority = nil

    @parent.add_child(self) if @parent
  end

  def add_child(child)
    @children << child
  end

  def root?
    @parent == nil
  end

  def visit(&block)
    yield self if !self.root?
    @children.each do |child|
      child.visit(&block)
    end
  end

  def clean_label
    self.label
      .gsub(/^\*+ */, "")
      .gsub(/^(TODO|APPT|DONE) */, "")
      .gsub(/^\[#[A-Z]\] */, "")
      .gsub(/ *:[^: ]*:$/, "")
      .gsub(/ *\[[0-9]*%\]$/, "")
      .gsub(/ *<[0-9]{4}-[0-9]{2}-[0-9]{2} [^>]*>$/, "")
  end

  def path
    s = ""

    parent = self.parent
    while !parent.root?
      s = parent.clean_label() + "/" + s
      parent = parent.parent
    end

    return s
  end

  def append_line(line)
    @text = "" if !@text
    @text << line << "\n"
  end

  def parse

    case
    when @label =~ /\*+ APPT/
      @type = :appt
    when @label =~ /\*+ TODO/
      @type = :todo
    else
      @type = :other
    end

    case
    when @label =~ /\[#([A-Z])\]/
      @priority = $1.ord - "A".ord
    else
      @priority = 1
    end

    self.parse_dates
  end

  def parse_dates

    def parse_date_time(string)
      Time.strptime(string, "%Y-%m-%d %H:%M")
    end

    def parse_date(string)
      Time.strptime(string, "%Y-%m-%d")
    end

    case
    when @type == :appt && @label =~ /.*<(....-..-..) ... (..:..)[^>]*>.*$/
      @time    = parse_date_time("#{$1} #{$2}")
      @warning = @time

    when @type == :todo && @text
      first_line = @text.lines.first

      case
      when first_line =~ /DEADLINE: <(....-..-..) ... -([0-9]+)d>$/
        @time    = parse_date($1)
        @warning = (@time.to_date - $2.to_i).to_time

      when first_line =~ /DEADLINE: <(....-..-..)(.*)>$/
        @time    = parse_date($1)
        @warning = (@time.to_date - Org::ORG_DEADLINE_WARNING_DAYS).to_time

      when first_line =~ /SCHEDULED: <(....-..-..).*>$/
        @time    = parse_date($1)
        @warning = @time
      end
    end
  end

  def inspect(prefix = "")
    s = ""

    s << prefix

    if [:todo, :appt].include?(@type)
      s << @type.to_s.upcase
    else
      s << "NODE"
    end

    if @priority
      s << " " << "[#" << ("A".ord + @priority) << "]"
    end

    case
    when self.root?
      s << " ROOT"
    else
      s << " “" << self.clean_label << "”"
    end

    if @time
      s << " TIME: <" << @time.strftime("%Y-%m-%d %H:%M") << ">"
    end
    if @warning
      s << " WARN: <" << @warning.strftime("%Y-%m-%d") << ">"
    end
    if @text && @text.length > 0
      s << " TEXT: " << @text.length.to_s << " chars"
    end

    s << "\n"

    @children.each do |child|
      s << child.inspect(prefix + "    ")
    end

    return s
  end

end

