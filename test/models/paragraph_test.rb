require "test_helper"

class ParagraphTest < ActiveSupport::TestCase
  test "content is stripped on create" do
    p = Paragraph.new(
      chapter: chapters(:one),
      position: 10,
      content: " \n  content \n"
    )
    p.save
    assert_equal "content", p.content
  end
end
