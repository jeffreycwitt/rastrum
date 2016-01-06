## repo file 
module Rastrum 
  class Repo
    def self.stage
      `git add -A`
    end
    def self.commit(message)
      `git commit -m "#{message}"`
    end
    def self.version(version)
      `git tag v#{version}`
    end
    def self.push(remote='origin', branch='master')
      `git push #{remote} #{branch}`
    end
    def self.full_update(version)
      self.stage
      self.commit("auto commit on version #{version} update")
      self.version(version)
      self.push
    end
    def self.light_update(version)
      self.stage
      self.commit("auto commit on version #{version} update")
    end
  end
end