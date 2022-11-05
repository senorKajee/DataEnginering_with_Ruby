require "csv"
def parsedLog
  fileName  = 'data/access_log_20190521-211058.log'
  accessLogLines = File.open(fileName,'r') do |f|
    f.readlines
  end

  signUpLogLines = accessLogLines.select do |line|
    line.include?('/signup?email=')
  end

  userData = signUpLogLines.map do |line|
    parsedArray = line.split('" "')
    email = extractEmail(parsedArray.first)
    userAgentString = line.split('" "').last
    browser = dertermineBrowser(userAgentString)
    [email,browser]
  end
  puts userData
end


def dertermineBrowser(userAgent)
  return "Firefox" if userAgent.include?("Firefox")&&userAgent.include?("Gecko")
  return "Chrome" if userAgent.include?("Chrome")
  return "Safari" if userAgent.include?("Safari")&&userAgent.include?("Gecko")
  return "Other"
end

def extractEmail(logLine)
  email =  logLine.match(/signup\?email\=([A-Za-z0-9@.]*) HTTP\//)
  email.captures
end

def crossReference(logLine)
  users = CSV.open('data/users.csv') do |csv|
    csv.readlines
  end
  users.map! do |line|
    if line.length == 3
      if line[0].nil?
        line[0] = "Unknown"
      end
      if line[1].nil?
        line[1] = "Unknown"
      end
    else
      if line[0].match(/[A-Za-z0-9@.]*/)
        email = line[0]
        line[0] = "Unknown"
        line.push("Unknown")
        line.push(email)
      end
    end
  end
  users
end

p crossReference("")
#parsedLog

