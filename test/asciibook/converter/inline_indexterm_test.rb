require 'test_helper'

class Asciibook::Converter::InlineIndextermTest < Asciibook::Test
  def test_convert_inline_indexterm_visible
    doc = <<~EOF
      ((term))
    EOF

    html = <<~EOF
      <p>
        <a class="indexterm" id="_indexterm_1">term</a>
      </p>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_inline_indexterm_invisible
    doc = <<~EOF
      (((primary, secondary, tertiary)))
    EOF

    html = <<~EOF
      <p>
        <a class="indexterm" id="_indexterm_1">&#8203;</a>
      </p>
    EOF

    assert_convert_body html, doc
  end
end
