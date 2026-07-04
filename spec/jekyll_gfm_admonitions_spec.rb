# frozen_string_literal: true

require 'spec_helper'

DocStub = Struct.new(:content, :path)

RSpec.describe JekyllGFMAdmonitions::GFMAdmonitionConverter do
  let(:markdown_converter) { double('Jekyll::Converters::Markdown') }

  subject(:converter) do
    obj = described_class.allocate
    obj.instance_variable_set(:@markdown, markdown_converter)
    obj
  end

  # Make markdown_converter return a simple <p> wrapper by default
  before do
    allow(markdown_converter).to receive(:convert) do |text|
      "<p>#{text.strip}</p>\n"
    end
  end

  # -----------------------------------------------------------------------
  # process_doc helpers
  # -----------------------------------------------------------------------

  def doc_with(content)
    DocStub.new(content.dup, 'test.md')
  end

  # -----------------------------------------------------------------------
  # Frozen string guard
  # -----------------------------------------------------------------------

  describe '#process_doc' do
    it 'does not raise when content is frozen' do
      doc = doc_with("> [!NOTE]\n> hello\n".freeze)
      expect { converter.send(:process_doc, doc) }.not_to raise_error
    end

    it 'returns early on empty content' do
      doc = doc_with('')
      converter.send(:process_doc, doc)
      expect(doc.content).to eq('')
    end

    it 'leaves non-admonition content unchanged' do
      doc = doc_with("# Hello\n\nJust some text.\n")
      converter.send(:process_doc, doc)
      expect(doc.content).to eq("# Hello\n\nJust some text.\n")
    end

    # -----------------------------------------------------------------------
    # All 5 admonition types
    # -----------------------------------------------------------------------

    %w[NOTE TIP WARNING IMPORTANT CAUTION].each do |type|
      it "renders #{type} admonitions" do
        doc = doc_with("> [!#{type}]\n> body\n")
        converter.send(:process_doc, doc)
        expect(doc.content).to include("markdown-alert-#{type.downcase}")
      end
    end

    # -----------------------------------------------------------------------
    # Case-insensitive tags (issue #23) — GitHub treats [!note], [!WarnIng]
    # the same as their uppercase forms.
    # -----------------------------------------------------------------------

    {
      'note' => 'note',
      'WarnIng' => 'warning',
      'Tip' => 'tip',
      'iMpOrTaNt' => 'important',
      'caution' => 'caution'
    }.each do |tag, type|
      it "renders the mixed/lower-case tag [!#{tag}] as a #{type} admonition" do
        doc = doc_with("> [!#{tag}]\n> body\n")
        converter.send(:process_doc, doc)
        expect(doc.content).to include("markdown-alert-#{type}")
      end
    end

    # -----------------------------------------------------------------------
    # Code blocks are restored exactly
    # -----------------------------------------------------------------------

    it 'leaves admonitions inside code blocks untouched' do
      code = "```\n> [!NOTE]\n> secret\n```"
      doc = doc_with(code)
      converter.send(:process_doc, doc)
      expect(doc.content).to include('> [!NOTE]')
    end

    it 'restores code block content exactly' do
      original = "```ruby\nputs 'hello'\n```\n"
      doc = doc_with(original)
      converter.send(:process_doc, doc)
      expect(doc.content).to eq(original)
    end

    # -----------------------------------------------------------------------
    # 4-space / tab indented code blocks are not converted
    # -----------------------------------------------------------------------

    context 'indented (4-space/tab) code blocks' do
      it 'does not convert 4-space indented admonition-like content' do
        content = "\n\n    > [!NOTE]\n    > this is code, not an admonition!\n"
        doc = doc_with(content)
        converter.send(:process_doc, doc)
        expect(doc.content).to include('> [!NOTE]')
        expect(doc.content).not_to include('markdown-alert')
      end

      it 'does not convert tab-indented admonition-like content' do
        content = "\n\n\t> [!WARNING]\n\t> tabbed code block\n"
        doc = doc_with(content)
        converter.send(:process_doc, doc)
        expect(doc.content).to include('> [!WARNING]')
        expect(doc.content).not_to include('markdown-alert')
      end

      it 'does not convert 4-space indented content at start of document' do
        content = "    > [!TIP]\n    > code at top of file\n"
        doc = doc_with(content)
        converter.send(:process_doc, doc)
        expect(doc.content).to include('> [!TIP]')
        expect(doc.content).not_to include('markdown-alert')
      end

      it 'restores 4-space indented code block content exactly' do
        original = "paragraph\n\n    some code\n    more code\n"
        doc = doc_with(original)
        converter.send(:process_doc, doc)
        expect(doc.content).to eq(original)
      end

      it 'still converts a real admonition when document also contains an indented code block' do
        content = "paragraph\n\n    some code\n\n> [!NOTE]\n> real admonition\n"
        doc = doc_with(content)
        converter.send(:process_doc, doc)
        expect(doc.content).to include('markdown-alert-note')
        expect(doc.content).to include('    some code')
      end

      it 'still converts 2-space indented admonitions inside list items' do
        doc = doc_with("- item\n\n  > [!CAUTION]\n  > caution text\n")
        converter.send(:process_doc, doc)
        expect(doc.content).to include('markdown-alert-caution')
      end

      it 'still converts 3-space indented admonitions inside list items' do
        doc = doc_with("1. item\n\n   > [!TIP]\n   > tip text\n")
        converter.send(:process_doc, doc)
        expect(doc.content).to include('markdown-alert-tip')
      end

      it 'restores multiple indented code blocks independently' do
        original = "para\n\n    first block\n\nmore text\n\n    second block\n"
        doc = doc_with(original)
        converter.send(:process_doc, doc)
        expect(doc.content).to include('    first block')
        expect(doc.content).to include('    second block')
      end
    end
  end

  # -----------------------------------------------------------------------
  # convert_admonitions
  # -----------------------------------------------------------------------

  describe '#convert_admonitions' do
    it 'uses a custom title when provided' do
      doc = doc_with("> [!NOTE] My Custom Title\n> body\n")
      converter.send(:convert_admonitions, doc)
      expect(doc.content).to include('My Custom Title')
    end

    it 'falls back to capitalised type when title is blank' do
      doc = doc_with("> [!NOTE]\n> body\n")
      converter.send(:convert_admonitions, doc)
      expect(doc.content).to include('Note')
    end

    it 'preserves indentation for admonitions inside list items' do
      doc = doc_with("1. item\n\n   > [!NOTE]\n   > indented body\n")
      converter.send(:convert_admonitions, doc)
      # Every line of the replacement HTML must carry the same indent
      expect(doc.content).to match(/^   <div/)
      expect(doc.content).to match(/^   <\/div>/)
    end

    it 'does not leave a bare </div> at column 0 for indented admonitions' do
      # A bare </div> at column 0 causes kramdown to emit <p>&lt;/div&gt;</p>
      doc = doc_with("- item\n\n  > [!NOTE]\n  > body\n")
      converter.send(:convert_admonitions, doc)
      expect(doc.content).not_to match(/^<\/div>/)
    end

    it 'captures multi-line body correctly' do
      doc = doc_with("> [!TIP]\n> line one\n> line two\n")
      converter.send(:convert_admonitions, doc)
      expect(doc.content).to include('line one')
      expect(doc.content).to include('line two')
    end

    # Regression test for issue #20: nested (second-hierarchy) bullet points
    # inside an admonition were flattened to the first hierarchy because the
    # blockquote-stripping regex consumed *all* whitespace after `>` instead of
    # the single space a `>` marker is allowed to consume.
    it 'preserves nested list indentation when stripping blockquote markers' do
      received = nil
      allow(markdown_converter).to receive(:convert) do |text|
        received = text
        "<p>#{text}</p>"
      end
      doc = doc_with(
        "> [!NOTE]\n" \
        "> Some text\n" \
        "> - `templates/`\n" \
        ">   - `generateBuilders.mustache`\n" \
        ">   - `pojo.mustache`\n"
      )
      converter.send(:convert_admonitions, doc)
      expect(received).to eq(
        "Some text\n" \
        "- `templates/`\n" \
        "  - `generateBuilders.mustache`\n" \
        "  - `pojo.mustache`"
      )
    end

    it 'preserves nested list indentation for admonitions inside list items' do
      received = nil
      allow(markdown_converter).to receive(:convert) do |text|
        received = text
        "<p>#{text}</p>"
      end
      # 3-space indent (e.g. inside an ordered list item) before the `>` marker.
      doc = doc_with(
        "1. item\n\n" \
        "   > [!NOTE]\n" \
        "   > - parent\n" \
        "   >   - child\n"
      )
      converter.send(:convert_admonitions, doc)
      expect(received).to eq("- parent\n  - child")
    end
  end

  # -----------------------------------------------------------------------
  # admonition_html — .md link rewriting
  # -----------------------------------------------------------------------

  describe '#admonition_html' do
    let(:icon) { '' }

    before do
      allow(markdown_converter).to receive(:convert) do |text|
        # Simulate a rendered link
        text
      end
    end

    it 'rewrites relative .md links to .html' do
      allow(markdown_converter).to receive(:convert)
        .with('see [page](other.md)')
        .and_return('<p>see <a href="other.md">page</a></p>')

      html = converter.send(:admonition_html, 'note', 'Note', 'see [page](other.md)', icon)
      expect(html).to include('href="other.html"')
      expect(html).not_to include('href="other.md"')
    end

    it 'preserves anchor fragments when rewriting .md links' do
      allow(markdown_converter).to receive(:convert).and_return(
        '<p><a href="other.md#section">link</a></p>'
      )

      html = converter.send(:admonition_html, 'note', 'Note', 'text', icon)
      expect(html).to include('href="other.html#section"')
    end

    it 'does not rewrite external https:// .md URLs' do
      allow(markdown_converter).to receive(:convert).and_return(
        '<p><a href="https://example.com/page.md">ext</a></p>'
      )

      html = converter.send(:admonition_html, 'note', 'Note', 'text', icon)
      expect(html).to include('href="https://example.com/page.md"')
    end
  end
end
