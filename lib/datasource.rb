require "excon"
require "tmpdir"
require "open3"


# ugh, datasource? having trouble finding a good name for this
class Datasource
  # TODO: move to ENV var
  GITHUB_REF = "differential-med/differential-data@master"

  def initialize(github_ref:)
    @owner, @repo, @ref = github_ref.split(/\/|@/)
  end

  def self.load_to_db
    new(github_ref: GITHUB_REF).load_to_db
  end

  def self.drop_and_load!
    SymptomDiagnosis.delete_all
    Diagnosis.delete_all
    Symptom.delete_all
    load_to_db
  end

  def load_to_db
    Dir.mktmpdir do |dir|
      tree_archive_path = "#{dir}/tree_archive"
      tree_path         = "#{dir}/tree"

      download_archive_from_github(to_path: tree_archive_path)
      inflate(tree_archive_path, to_path: tree_path)
      # github archive will contain a container div with the ref SHA in the name
      # step into that
      tree_path = to_first_child_directory(tree_path)
      expect_top_level_folders(tree_path)
      load_from_filesystem(tree_path)
    end
  end

  def download_archive_from_github(to_path:)
    url = get_archive_url
    out = File.open(to_path, "wb+")

    Excon.get(
      url,
      expects: 200,
      response_block: ->(chunk, _remaining_bytes, _total_bytes) {
        out << chunk
      }
    )
  ensure
    out&.close
  end

  def expect_top_level_folders(path)
    unless File.directory?("#{path}/symptoms") && File.directory?("#{path}/diagnoses")
      binding.pry
      raise "datasource: failed to find symptoms and/or diagnoses directories"
    end
  end

  def load_from_filesystem(tree_path)
    each_subpath("#{tree_path}/diagnoses") do |path|
      load_diagnosis(path)
    end

    each_subpath("#{tree_path}/symptoms") do |path|
      load_symptom(path)
    end
  end

  def load_symptom(path)
    id         = File.basename(path)
    summary    = try_read("#{path}/summary.md")
    attributes = try_read_yaml("#{path}/attributes.yml") || {}

    Symptom.create! do |symptom|
      symptom.id = id
      symptom.summary = summary
      symptom.name = attributes["pretty-name"]
    end

    (attributes["diagnoses"] || []).each do |diagnosis_id|
      SymptomDiagnosis.create! do |sd|
        sd.symptom_id   = id
        sd.diagnosis_id = diagnosis_id
      end
    end
  end

  def load_diagnosis(path)
    id         = File.basename(path)
    summary    = try_read("#{path}/summary.md")
    attributes = try_read_yaml("#{path}/attributes.yml") || {}

    Diagnosis.create! do |diag|
      diag.id = id
      diag.summary = summary
      diag.name = attributes["pretty-name"]
    end
  end

  # private

  def get_archive_url
    response = Excon.get(
      "https://api.github.com/repos/#{@owner}/#{@repo}/tarball/#{@ref}",
      expects: 302
    )
    response.headers["Location"]
  end

  def try_read(path)
    File.read(path) if File.exist?(path)
  end

  def try_read_yaml(path)
    source = try_read(path)
    YAML.safe_load(source) if source
  end

  # yields directories only
  def each_subpath(path)
    Dir.foreach(path) do |child|
      next if child == "." || child == ".."

      subpath = "#{path}/#{child}"
      next unless File.directory?(subpath)

      yield subpath
    end
  end

  def inflate(archive_path, to_path:)
    exec("mkdir -p #{to_path}")
    exec("tar xzf #{archive_path} -C #{to_path}")
  end

  def exec(*args)
    stdout, stderr, status = Open3.capture3(*args)

    if status != 0
      raise("datasource: failed to run '#{args}': status=#{status} stderr=#{stderr}")
    end

    stdout
  end

  def to_first_child_directory(path)
    child = exec("ls #{path}").strip
    "#{path}/#{child}"
  end
end
