class BugIssue
  RANK_ERROR_THRESHOLD = 4
  attr_accessor :module_name
  attr_accessor :buginfo

  def initialize(module_name, buginfo)
    @module_name = module_name
    @buginfo = buginfo
  end

  def rank
    @rack ||= buginfo.attribute("rank").value.to_i
  end

  def type
    @type ||= rank > RANK_ERROR_THRESHOLD ? :warn : :fail
  end

  def line
    @line ||= buginfo.xpath("SourceLine/@start").first.to_s.to_i
  end

  def source_path
    @source_path ||= buginfo.xpath("SourceLine/@sourcepath").first.to_s
  end

  def description
    @description ||= buginfo.xpath("LongMessage/text()").first.text
  end

  def absolute_path
    @absolute_path ||= Pathname.new(module_name).join("src/main/java", source_path).to_s
  end

end
