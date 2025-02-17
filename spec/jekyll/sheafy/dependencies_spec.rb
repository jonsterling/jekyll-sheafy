require "jekyll/sheafy/dependencies"

describe Jekyll::Sheafy::Dependencies do
  describe ".scan_includes" do
    it "detects nothing on empty file" do
      node = Node.new(content: "")
      expect(subject.scan_includes(node)).to eq([])
    end

    it "detects includes mixed with text" do
      node = Node.new(content: <<~CONTENT)
        Lorem ipsum.
        @include{0001}
        Dolor sit amet.
        @include{0002}
        Yadda yadda yadda.
        @include{0003}
      CONTENT
      expect(subject.scan_includes(node)).to eq(["0001", "0002", "0003"])
    end

    it "keeps duplicates" do
      node = Node.new(content: <<~CONTENT)
        @include{0001}
        @include{0001}
      CONTENT
      expect(subject.scan_includes(node)).to eq(["0001", "0001"])
    end
  end

  describe ".build_adjacency_list" do
    it "builds nothing on empty index" do
      index = {}
      expect(subject.build_adjacency_list(index)).to eq({})
    end

    it "correctly interpretes a boring index" do
      index = {
        "0000" => Node.new(content: "@include{0001}\n@include{0002}\n"),
        "0001" => Node.new(content: ""),
        "0002" => Node.new(content: "@include{0003}\n@include{0004}\n"),
        "0003" => Node.new(content: ""),
        "0004" => Node.new(content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq({
        "0000" => ["0001", "0002"],
        "0001" => [],
        "0002" => ["0003", "0004"],
        "0003" => [],
        "0004" => [],
      })
    end

    it "keeps duplicates" do
      index = {
        "0000" => Node.new(content: "@include{0001}\n" * 2),
        "0001" => Node.new(content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq(
        { "0000" => ["0001", "0001"], "0001" => [] }
      )
    end
  end
end
