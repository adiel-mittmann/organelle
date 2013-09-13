$:.push(File.expand_path(File.dirname(__FILE__)))

require 'at-dawn'
require 'at-evening'

require 'pony'

class Organelle

  CONFIG_PONY={
    :via => :smtp,
    :via_options => {
      :address    => '127.0.0.1',
      :port     => '25'
    }
  }

  def run(argv)

    if argv.size < 4
      puts "ruby organelle.rb at-evening|at-dawn ORG-FILE EMAIL-FROM EMAIL-TO"
      return
    end

    @type        = argv[0]
    @org_file    = argv[1]
    @email_from  = argv[2]
    @email_to    = argv[3]

    case
    when @type == "at-dawn"
      subject, body = AtDawn.new(@org_file).email()
    when @type == "at-evening"
      subject, body = AtEvening.new(@org_file).email()
    else
      puts "Invalid type: #{@type}"
      return
    end

    self.send(subject, body)
  end

  def send(subject, body)

    return if subject == nil || body == nil

    hash = CONFIG_PONY.dup
    hash[:to]        = @email_to
    hash[:from]      = @email_from
    hash[:subject]   = subject
    hash[:html_body] = body

    if ENV['DEBUG'] == "1"
      puts hash[:html_body]
    else
      Pony.mail(hash)
    end
  end

end

Organelle.new.run(ARGV)
