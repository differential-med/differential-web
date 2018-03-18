require "excon"
require "tmpdir"

class Datasource
  # TODO: move to ENV var
  GITHUB_REF = "differential-med/differential-data@master"

  def initialize(github_ref:)
    @owner, @repo, @ref = github_ref.split(/\/|@/)
  end

  def self.load_to_db
    new(github_ref: GITHUB_REF).load_to_db
  end

  def self.drop_and_load
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
      load_from_filesystem(tree_path)
    end
  end

  def download_archive_from_github(to_path:)
    url = get_archive_url
    out = File.open(to_path, "w+")

    Excon.get(
      url,
      expects: 200,
      response_block: lambda(chunk, _remaining_bytes, _total_bytes) {
        out << chunk
      }
    )
  ensure
    out&.close
  end

  def inflate(archive_path, to_path:)
    `tar xzf -C #{to_path} #{archive_path}`
  end

  def load_from_filesystem(tree_path)
    Dir.foreach("#{tree_path}/symptoms") do |path|
      next unless File.directory?(path)
      load_symptom(path)
    end

    Dir.foreach("#{tree_path}/diagnoses") do |path|
      next unless File.directory?(path)
      load_diagnosis(path)
    end
  end

  def load_symptom(path)
    id         = File.basename(path)
    summary    = try_read("#{path}/summary.md")
    attributes = try_read_yaml("#{path}/attributes.yml")

    Symptom.create! do |symptom|
      symptom.id = id
      symptom.summary = summary
      symptom.name = attributes["pretty-name"]
    end

    (attributes[:diagnoses] || []).each do |diagnosis_id|
      SymptomDiagnosis.create! do |sd|
        sd.symptom_id   = id
        sd.diagnosis_id = diagnosis_id
      end
    end
  end

  def load_diagnosis(path)
    id         = File.basename(path)
    summary    = try_read("#{path}/summary.md")
    attributes = try_read_yaml("#{path}/attributes.yml")

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
end
