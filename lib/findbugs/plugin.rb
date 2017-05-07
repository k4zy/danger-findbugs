module Danger
  class DangerFindbugs < Plugin
    RANK_ERROR_THRESHOLD = 4

    attr_accessor :gradle_task
    attr_accessor :report_file

    def report_file
      return @report_file || 'build/reports/findbugs_report.xml'
    end

    attr_accessor :gradle_module

    def gradle_module
      return @gradle_module || 'app'
    end

    def report
      unless gradlew_exists?
        fail("Could not find `gradlew` inside current directory")
        return
      end

      system "./gradlew #{gradle_task || 'findbugs'}"

      unless File.exists?(report_file)
        fail("Findbugs report not found at `#{report_file}`. "\
        "Have you forgot to add `xmlReport true` to your `build.gradle` file?")
      end

      issues = read_issues_from_report
      send_inline_comment(issues)
    end

    private

    def make_pathname(path)
      if path == nil
        nil
      elsif path.is_a?(Pathname)
        path
      else
        Pathname.new(path)
      end
    end

    def read_issues_from_report
      file = File.open(report_file)

      require 'oga'
      report = Oga.parse_xml(file)

      report.xpath("//BugInstance").map do |info|
        rank = info.attribute("rank").value.to_i
        source_path = info.xpath("SourceLine/@sourcepath").first.to_s
        file_path = make_pathname(gradle_module).join("src/main/java", source_path).to_s
        {
            description: info.xpath("LongMessage/text()").first.text,
            file_path: file_path,
            line: info.xpath("SourceLine/@start").first.to_s.to_i,
            type: rank > RANK_ERROR_THRESHOLD ? :warning : :error,
        }
      end
    end

    def send_inline_comment (issues)
      target_files = (git.modified_files - git.deleted_files) + git.added_files
      dir = "#{Dir.pwd}/"
      issues.each do |issue|
        next unless target_files.include? issue[:file_path]
        send("fail", issue[:description], file: issue[:file_path], line: issue[:line])
      end
    end

    def gradlew_exists?
      `ls gradlew`.strip.empty? == false
    end

  end
end
