require "csv"
require "pp"

def getFile
  matchingFile = Dir['data/access_log_*-*.log']
  parsingResult = matchingFile.map do |file|
    accessLogLines = File.open(file,'r') do |f|
      f.readlines
    end
    parsedLog(accessLogLines)
  end
  pp parsingResult

end
def parsedLog(accessLogLines)

  signUpLogLines = accessLogLines.select do |line|
    line.include?('/signup?email=')
  end

  userData = signUpLogLines.map do |line|
    parsedArray = line.split('" "')
    email = extractEmail(parsedArray.first)
    userAgentString = parsedArray.last
    browser = dertermineBrowser(userAgentString)
    [email,browser]
  end

  cressReferencesData = userData.map do |line|
    crossReference(line)
  end
  cressReferencesData
end


def dertermineBrowser(userAgent)
  return "Firefox" if userAgent.include?("Firefox")&&userAgent.include?("Gecko")
  return "Chrome" if userAgent.include?("Chrome")
  return "Safari" if userAgent.include?("Safari")&&userAgent.include?("Gecko")
  "Other"
end

def extractEmail(logLine)
  email =  logLine.match(/signup\?email\=([A-Za-z0-9@.]*) HTTP\//)
  email.captures.first
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
    line
  end
  matchingUser = users.select do |line|
    logLine[0] == line[2]
  end
  matchingUser = matchingUser.first

  {firstname: matchingUser[1],
   lastname: matchingUser[0] ,
   email: matchingUser[2],
   browser: logLine[1]}
end


pp getFile

